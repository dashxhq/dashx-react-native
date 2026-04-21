package com.dashx.rn.sdk

import com.dashx.android.DashXNotificationListener
import com.dashx.android.DashXPayload
import com.dashx.android.NavigationAction
import com.dashx.rn.sdk.util.convertJsonToMap
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.encodeToJsonElement
import kotlinx.serialization.json.jsonObject

/**
 * Bridges the dashx-android SDK's [DashXNotificationListener.onNotificationClicked]
 * hook to the JS-side `DashX.onNotificationClicked(...)` listener registered via
 * `NativeEventEmitter`. Mirrors the iOS emit shape from
 * `ios/DashXNotificationHandler.swift` → `handleNotificationResponse`:
 *
 * ```json
 * {
 *   "notification":      { ...DashX payload keys... },
 *   "action":            { "type": "deepLink" | "screen" | ..., ... } | null,
 *   "actionIdentifier":  "<string, or empty>"
 * }
 * ```
 *
 * Registered from [DashXReactNativeModuleImpl.initialize] via
 * [DashX.registerNotificationListener], and unregistered in [invalidate].
 *
 * Returns `false` from [onNotificationClicked] so the SDK proceeds with its
 * default navigation (deep-link intent, rich-landing browser, click-action
 * intent). Consumers who want to override need to do so in JS — the
 * JS-side listener has no way to suppress the native default via a return
 * value, which matches iOS behavior.
 *
 * `actionIdentifier` is `null` when the notification body was tapped, or the
 * tapped action button's identifier (matches `ActionButton.identifier`) for
 * button taps. We emit an empty string in the body-tap case so the JS event
 * always carries a String — matches the iOS event shape, where the field is
 * always present.
 */
class DashXNotificationClickedListener(
    private val reactContext: ReactApplicationContext
) : DashXNotificationListener {

    override fun onNotificationClicked(
        payload: DashXPayload,
        action: NavigationAction?,
        actionIdentifier: String?
    ): Boolean {
        if (!reactContext.hasActiveReactInstance()) {
            // RN is still booting (common on cold-start from a killed-app
            // notification tap). The JS emit would be dropped anyway; skip.
            return false
        }

        val body: WritableMap = Arguments.createMap().apply {
            putMap("notification", payloadToMap(payload))
            if (action != null) {
                putMap("action", actionToMap(action))
            } else {
                putNull("action")
            }
            putString("actionIdentifier", actionIdentifier ?: "")
        }

        reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
            .emit("notificationClicked", body)

        return false
    }

    private fun payloadToMap(payload: DashXPayload): WritableMap {
        // DashXPayload is `@Serializable` — go straight to a JsonObject tree
        // and hand it to the shared `convertJsonToMap` helper for a
        // RN-bridge-safe `WritableMap`. No Gson / no string round-trip.
        val jsonObject = Json.encodeToJsonElement(DashXPayload.serializer(), payload).jsonObject
        return convertJsonToMap(jsonObject) ?: Arguments.createMap()
    }

    private fun actionToMap(action: NavigationAction): WritableMap {
        val map = Arguments.createMap()
        when (action) {
            is NavigationAction.DeepLink -> {
                map.putString("type", "deepLink")
                map.putString("url", action.url)
            }
            is NavigationAction.Screen -> {
                map.putString("type", "screen")
                map.putString("name", action.name)
                action.data?.let { data ->
                    val dataMap = Arguments.createMap()
                    for ((key, value) in data) {
                        dataMap.putString(key, value)
                    }
                    map.putMap("data", dataMap)
                }
            }
            is NavigationAction.RichLanding -> {
                map.putString("type", "richLanding")
                map.putString("url", action.url)
            }
            is NavigationAction.ClickAction -> {
                map.putString("type", "clickAction")
                map.putString("action", action.action)
            }
        }
        return map
    }
}
