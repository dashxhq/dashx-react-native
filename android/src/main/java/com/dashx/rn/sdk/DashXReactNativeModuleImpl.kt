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

class DashXReactNativeModuleImpl(private val reactContext: ReactApplicationContext) {
    private val tag = DashXReactNativeModuleImpl::class.java.simpleName

    fun initialize() {
        MessageReceivedEventHolder.reactContext = reactContext
    }

    fun invalidate() {
        MessageReceivedEventHolder.reactContext = null
    }

    fun setLogLevel(level: Double) {
        val logLevel = LogLevel.values().firstOrNull { it.code == level.toInt() } ?: LogLevel.OFF
        DashXLog.setLogLevel(logLevel)
    }

    fun configure(options: ReadableMap) {
        DashX.configure(
            reactContext,
            options.getString("publicKey")!!,
            options.getStringIfPresent("baseURI"),
            options.getStringIfPresent("targetEnvironment")
        )
    }

    fun identify(options: ReadableMap?) {
        val optionsHashMap = options?.toHashMap()
            ?.filterValues { it != null }
            ?.mapValues { it.value.toString() }
        DashX.identify(optionsHashMap?.let { HashMap(it) })
    }

    fun setIdentity(uid: String?, token: String?) {
        DashX.setIdentity(uid, token)
    }

    fun reset() {
        DashX.reset()
    }

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

    fun screen(screenName: String, data: ReadableMap?) {
        val screenData = data?.toHashMap()
            ?.filterValues { it != null }
            ?.mapValues { it.value.toString() }
            ?.let { HashMap(it) }
            ?: HashMap()
        DashX.screen(screenName, screenData)
    }

    fun fetchRecord(urn: String, options: ReadableMap?, promise: Promise) {
        val preview = options?.getBooleanIfPresent("preview")
        val language = options?.getStringIfPresent("language")
        val fields = try {
            convertReadableArrayToKJsonList(options?.getArray("fields"))
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            promise.reject(E_UNSPECIFIED, "Error parsing fields: ${e.message}")
            return
        }
        val include = try {
            convertReadableArrayToKJsonList(options?.getArray("include"))
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            promise.reject(E_UNSPECIFIED, "Error parsing include: ${e.message}")
            return
        }
        val exclude = try {
            convertReadableArrayToKJsonList(options?.getArray("exclude"))
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            promise.reject(E_UNSPECIFIED, "Error parsing exclude: ${e.message}")
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
                promise.reject(E_UNSPECIFIED, it.message)
            },
            onSuccess = {
                promise.resolve(convertJsonToMap(convertKJsonToJson(it)))
            }
        )
    }

    fun searchRecords(resource: String, options: ReadableMap?, promise: Promise) {
        val jsonFilter = try {
            convertMapToJson(options?.getMap("filter"))?.let { convertJsonToKJson(it) }
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            promise.reject(E_UNSPECIFIED, "Error parsing filter: ${e.message}")
            return
        }
        val order = try {
            convertReadableArrayToKJsonList(options?.getArray("order"))
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            promise.reject(E_UNSPECIFIED, "Error parsing order: ${e.message}")
            return
        }
        val limit = options?.getIntIfPresent("limit")
        val preview = options?.getBooleanIfPresent("preview")
        val language = options?.getStringIfPresent("language")
        val fields = try {
            convertReadableArrayToKJsonList(options?.getArray("fields"))
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            promise.reject(E_UNSPECIFIED, "Error parsing fields: ${e.message}")
            return
        }
        val include = try {
            convertReadableArrayToKJsonList(options?.getArray("include"))
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            promise.reject(E_UNSPECIFIED, "Error parsing include: ${e.message}")
            return
        }
        val exclude = try {
            convertReadableArrayToKJsonList(options?.getArray("exclude"))
        } catch (e: Exception) {
            DashXLog.d(tag, e.message)
            promise.reject(E_UNSPECIFIED, "Error parsing exclude: ${e.message}")
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
                promise.reject(E_UNSPECIFIED, it.message)
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

    fun fetchStoredPreferences(promise: Promise) {
        DashX.fetchStoredPreferences(
            onError = {
                promise.reject(E_UNSPECIFIED, it.message)
            },
            onSuccess = { content ->
                promise.resolve(convertJsonToMap(convertKJsonToJson(Json.decodeFromString<JsonObject>(Json.encodeToString(content)))))
            }
        )
    }

    fun saveStoredPreferences(preferenceData: ReadableMap?, promise: Promise) {
        val preferencesString = MapUtil.toJSONElement(preferenceData).toString()

        DashX.saveStoredPreferences(
            Json.decodeFromString<JsonObject>(preferencesString),
            onError = {
                promise.reject(E_UNSPECIFIED, it.message)
            },
            onSuccess = { content ->
                promise.resolve(convertJsonToMap(convertKJsonToJson(Json.decodeFromString<JsonObject>(Json.encodeToString(content)))))
            }
        )
    }

    fun subscribe() {
        DashX.subscribe()
    }

    fun unsubscribe() {
        DashX.unsubscribe()
    }

    // --- iOS-only methods: no-op stubs on Android (JS guards prevent these from being called) ---

    fun enableLifecycleTracking() {
        // iOS-only; no-op on Android
    }

    fun enableAdTracking() {
        // iOS-only; no-op on Android
    }

    fun processURL(url: String, source: String?, forwardToLinkHandler: Boolean) {
        // iOS-only; no-op on Android
    }

    fun trackNotificationNavigation(action: ReadableMap?, notificationId: String?) {
        // iOS-only; no-op on Android
    }

    // --- Android parity gaps: reject stubs (full implementations pending in a separate PR) ---

    fun uploadAsset(filePath: String, resource: String, attribute: String, promise: Promise) {
        promise.reject(E_UNSUPPORTED, UNSUPPORTED_MESSAGE)
    }

    fun fetchAsset(assetId: String, promise: Promise) {
        promise.reject(E_UNSUPPORTED, UNSUPPORTED_MESSAGE)
    }

    fun requestNotificationPermission(promise: Promise) {
        promise.reject(E_UNSUPPORTED, UNSUPPORTED_MESSAGE)
    }

    fun getNotificationPermissionStatus(promise: Promise) {
        promise.reject(E_UNSUPPORTED, UNSUPPORTED_MESSAGE)
    }

    companion object {
        const val NAME = "DashXReactNative"
        private const val E_UNSPECIFIED = "EUNSPECIFIED"
        private const val E_UNSUPPORTED = "EUNSUPPORTED"
        private const val UNSUPPORTED_MESSAGE = "This method is not implemented on Android"
    }
}
