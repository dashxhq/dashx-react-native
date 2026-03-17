package com.dashx.rn.sdk

import com.dashx.android.DashXFirebaseMessagingService
import com.dashx.android.DashXLog
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.google.firebase.messaging.RemoteMessage

/**
 * Extends dashx-android's FCM service to also emit "messageReceived" to the React Native JS layer
 * so that DashX.onMessageReceived() callbacks receive push notifications.
 */
class DashXReactNativeFirebaseMessagingService : DashXFirebaseMessagingService() {

    private val tag = DashXReactNativeFirebaseMessagingService::class.java.simpleName

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        // Preserve dashx-android behavior (notification display + tracking)
        super.onMessageReceived(remoteMessage)

        val context = MessageReceivedEventHolder.reactContext ?: run {
            DashXLog.d(tag, "React context not available, skipping JS emit")
            return
        }

        if (!context.hasActiveReactInstance()) {
            DashXLog.d(tag, "No active React instance, skipping JS emit")
            return
        }

        val payload = remoteMessageToWritableMap(remoteMessage)
        context.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
            .emit("messageReceived", payload)
    }

    private fun remoteMessageToWritableMap(remoteMessage: RemoteMessage): WritableMap {
        val map = Arguments.createMap()

        // Data payload (always present as Map<String, String>)
        remoteMessage.data.let { data ->
            if (!data.isNullOrEmpty()) {
                val dataMap = Arguments.createMap()
                for ((key, value) in data) {
                    dataMap.putString(key, value)
                }
                map.putMap("data", dataMap)
            }
        }

        // Notification payload (if present)
        remoteMessage.notification?.let { notification ->
            val notifMap = Arguments.createMap()
            notification.title?.let { notifMap.putString("title", it) }
            notification.body?.let { notifMap.putString("body", it) }
            notification.bodyLocalizationKey?.let { notifMap.putString("bodyLocalizationKey", it) }
            notification.titleLocalizationKey?.let { notifMap.putString("titleLocalizationKey", it) }
            notification.channelId?.let { notifMap.putString("channelId", it) }
            notification.clickAction?.let { notifMap.putString("clickAction", it) }
            notification.tag?.let { notifMap.putString("tag", it) }
            notification.imageUrl?.toString()?.let { notifMap.putString("imageUrl", it) }
            map.putMap("notification", notifMap)
        }

        remoteMessage.messageId?.let { map.putString("messageId", it) }
        remoteMessage.senderId?.let { map.putString("senderId", it) }
        remoteMessage.from?.let { map.putString("from", it) }

        return map
    }
}
