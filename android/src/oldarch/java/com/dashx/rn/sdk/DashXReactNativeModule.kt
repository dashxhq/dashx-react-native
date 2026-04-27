package com.dashx.rn.sdk

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap

class DashXReactNativeModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    private val impl = DashXReactNativeModuleImpl(reactContext)

    override fun getName(): String = DashXReactNativeModuleImpl.NAME

    override fun initialize() {
        super.initialize()
        impl.initialize()
    }

    override fun invalidate() {
        impl.invalidate()
        super.invalidate()
    }

    @ReactMethod
    fun configure(options: ReadableMap) = impl.configure(options)

    @ReactMethod
    fun identify(options: ReadableMap?) = impl.identify(options)

    @ReactMethod
    fun setIdentity(uid: String?, token: String?) = impl.setIdentity(uid, token)

    @ReactMethod
    fun reset() = impl.reset()

    @ReactMethod
    fun track(event: String, data: ReadableMap?) = impl.track(event, data)

    @ReactMethod
    fun screen(screenName: String, data: ReadableMap?) = impl.screen(screenName, data)

    @ReactMethod
    fun fetchRecord(urn: String, options: ReadableMap?, promise: Promise) =
        impl.fetchRecord(urn, options, promise)

    @ReactMethod
    fun searchRecords(resource: String, options: ReadableMap?, promise: Promise) =
        impl.searchRecords(resource, options, promise)

    @ReactMethod
    fun fetchStoredPreferences(promise: Promise) = impl.fetchStoredPreferences(promise)

    @ReactMethod
    fun saveStoredPreferences(preferenceData: ReadableMap?, promise: Promise) =
        impl.saveStoredPreferences(preferenceData, promise)

    @ReactMethod
    fun subscribe() = impl.subscribe()

    @ReactMethod
    fun unsubscribe(promise: Promise) = impl.unsubscribe(promise)

    @ReactMethod
    fun setLogLevel(level: Double) = impl.setLogLevel(level)

    @ReactMethod
    fun enableLifecycleTracking() = impl.enableLifecycleTracking()

    @ReactMethod
    fun enableAdTracking() = impl.enableAdTracking()

    @ReactMethod
    fun processURL(url: String, source: String?, forwardToLinkHandler: Boolean) =
        impl.processURL(url, source, forwardToLinkHandler)

    @ReactMethod
    fun trackNotificationNavigation(action: ReadableMap?, notificationId: String?) =
        impl.trackNotificationNavigation(action, notificationId)

    @ReactMethod
    fun uploadAsset(filePath: String, resource: String, attribute: String, promise: Promise) =
        impl.uploadAsset(filePath, resource, attribute, promise)

    @ReactMethod
    fun fetchAsset(assetId: String, promise: Promise) = impl.fetchAsset(assetId, promise)

    @ReactMethod
    fun requestNotificationPermission(promise: Promise) =
        impl.requestNotificationPermission(promise)

    @ReactMethod
    fun getNotificationPermissionStatus(promise: Promise) =
        impl.getNotificationPermissionStatus(promise)

    @ReactMethod
    fun addListener(eventName: String) {
        // Required for RN built-in Event Emitter Calls
    }

    @ReactMethod
    fun removeListeners(count: Double) {
        // Required for RN built-in Event Emitter Calls
    }
}
