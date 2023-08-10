package com.dashx.rn.sdk

import android.content.pm.PackageInfo
import android.content.pm.PackageManager.NameNotFoundException
import android.net.Uri
import com.dashx.rn.sdk.util.*
import com.dashx.sdk.DashXClient as DashX
import com.dashx.sdk.DashXLog
import com.dashx.sdk.DashXLog.LogLevel
import com.dashx.sdk.data.LibraryInfo
import com.facebook.react.bridge.*
import java.io.File
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject

class DashXReactNativeModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    private val tag = DashXReactNativeModule::class.java.simpleName
    private var dashXClient: DashX? = null

    override fun getName(): String {
        return "DashXReactNative"
    }

    @ReactMethod
    fun setLogLevel(level: Int) {
        val logLevel = LogLevel.values().firstOrNull { it.code == level } ?: LogLevel.OFF
        DashXLog.setLogLevel(logLevel)
    }

    @ReactMethod
    fun configure(options: ReadableMap) {
        dashXClient = DashX.configure(
            reactContext,
            options.getString("publicKey")!!,
            options.getStringIfPresent("baseURI"),
            options.getStringIfPresent("targetEnvironment"),
            LibraryInfo("dashx-react-native", BuildConfig.VERSION_NAME)
        )
    }

    @ReactMethod
    fun identify(options: ReadableMap?) {
        val optionsHashMap = options?.toHashMap()
        dashXClient?.identify(optionsHashMap as HashMap<String, String>?)
    }

    @ReactMethod
    fun setIdentity(uid: String?, token: String?) {
        dashXClient?.setIdentity(uid, token)
    }

    @ReactMethod
    fun reset() {
        dashXClient?.reset()
    }

    @ReactMethod
    fun track(event: String, data: ReadableMap?) {
        val jsonData = try {
            data?.toHashMap() as HashMap<String, String>?
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            return
        }

        dashXClient?.track(event, jsonData)
    }

    @ReactMethod
    fun screen(screenName: String, data: ReadableMap?) {
        dashXClient?.screen(screenName, data?.toHashMap() as HashMap<String, String>)
    }

    @ReactMethod
    fun fetchContent(urn: String, options: ReadableMap?, promise: Promise) {
        dashXClient?.fetchContent(
            urn,
            options?.getBooleanIfPresent("preview"),
            options?.getStringIfPresent("language"),
            listOf(options?.getArray("fields")) as List<String>?,
            listOf(options?.getArray("include")) as List<String>?,
            listOf(options?.getArray("exclude")) as List<String>?,
            onError = {
                promise.reject("EUNSPECIFIED", it)
            },
            onSuccess = {
                promise.resolve(convertJsonToMap(convertKJsonToJson(it)))
            }
        )
    }

    @ReactMethod
    fun searchContent(contentType: String, options: ReadableMap?, promise: Promise) {
        val jsonFilter = try {
            convertMapToJson(options?.getMap("filter"))
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            throw Exception("Encountered an error while parsing filter")
        }

        val jsonOrder = try {
            convertMapToJson(options?.getMap("order"))
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            throw Exception("Encountered an error while parsing order")
        }

        dashXClient?.searchContent(
            contentType,
            options?.getString("returnType") ?: "all",
            convertJsonToKJson(jsonFilter),
            convertJsonToKJson(jsonOrder),
            options?.getIntIfPresent("limit"),
            options?.getBooleanIfPresent("preview"),
            options?.getStringIfPresent("language"),
            listOf(options?.getArray("fields")) as List<String>?,
            listOf(options?.getArray("include")) as List<String>?,
            listOf(options?.getArray("exclude")) as List<String>?,
            onError = {
                promise.reject("EUNSPECIFIED", it)
            },
            onSuccess = { content ->
                val readableArray = Arguments.createArray()
                content.forEach {
                    readableArray.pushMap(convertJsonToMap(convertKJsonToJson(it)))
                }
                promise.resolve(readableArray)
            }
        )
    }

    @ReactMethod
    fun addItemToCart(
        itemId: String,
        pricingId: String,
        quantity: String,
        reset: Boolean? = false,
        custom: ReadableMap? = null,
        promise: Promise
    ) {
        val jsonCustom = try {
            convertMapToJson(custom)
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            throw Exception("Encountered an error while parsing custom")
        }

        dashXClient?.addItemToCart(
            itemId,
            pricingId,
            quantity,
            reset ?: false,
            convertJsonToKJson(jsonCustom),
            onError = {
                promise.reject("EUNSPECIFIED", it)
            },
            onSuccess = { content ->
                promise.resolve(convertJsonToMap(convertKJsonToJson(Json.decodeFromString<JsonObject>(Json.encodeToString(content)))))
            }
        )
    }

    @ReactMethod
    fun fetchCart(promise: Promise) {
        dashXClient?.fetchCart(
            onError = {
                promise.reject("EUNSPECIFIED", it)
            },
            onSuccess = { content ->
                promise.resolve(convertJsonToMap(convertKJsonToJson(Json.decodeFromString<JsonObject>(Json.encodeToString(content)))))
            }
        )
    }

    @ReactMethod
    fun fetchStoredPreferences(promise: Promise) {
        dashXClient?.fetchStoredPreferences(
            onError = {
                promise.reject("EUNSPECIFIED", it)
            },
            onSuccess = { content ->
                promise.resolve(convertJsonToMap(convertKJsonToJson(Json.decodeFromString<JsonObject>(Json.encodeToString(content)))))
            }
        )
    }

    @ReactMethod
    fun saveStoredPreferences(preferenceData: ReadableMap?, promise: Promise) {
        val preferencesString = MapUtil.toJSONElement(preferenceData).toString()

        dashXClient?.saveStoredPreferences(
            Json.decodeFromString<JsonObject>(preferencesString),
            onError = {
                promise.reject("EUNSPECIFIED", it)
            },
            onSuccess = { content ->
                promise.resolve(convertJsonToMap(convertKJsonToJson(Json.decodeFromString<JsonObject>(Json.encodeToString(content)))))
            }
        )
    }

    @ReactMethod
    fun subscribe() {
        dashXClient?.subscribe()
    }

    //FIXME Amend the logic to work with React Native content URIs
    fun getFilePathFromURIString(contentUriString: String): String {
        val sanitizedURI = contentUriString.replace("\"", "")
        val path = Uri.parse(sanitizedURI).path
        val index = path?.indexOf(':')

        if (index == null) {
            return ""
        }

        // Remove unnecessary URI component
        val filePath = path!!.substring(index!! + 1)

        return filePath
    }
}
