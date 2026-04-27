# Contributing to @dashx/react-native

## Prerequisites

- Node.js >= 16
- Yarn
- Xcode (for iOS)
- Android Studio with JDK 17 (for Android)
- CocoaPods (`gem install cocoapods`)

## Getting Started

1. Clone the repository:

```sh
git clone https://github.com/dashxhq/dashx-react-native.git
cd dashx-react-native
```

2. Install dependencies:

```sh
yarn install
```

3. Run tests:

```sh
yarn test
```

4. Run lint:

```sh
yarn lint
```

## Building the SDK Locally

### Android

The Android bridge lives in `android/` and is a Gradle library module that is built as part of a React Native app — it cannot be built standalone because it depends on the React Native Gradle plugin and Android SDK provided by the host app.

To build and test locally, use a React Native demo app (e.g. `dashx-demo-react-native`):

1. In the demo app's `package.json`, point to your local SDK checkout:

```json
"dependencies": {
  "@dashx/react-native": "file:../dashx-react-native"
}
```

2. Install and build:

```sh
cd dashx-demo-react-native
yarn install
cd android
./gradlew assembleDebug
```

3. **To test with a local `dashx-android` SDK build**, publish it to local Maven and add `mavenLocal()` to the demo app's `android/build.gradle` repositories:

```sh
# In dashx-android:
./gradlew publishToMavenLocal

# In dashx-react-native/android/build.gradle, add:
repositories {
    mavenLocal()
    // ...
}
```

### iOS

The iOS bridge lives in `ios/` and is distributed as a CocoaPod (`DashXReactNative.podspec`). Like Android, it is built as part of a React Native app's Xcode workspace.

To build and test locally, use a React Native demo app (e.g. `dashx-demo-react-native`):

1. In the demo app's `package.json`, point to your local SDK checkout:

```json
"dependencies": {
  "@dashx/react-native": "file:../dashx-react-native"
}
```

2. Install dependencies and pods:

```sh
cd dashx-demo-react-native
yarn install
cd ios
pod install
```

3. Build from Xcode by opening the `.xcworkspace`, or from the command line:

```sh
xcodebuild -workspace ios/DashXDemoReactNative.xcworkspace \
  -scheme DashXDemoReactNative \
  -destination 'generic/platform=iOS Simulator' \
  build
```

4. **To test with a local `dashx-ios` SDK build**, add a path override in the demo app's `Podfile`:

```ruby
pod 'DashX', :path => '../../dashx-ios'
```

Then re-run `pod install`.

## Project Structure

```
dashx-react-native/
  index.js              # JS bridge — public API surface
  index.d.ts            # TypeScript type definitions
  android/
    src/main/java/com/dashx/rn/sdk/
      DashXReactNativeModule.kt   # Android native module
      DashXReactNativePackage.kt  # Package registration
      DashXReactNativeFirebaseMessagingService.kt  # FCM service
      util/                       # Bridge conversion utilities
    build.gradle                  # Android build config
  ios/
    DashXReactNative.swift        # iOS native module — SOURCE OF TRUTH for bridge methods
    DashXReactNative.mm           # Obj-C++ bridge exports — AUTO-GENERATED, see below
    DashXEventEmitter.swift       # Event emitter for push notifications
    DashXRCTAppDelegate.swift     # AppDelegate with Firebase/push handling
  scripts/
    generate-bridge-shim.js       # Regenerates DashXReactNative.mm from the Swift @objc decls
  DashXReactNative.podspec        # CocoaPods spec
  __tests__/                      # Jest tests
```

## iOS bridge: editing methods

`ios/DashXReactNative.mm` is **auto-generated** from `ios/DashXReactNative.swift`.
Don't hand-edit it — your changes will be overwritten on the next regen, and CI
will fail anyway because the committed `.mm` won't match what the script
produces.

Workflow when adding or changing a bridged method:

1. Edit `ios/DashXReactNative.swift`. Each bridged method needs an `@objc`
   decoration. Multi-arg methods use the explicit form
   `@objc(methodName:label1:label2:)`; zero-arg methods use bare `@objc`.
2. Run the regen:
   ```sh
   yarn sync-bridge-shim
   ```
3. Commit both the Swift change AND the regenerated `ios/DashXReactNative.mm`
   in the same PR.

CI verification: `yarn lint` chains `yarn check-bridge-shim`, which re-runs
the generator and fails on a non-empty `git diff` against the committed
`.mm`. So a forgotten `sync-bridge-shim` step is caught at PR time, not in
production.

Why the `.mm` exists at all: React Native's iOS bridge requires every Swift
method to be declared in BOTH the Swift `@objc` form (for runtime dispatch)
AND in `RCT_EXTERN_METHOD(...)` form in an Obj-C++ shim (for old-arch
consumers' bridge module registration + new-arch compile-time selector
verification). The script makes the Swift declarations the single source of
truth and emits the matching shim mechanically.

If the script ever fails with `unknown Swift parameter type "..."`, add a
mapping for that type in `scripts/generate-bridge-shim.js`'s
`SWIFT_TO_OBJC` table (one line, then re-run).

## Running Tests

```sh
yarn test
```

Tests mock the React Native native modules and verify the JS bridge layer: input validation, native method delegation, promise handling, and event listener registration.

## Publishing

Use `yarn publish` to bump the version and release to npm:

```sh
yarn publish
git push origin main
```
