# Changelog

All notable changes to `@dashx/react-native` are documented in this file. Format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versions follow [SemVer](https://semver.org/).

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
