package com.dashx.rn.sdk

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

    override fun initialize() {
        super.initialize()
        MessageReceivedEventHolder.reactContext = reactContext
    }

    override fun invalidate() {
        MessageReceivedEventHolder.reactContext = null
        super.invalidate()
    }

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
            ?.filterValues { it != null }
            ?.mapValues { it.value.toString() }
        DashX.identify(optionsHashMap?.let { HashMap(it) })
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
            data?.toHashMap()
                ?.filterValues { it != null }
                ?.mapValues { it.value.toString() }
                ?.let { HashMap(it) }
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            return
        }

        DashX.track(event, jsonData)
    }

    @ReactMethod
    fun screen(screenName: String, data: ReadableMap?) {
        val screenData = data?.toHashMap()
            ?.filterValues { it != null }
            ?.mapValues { it.value.toString() }
            ?.let { HashMap(it) }
            ?: HashMap()
        DashX.screen(screenName, screenData)
    }

    @ReactMethod
    fun fetchRecord(urn: String, options: ReadableMap?, promise: Promise) {
        val preview = options?.getBooleanIfPresent("preview")
        val language = options?.getStringIfPresent("language")
        val fields = try {
            convertReadableArrayToKJsonList(options?.getArray("fields"))
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            promise.reject("EUNSPECIFIED", "Error parsing fields: ${e.message}")
            return
        }
        val include = try {
            convertReadableArrayToKJsonList(options?.getArray("include"))
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            promise.reject("EUNSPECIFIED", "Error parsing include: ${e.message}")
            return
        }
        val exclude = try {
            convertReadableArrayToKJsonList(options?.getArray("exclude"))
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            promise.reject("EUNSPECIFIED", "Error parsing exclude: ${e.message}")
            return
        }

        DashX.fetchRecord(
            urn = urn,
            preview = preview,
            language = language,
            fields = fields,
            include = include,
            exclude = exclude,
            onError = {
                promise.reject("EUNSPECIFIED", it.message)
            },
            onSuccess = {
                promise.resolve(convertJsonToMap(convertKJsonToJson(it)))
            }
        )
    }

    @ReactMethod
    fun searchRecords(resource: String, options: ReadableMap?, promise: Promise) {
        val jsonFilter = try {
            convertMapToJson(options?.getMap("filter"))?.let { convertJsonToKJson(it) }
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            promise.reject("EUNSPECIFIED", "Error parsing filter: ${e.message}")
            return
        }
        val order = try {
            convertReadableArrayToKJsonList(options?.getArray("order"))
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            promise.reject("EUNSPECIFIED", "Error parsing order: ${e.message}")
            return
        }
        val limit = options?.getIntIfPresent("limit")
        val preview = options?.getBooleanIfPresent("preview")
        val language = options?.getStringIfPresent("language")
        val fields = try {
            convertReadableArrayToKJsonList(options?.getArray("fields"))
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            promise.reject("EUNSPECIFIED", "Error parsing fields: ${e.message}")
            return
        }
        val include = try {
            convertReadableArrayToKJsonList(options?.getArray("include"))
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            promise.reject("EUNSPECIFIED", "Error parsing include: ${e.message}")
            return
        }
        val exclude = try {
            convertReadableArrayToKJsonList(options?.getArray("exclude"))
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            promise.reject("EUNSPECIFIED", "Error parsing exclude: ${e.message}")
            return
        }

        DashX.searchRecords(
            resource = resource,
            filter = jsonFilter,
            order = order,
            limit = limit,
            preview = preview,
            language = language,
            fields = fields,
            include = include,
            exclude = exclude,
            onError = {
                promise.reject("EUNSPECIFIED", it.message)
            },
            onSuccess = { records ->
                val readableArray = Arguments.createArray()
                records.forEach {
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
