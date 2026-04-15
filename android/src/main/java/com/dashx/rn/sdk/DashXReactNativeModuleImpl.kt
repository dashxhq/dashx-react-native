package com.dashx.rn.sdk

import android.Manifest
import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.dashx.rn.sdk.util.*
import com.dashx.android.DashX
import com.dashx.android.DashXLog
import com.dashx.android.DashXLog.LogLevel
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.PermissionAwareActivity
import com.facebook.react.modules.core.PermissionListener
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
        createDefaultNotificationChannel()
        DashX.configure(
            reactContext,
            options.getString("publicKey")!!,
            options.getStringIfPresent("baseURI"),
            options.getStringIfPresent("targetEnvironment")
        )
    }

    private fun createDefaultNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val notificationManager = reactContext.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return

        val existing = notificationManager.getNotificationChannel(DEFAULT_CHANNEL_ID)
        if (existing != null && existing.importance >= NotificationManager.IMPORTANCE_HIGH) return
        if (existing != null) {
            notificationManager.deleteNotificationChannel(DEFAULT_CHANNEL_ID)
        }

        val channel = NotificationChannel(
            DEFAULT_CHANNEL_ID,
            DEFAULT_CHANNEL_NAME,
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            enableVibration(true)
            setShowBadge(true)
            lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
        }
        notificationManager.createNotificationChannel(channel)
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
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            promise.resolve(PERMISSION_AUTHORIZED)
            return
        }

        val alreadyGranted = ContextCompat.checkSelfPermission(
            reactContext,
            Manifest.permission.POST_NOTIFICATIONS
        ) == PackageManager.PERMISSION_GRANTED
        if (alreadyGranted) {
            promise.resolve(PERMISSION_AUTHORIZED)
            return
        }

        val activity = reactContext.currentActivity as? PermissionAwareActivity
        if (activity == null) {
            promise.reject(E_UNSPECIFIED, "No current activity to request permission from")
            return
        }

        val listener = PermissionListener { requestCode, _, grantResults ->
            if (requestCode != NOTIFICATION_PERMISSION_REQUEST_CODE) return@PermissionListener false
            val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            promise.resolve(if (granted) PERMISSION_AUTHORIZED else PERMISSION_DENIED)
            true
        }

        activity.requestPermissions(
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            NOTIFICATION_PERMISSION_REQUEST_CODE,
            listener
        )
    }

    fun getNotificationPermissionStatus(promise: Promise) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            promise.resolve(PERMISSION_AUTHORIZED)
            return
        }
        val granted = ContextCompat.checkSelfPermission(
            reactContext,
            Manifest.permission.POST_NOTIFICATIONS
        ) == PackageManager.PERMISSION_GRANTED
        promise.resolve(if (granted) PERMISSION_AUTHORIZED else PERMISSION_NOT_DETERMINED)
    }

    companion object {
        const val NAME = "DashXReactNative"
        private const val E_UNSPECIFIED = "EUNSPECIFIED"
        private const val E_UNSUPPORTED = "EUNSUPPORTED"
        private const val UNSUPPORTED_MESSAGE = "This method is not implemented on Android"

        private const val DEFAULT_CHANNEL_ID = "default_dashx_notification_channel"
        private const val DEFAULT_CHANNEL_NAME = "Notifications"

        private const val NOTIFICATION_PERMISSION_REQUEST_CODE = 3571

        // Mirrors iOS UNAuthorizationStatus values used by the JS layer.
        private const val PERMISSION_NOT_DETERMINED = 0
        private const val PERMISSION_DENIED = 1
        private const val PERMISSION_AUTHORIZED = 2
    }
}
