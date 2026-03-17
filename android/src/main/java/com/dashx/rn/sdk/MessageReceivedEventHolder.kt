package com.dashx.rn.sdk

import com.facebook.react.bridge.ReactApplicationContext

/**
 * Holds a reference to the React context so that [DashXReactNativeFirebaseMessagingService]
 * can emit "messageReceived" events to JS when FCM messages arrive.
 * Set by [DashXReactNativeModule], cleared when the module is invalidated.
 */
object MessageReceivedEventHolder {
    @Volatile
    var reactContext: ReactApplicationContext? = null
        internal set
}
