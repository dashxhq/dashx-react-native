package com.dashx.rn.sdk

import android.annotation.TargetApi
import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.provider.MediaStore
import com.dashx.rn.sdk.util.*
import com.dashx.sdk.DashXLog
import com.dashx.sdk.data.ExternalAsset
import com.facebook.react.bridge.*
import com.google.gson.Gson
import java.io.File
import com.dashx.sdk.DashXClient as DashX


class DashXReactNativeModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    private val tag = DashXReactNativeModule::class.java.simpleName
    private var dashXClient: DashX? = null

    override fun getName(): String {
        return "DashXReactNative"
    }

    @ReactMethod
    fun setLogLevel(logLevel: Int) {
        DashXLog.setLogLevel(logLevel)
    }

    @ReactMethod
    fun configure(options: ReadableMap) {
        dashXClient = DashX.createInstance(
            reactContext,
            options.getString("publicKey")!!,
            options.getStringIfPresent("baseURI"),
            options.getStringIfPresent("targetEnvironment")
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
            data?.toHashMap() as HashMap<String, String>
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
                promise.resolve(convertJsonToMap(it))
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
            jsonFilter,
            jsonOrder,
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
                    readableArray.pushMap(convertJsonToMap(it))
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
            jsonCustom,
            onError = {
                promise.reject("EUNSPECIFIED", it)
            },
            onSuccess = { content ->
                promise.resolve(convertJsonToMap(content))
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
                promise.resolve(convertJsonToMap(content))
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
                promise.resolve(convertJsonToMap(content))
            }
        )
    }

    @ReactMethod
    fun saveStoredPreferences(preferenceData: ReadableMap?, promise: Promise) {
        val preferencesHashMap = MapUtil.toJSONElement(preferenceData)

        dashXClient?.saveStoredPreferences(
            preferencesHashMap,
            onError = {
                promise.reject("EUNSPECIFIED", it)
            },
            onSuccess = { content ->
                promise.resolve(convertJsonToMap(content))
            }
        )
    }

    @ReactMethod
    fun uploadExternalAsset(
        file: ReadableMap, 
        externalColumnId: String, 
        promise: Promise
    ) {
        val jsonFile = try {
            convertMapToJson(file)
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            throw Exception("Encountered an error while parsing file")
        }

        // Remove unnecessary double quotes from RN URI
        val filePath = getFilePathFromURIString(jsonFile?.get("uri").toString())
        val fileObject = File(filePath)

        dashXClient?.uploadExternalAsset(
            fileObject,
            externalColumnId,
            onError = {
                promise.reject("EUNSPECIFIED", it)
            },
            onSuccess = { content ->
                val jsonObject = Gson().toJsonTree(content, ExternalAsset::class.java).asJsonObject
                promise.resolve(convertJsonToMap(jsonObject))
            }
        )
    }

    @ReactMethod
    fun externalAsset(
            id: String,
            promise: Promise
    ) {
        dashXClient?.externalAsset(
            id,
            onError = {
                promise.reject("EUNSPECIFIED", it)
            },
            onSuccess = { content ->
                val jsonObject = Gson().toJsonTree(content, ExternalAsset::class.java).asJsonObject
                promise.resolve(convertJsonToMap(jsonObject))
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

        // Remove unnecessary URI component
        val filePath = path!!.substring(path?.indexOf(':') + 1)

        return filePath
    }
}
