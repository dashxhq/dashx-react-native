# Changelog

All notable changes to `@dashx/react-native` are documented in this file. Format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versions follow [SemVer](https://semver.org/).

## [1.4.0] — 2026-04-27

### Changed

- **`DashX.unsubscribe()` now returns `Promise<{ success: boolean }>`** (was `void`). Matches `@dashx/browser`'s shape exactly — apps using a Metro `.web.ts` resolver can now share a single typed callsite across web and native.

  **Migration**

  Most existing call sites continue to work unchanged:

  ```ts
  DashX.unsubscribe()                          // ✓ fire-and-forget still works
  await DashX.unsubscribe()                    // ✓ still works (return value just unused)
  const { success } = await DashX.unsubscribe()  // new capability
  ```

  Two situations to watch for after upgrading:

  - **Unhandled-rejection warnings.** Previously the native module surfaced errors only in its own logs; the JS API was silent. Now JS-side promise rejections fire on SDK-state problems (Firebase Messaging dependency missing, `configure()` not yet called) and transport failures (Firebase `deleteToken` failure, GraphQL / network errors). If you never caught errors before because there was nothing to catch, a fire-and-forget `DashX.unsubscribe()` may now surface "Possible Unhandled Promise Rejection" warnings in your console. Wrap with `.catch(...)` or `try / await` if those warnings are noisy.
  - **TypeScript `: void` annotations.** `const x: void = DashX.unsubscribe()` no longer compiles. Vanishingly rare in practice but worth a grep.

  **What the resolved value means**

  - **`success: true`** — backend found and unsubscribed a matching contact.
  - **`success: false`** — non-error outcome meaning "no matching contact found"; typically the anonymous UID rotated since subscribe, the FCM token is stale, the contact is already unsubscribed, or `unsubscribe()` was called on a device that never subscribed in this session. The device ends up unsubscribed in either case; the boolean is useful for diagnostics and analytics.
  - **Promise rejection** — distinct from `success: false` so callers can branch on SDK-misuse vs legitimate no-match.

- **Native pin bumps to pick up the underlying schema change:**
  - `android/build.gradle` → `com.dashx:dashx-android` `1.2.7` → `1.2.8`. The bridge now passes `onSuccess` / `onError(DashXError)` callbacks to the native `DashX.unsubscribe(...)` and resolves/rejects the JS promise accordingly.
  - iOS pod consumers should bump `pod 'DashX/SDK'` to `:tag => '1.5.0'` in their Podfile. The bridge now calls `DashX.unsubscribe { result in ... }` and resolves/rejects the JS promise from the `Result<Bool, Error>` completion.

## [1.3.2] — 2026-04-22

### Added
- **`DashX.onPushNotificationReceived(callback)`** — new name for registering a foreground push listener. Same signature, same subscription shape; matches the `@dashx/browser` API so cross-platform apps using a Metro `.web.ts` wrapper can share the callsite.

### Deprecated
- **`DashX.onMessageReceived(callback)`** is now a deprecated alias of `onPushNotificationReceived` and logs a one-time `console.warn` on first call. The name leaked up from Android's Firebase `FirebaseMessagingService.onMessageReceived` override and was ambiguous in the DashX domain ("message" overloaded with `trackMessage` and in-app notifications). Scheduled for removal in the next major version.

## [1.3.1] — 2026-04-21

### Added
- **`DashX.onNotificationClicked` now fires on Android.** Previously only wired on iOS — the Android bridge didn't register a `DashXNotificationListener` with the SDK, so JS listeners never received tap events. The bridge now registers a listener in `DashXReactNativeModuleImpl.initialize()` and emits a `notificationClicked` event matching the iOS shape: `{ notification, action, actionIdentifier }`. `actionIdentifier` is the tapped button's identifier (body tap → empty string, matching iOS's always-a-string contract).
- Android JVM unit tests for the kotlinx-serialization conversion helpers (`Utils.kt`) — 16 tests covering all primitive types, nested objects/arrays, null handling, round-trips, and regression cases for the two pre-migration crash paths. Runs as a dedicated `android-test` CI job on PRs to `develop` and pushes to `main`.

### Changed
- **Android JSON handling consolidated on kotlinx-serialization.** Removed the Gson dependency and the `org.json`-shaped helpers (`MapUtil.java`, `ArrayUtil.java`), rewrote `Utils.kt` to use kotlinx `JsonObject` / `JsonArray` end-to-end. Matches how dashx-android itself serializes (its Apollo scalar mapping is `kotlinx.serialization.json.JsonObject`), eliminates the string round-trips the previous cross-library code was doing, and removes a class of bugs where three JSON libraries coexisted. Internal helper signatures changed (`convertMapToJson` now returns `JsonObject?`, `convertJsonToMap` now takes `JsonObject?`); consumer JS API is unchanged.
- `android/build.gradle` dep on `com.dashx:dashx-android` bumped `1.2.6` → `1.2.7` to receive the new 3-arg `onNotificationClicked(payload, action, actionIdentifier)` listener overload.

### Fixed
- `uploadAsset` / `fetchAsset` on Android previously failed to compile against `@dashx/react-native` due to a type mismatch in the TurboModule-migration callsite (`org.json.JSONObject` passed to a Gson `JsonObject`-typed helper, introduced in 1.2.0's TurboModule PR and never caught because no Android consumer had built the bridge since). Fixed by the Gson → kotlinx migration described above.

## [1.3.0] — 2026-04-20

### Breaking
- **`DashX` pod → `DashX/SDK`.** The podspec now depends on the `DashX/SDK` subspec of [dashx-ios 1.4.0+](https://github.com/dashxhq/dashx-ios) with no version constraint. Consumers must update their Podfile:
  ```ruby
  # before
  pod 'DashX', :git => 'https://github.com/dashxhq/dashx-ios.git', :tag => '1.1.9'

  # after
  pod 'DashX/SDK', :git => 'https://github.com/dashxhq/dashx-ios.git', :tag => '1.4.0'
  ```
- **`FirebaseMessaging` is now a hard dependency.** Previously the bridge guarded Firebase usage with `#if canImport(FirebaseMessaging)`, but `canImport` doesn't see consumer-Podfile pods at this pod's compile time, so the guard silently elided every FCM code path — push registration stopped working on fresh installs. Consumers must enable modular headers in their Podfile:
  ```ruby
  use_modular_headers!
  # or, per-pod:
  pod 'FirebaseMessaging', :modular_headers => true
  ```

### Added
- `DashX.onNotificationClicked(callback)` — fires when the user taps a DashX notification or one of its action buttons. Callback receives `{ notification, action, actionIdentifier }` where `action` is a resolved `NavigationAction` (`deepLink` / `screen` / `richLanding` / `clickAction`) or `null`.
- `DashXNotificationResponseResult.navigationAction` — new Swift-only field on the helper result type returned by `DashXNotificationHandler.handleNotificationResponse(_:)`.
- `NotificationClickedEvent` exported from `index.d.ts`.

### Fixed
- **iOS dev builds silently failing to receive pushes.** `Messaging.messaging().setAPNSToken(_, type: .unknown)` sometimes mis-tagged the APNs environment on dev-signed binaries, producing an FCM token whose pushes 410'd at Apple. The bridge now forces `.sandbox` in `DEBUG` configurations and `.prod` otherwise.
- **`DashX.setIdentity(uid, token)` now passes `null` / `""` / `undefined` through to the native SDK unchanged** (apart from normalizing `undefined → null`, since the RN bridge can't carry `undefined`). Previously the JS wrapper threw on `null` / `""` / `undefined` for `uid`, contradicting the nullable signatures on iOS (`NSString?`) and Android (`String?`). TypeScript signature updated: `setIdentity(uid: string | null, token?: string | null): void`.

## [1.2.0] — 2026-04-16

Previous release — see git log.
