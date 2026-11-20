package com.dashx.rn.sdk

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap

class DashXReactNativeModule(reactContext: ReactApplicationContext) :
    NativeDashXReactNativeSpec(reactContext) {

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

    override fun configure(options: ReadableMap) = impl.configure(options)

    override fun identify(options: ReadableMap?) = impl.identify(options)

    override fun setIdentity(uid: String?, token: String?) = impl.setIdentity(uid, token)

    override fun reset() = impl.reset()

    override fun track(event: String, data: ReadableMap?) = impl.track(event, data)

    override fun screen(screenName: String, data: ReadableMap?) = impl.screen(screenName, data)

    override fun fetchRecord(urn: String, options: ReadableMap?, promise: Promise) =
        impl.fetchRecord(urn, options, promise)

    override fun searchRecords(resource: String, options: ReadableMap?, promise: Promise) =
        impl.searchRecords(resource, options, promise)

    override fun fetchStoredPreferences(promise: Promise) = impl.fetchStoredPreferences(promise)

    override fun saveStoredPreferences(preferenceData: ReadableMap?, promise: Promise) =
        impl.saveStoredPreferences(preferenceData, promise)

    override fun subscribe() = impl.subscribe()

    override fun unsubscribe(promise: Promise) = impl.unsubscribe(promise)

    override fun setLogLevel(level: Double) = impl.setLogLevel(level)

    override fun enableLifecycleTracking() = impl.enableLifecycleTracking()

    override fun enableAdTracking() = impl.enableAdTracking()

    override fun processURL(url: String, source: String?, forwardToLinkHandler: Boolean) =
        impl.processURL(url, source, forwardToLinkHandler)

    override fun trackNotificationNavigation(action: ReadableMap?, notificationId: String?) =
        impl.trackNotificationNavigation(action, notificationId)

    override fun uploadAsset(
        filePath: String,
        resource: String,
        attribute: String,
        promise: Promise
    ) = impl.uploadAsset(filePath, resource, attribute, promise)

    override fun fetchAsset(assetId: String, promise: Promise) = impl.fetchAsset(assetId, promise)

    override fun requestNotificationPermission(fallbackToSettings: Boolean, promise: Promise) =
        impl.requestNotificationPermission(fallbackToSettings, promise)

    override fun getNotificationPermissionStatus(promise: Promise) =
        impl.getNotificationPermissionStatus(promise)

    override fun chatOpenConversation(leaseId: String, chatIdentityId: String, conversationId: String) =
        impl.chatOpenConversation(leaseId, chatIdentityId, conversationId)

    override fun chatCloseConversation(leaseId: String) =
        impl.chatCloseConversation(leaseId)

    override fun chatSetConversationVisible(leaseId: String, visible: Boolean) =
        impl.chatSetConversationVisible(leaseId, visible)

    override fun chatSendMessage(leaseId: String, content: ReadableMap, promise: Promise) =
        impl.chatSendMessage(leaseId, content, promise)

    override fun chatLoadPreviousPage(leaseId: String, requestId: Double) =
        impl.chatLoadPreviousPage(leaseId, requestId)

    override fun chatFetchConversations(chatIdentityId: String, options: ReadableMap?, promise: Promise) =
        impl.chatFetchConversations(chatIdentityId, options, promise)

    override fun chatFetchConversation(chatIdentityId: String, conversationId: String, promise: Promise) =
        impl.chatFetchConversation(chatIdentityId, conversationId, promise)

    override fun chatSummarizeConversations(chatIdentityId: String, options: ReadableMap?, promise: Promise) =
        impl.chatSummarizeConversations(chatIdentityId, options, promise)

    override fun chatSummarizeUnread(chatIdentityId: String, promise: Promise) =
        impl.chatSummarizeUnread(chatIdentityId, promise)

    override fun chatResolveConversation(chatIdentityId: String, conversationId: String, promise: Promise) =
        impl.chatResolveConversation(chatIdentityId, conversationId, promise)

    override fun addListener(eventName: String) {
        // Required for RN built-in Event Emitter Calls
    }

    override fun removeListeners(count: Double) {
        // Required for RN built-in Event Emitter Calls
    }
}
