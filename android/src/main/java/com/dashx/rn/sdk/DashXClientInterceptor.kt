package com.dashx.rn.sdk

import android.content.Context
import com.dashx.sdk.DashXClient as DashX
import com.dashx.sdk.DashXLog
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter
import com.google.firebase.messaging.RemoteMessage

class DashXClientInterceptor private constructor() {
    private val tag = DashXClientInterceptor::class.java.simpleName

    private var client: com.dashx.sdk.DashXClient? = null
    var reactApplicationContext: ReactApplicationContext? = null
    private val dashXNotificationFilter = "DASHX_PN_TYPE"

    fun createDashXClient(reactApplicationContext: ReactApplicationContext, publicKey: String, baseURI: String?, targetEnvironment: String?, targetInstallation: String?) {
        this.reactApplicationContext = reactApplicationContext
        client = DashX(reactApplicationContext.applicationContext, publicKey, baseURI, targetEnvironment, targetInstallation)
    }

    fun getDashXClient(): com.dashx.sdk.DashXClient? {
        return client
    }

    fun handleMessage(remoteMessage: RemoteMessage) {
        val notificationData = remoteMessage.getData()

        DashXLog.d(tag, "Notification Data: " + notificationData)

        val eventProperties: WritableMap = Arguments.createMap()

        try {
            eventProperties.putMap("data", convertToWritableMap(notificationData, listOf(dashXNotificationFilter)))
        } catch (e: Exception) {
            e.printStackTrace()
            DashXLog.d(tag, "Encountered an error while parsing notification data.")
        }

        val notification = remoteMessage.getNotification()

        if (notification != null) {
            val notificationProperties: WritableMap = Arguments.createMap()
            notificationProperties.putString("title", notification.getTitle())
            notificationProperties.putString("body", notification.getBody())

            eventProperties.putMap("notification", notificationProperties)

            DashXLog.d(tag, "onMessageReceived with Title: " + notification.getTitle() + " and Body: " + notification.getBody())
        }

        sendJsEvent("messageReceived", eventProperties)
    }

    private fun sendJsEvent(eventName: String, params: WritableMap) {
        reactApplicationContext
            ?.getJSModule(RCTDeviceEventEmitter::class.java)
            ?.emit(eventName, params)
    }

    companion object {
        val instance: DashXClientInterceptor by lazy {
            DashXClientInterceptor()
        }
    }
}
