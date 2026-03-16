package com.dashx.rn.sdk

import android.net.Uri
import com.dashx.rn.sdk.util.*
import com.dashx.android.DashX
import com.dashx.android.DashXLog
import com.dashx.android.DashXLog.LogLevel
import com.facebook.react.bridge.*
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject

class DashXReactNativeModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    private val tag = DashXReactNativeModule::class.java.simpleName

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
        DashX.configure(
            reactContext,
            options.getString("publicKey")!!,
            options.getStringIfPresent("baseURI"),
            options.getStringIfPresent("targetEnvironment")
        )
    }

    @ReactMethod
    fun identify(options: ReadableMap?) {
        val optionsHashMap = options?.toHashMap()
        DashX.identify(optionsHashMap as HashMap<String, String>?)
    }

    @ReactMethod
    fun setIdentity(uid: String?, token: String?) {
        DashX.setIdentity(uid, token)
    }

    @ReactMethod
    fun reset() {
        DashX.reset()
    }

    @ReactMethod
    fun track(event: String, data: ReadableMap?) {
        val jsonData = try {
            data?.toHashMap() as HashMap<String, String>?
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            return
        }

        DashX.track(event, jsonData)
    }

    @ReactMethod
    fun screen(screenName: String, data: ReadableMap?) {
        DashX.screen(screenName, data?.toHashMap() as HashMap<String, String>)
    }

    @ReactMethod
    fun fetchContent(urn: String, options: ReadableMap?, promise: Promise) {
        DashX.fetchRecord(
            urn,
            options?.getBooleanIfPresent("preview"),
            options?.getStringIfPresent("language"),
            onError = {
                promise.reject("EUNSPECIFIED", it.message)
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

        DashX.searchRecords(
            contentType,
            convertJsonToKJson(jsonFilter),
            onError = {
                promise.reject("EUNSPECIFIED", it.message)
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
    fun fetchStoredPreferences(promise: Promise) {
        DashX.fetchStoredPreferences(
            onError = {
                promise.reject("EUNSPECIFIED", it.message)
            },
            onSuccess = { content ->
                promise.resolve(convertJsonToMap(convertKJsonToJson(Json.decodeFromString<JsonObject>(Json.encodeToString(content)))))
            }
        )
    }

    @ReactMethod
    fun saveStoredPreferences(preferenceData: ReadableMap?, promise: Promise) {
        val preferencesString = MapUtil.toJSONElement(preferenceData).toString()

        DashX.saveStoredPreferences(
            Json.decodeFromString<JsonObject>(preferencesString),
            onError = {
                promise.reject("EUNSPECIFIED", it.message)
            },
            onSuccess = { content ->
                promise.resolve(convertJsonToMap(convertKJsonToJson(Json.decodeFromString<JsonObject>(Json.encodeToString(content)))))
            }
        )
    }

    @ReactMethod
    fun subscribe() {
        DashX.subscribe()
    }

    @ReactMethod
    fun unsubscribe() {
        DashX.unsubscribe()
    }
}
