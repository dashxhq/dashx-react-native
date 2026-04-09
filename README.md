<p align="center">
    <br />
    <a href="https://dashx.com"><img src="https://raw.githubusercontent.com/dashxhq/brand-book/master/assets/logo-black-text-color-icon@2x.png" alt="DashX" height="40" /></a>
    <br />
    <br />
    <strong>Your All-in-One Product Stack</strong>
</p>

<div align="center">
  <h4>
    <a href="https://dashx.com">Website</a>
    <span> | </span>
    <a href="https://docs.dashx.com">Documentation</a>
  </h4>
</div>

<br />

# @dashx/react-native

[![npm version](https://img.shields.io/npm/v/@dashx/react-native.svg)](https://www.npmjs.com/package/@dashx/react-native)
[![license](https://img.shields.io/npm/l/@dashx/react-native.svg)](https://github.com/dashxhq/dashx-react-native/blob/main/LICENSE)
[![platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS-brightgreen.svg)](#requirements)

_DashX SDK for React Native_

## Requirements

| Platform | Minimum Version |
|----------|----------------|
| iOS | 13.0+ |
| Android | SDK 26 (Android 8.0)+ |
| React Native | 0.71+ |
| Node.js | 16.0+ |

> **Note:** This SDK uses native modules and is **not compatible with Expo Go**. Use a [development build](https://docs.expo.dev/develop/development-builds/introduction/) if you are using Expo.

## Install

```sh
npm install @dashx/react-native
```

or

```sh
yarn add @dashx/react-native
```

### Setup for Android

DashX requires Google Services for Firebase Cloud Messaging:

1. Add the `google-services` plugin in your `/android/build.gradle`:

```gradle
buildscript {
  dependencies {
    // ... other dependencies
    classpath 'com.google.gms:google-services:4.4.2'
  }
}
```

2. Apply the plugin in your `/android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'
```

3. Add your Android app on [Firebase Console](https://console.firebase.google.com/): **Project Overview > Add App > Android**

4. Download `google-services.json` and place it at `/android/app/google-services.json`

### Setup for iOS

#### Step 1: Add pods to your Podfile

The DashX iOS SDK is not published to CocoaPods trunk. Add it directly from GitHub along with the Firebase pods required for FCM push notifications.

Add `use_modular_headers!` at the top of your `ios/Podfile`, then add the pods inside the target block:

```ruby
use_modular_headers!

target 'YourApp' do
  # ... other pods

  pod 'DashX', :git => 'https://github.com/dashxhq/dashx-ios.git', :tag => '1.1.9'
  pod 'FirebaseCore'
  pod 'FirebaseMessaging'

  use_react_native!(...)
end
```

Then run:

```sh
cd ios && pod install
```

#### Step 2: Add GoogleService-Info.plist

1. Add your iOS app on [Firebase Console](https://console.firebase.google.com/): **Project Overview > Add App > iOS**
2. Download `GoogleService-Info.plist` and add it to your Xcode project (right-click project root > **Add Files to "YourApp"**, ensure **Copy items if needed** is checked)

#### Step 3: Enable Push Notifications capability

In Xcode, select your app target > **Signing & Capabilities** > **+ Capability** > add **Push Notifications**.

#### Step 4: Configure your AppDelegate

The SDK ships `DashXRCTAppDelegate` which handles permission requests, notification display, and universal link forwarding. Subclass it in your `AppDelegate.swift` and configure Firebase directly:

```swift
import DashXReactNative
import ReactAppDependencyProvider
import FirebaseCore
import FirebaseMessaging
import DashX
import UserNotifications

@main
class AppDelegate: DashXRCTAppDelegate {
  override var moduleName: String { "YourAppName" }

  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    self.dependencyProvider = RCTAppDependencyProvider()
    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Forward the APNS token to Firebase so it can exchange it for an FCM token
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
  }

  override func bundleURL() -> URL? {
    #if DEBUG
    RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
    #else
    Bundle.main.url(forResource: "main", withExtension: "jsbundle")
    #endif
  }
}

// Receive the FCM token and pass it to DashX
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    guard let token = fcmToken else { return }
    DashX.setFCMToken(to: token)
  }
}
```

`DashXRCTAppDelegate` handles the rest automatically:
- Requests notification permission on launch
- Displays notifications (banner + sound by default, even while app is in the foreground)
- Tracks delivery, clicks, and dismissals
- Forwards universal links to the JS `onLinkReceived` listener

**Override points** (all optional):

```swift
/// Control foreground notification presentation (default: [.banner, .sound])
override func notificationDeliveredInForeground(message: [AnyHashable: Any]) -> UNNotificationPresentationOptions {
  return [.banner, .sound, .badge]
}

// Called when the user taps a notification or one of its action buttons
override func notificationClicked(message: [AnyHashable: Any], actionIdentifier: String) {
  // custom tap handling
}

// Called when a universal/deep link arrives
override func handleLink(url: URL) {
  // custom link handling
}
```

#### Step 5: Subscribe in JavaScript

Call `DashX.subscribe()` at app startup so the SDK registers the device as soon as the FCM token is available:

```js
import { useEffect } from 'react';
import DashX from '@dashx/react-native';

DashX.configure({ publicKey: 'your-public-key' });

export default function App() {
  useEffect(() => {
    DashX.subscribe();
  }, []);

  // ...
}
```

> **Without Firebase:** If you are not using FCM, omit the Firebase pods and the Firebase-related `AppDelegate` code. The SDK will still handle APNS permission requests and notification display via `DashXRCTAppDelegate`.

## Usage

```js
import DashX from '@dashx/react-native';
```

### Configure

Initialize the SDK once at app startup. Call `configure` at the top level of your entry file (e.g. `App.js`) so it runs before any component mounts:

```js
// App.js — call at module level, before the component
import DashX from '@dashx/react-native';

DashX.configure({
  publicKey: 'your-public-key',
  // baseURI: 'https://api.dashx.com',       // optional, custom API endpoint
  // targetEnvironment: 'production',         // optional
});

export default function App() {
  // ...
}
```

Calling from `useEffect` in your root component also works, but module-level init is preferred so the SDK is ready as early as possible.

| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `publicKey` | `string` | Yes | Your DashX public key |
| `baseURI` | `string` | No | Custom API base URI |
| `targetEnvironment` | `string` | No | Target environment name |

### Identify a user

```js
DashX.identify({
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com',
});
```

### Set identity with token

```js
DashX.setIdentity('user-uid', 'user-token');
```

### Reset

Clear the current identity:

```js
DashX.reset();
```

### Track events

```js
DashX.track('Item Purchased', {
  itemId: 'sku-123',
  price: 9.99,
});
```

### Track screen views

```js
DashX.screen('HomeScreen', {
  referrer: 'DeepLink',
});
```

### Fetch a record

Fetch a single record by URN (e.g. `"article/uuid"`). The URN must use the full UUID form of the record ID.

```js
const record = await DashX.fetchRecord('article/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx', {
  preview: false,
  language: 'en',
  // fields, include, exclude as arrays of objects if needed
});
```

| Option | Type | Description |
|--------|------|-------------|
| `preview` | `boolean` | Include draft/preview content |
| `language` | `string` | Content language |
| `fields` | `object[]` | Fields to return |
| `include` | `object[]` | Related data to include |
| `exclude` | `object[]` | Fields to exclude |

### Search records

```js
const records = await DashX.searchRecords('article', {
  filter: { status: 'published' },
  order: [{ field: 'createdAt', direction: 'desc' }],
  limit: 10,
  page: 1,
  preview: false,
  language: 'en',
});
```

| Option | Type | Description |
|--------|------|-------------|
| `filter` | `object` | Filter criteria |
| `order` | `object[]` | Sort order (e.g. `[{ field, direction }]`) |
| `limit` | `number` | Max records to return |
| `page` | `number` | Page number for pagination |
| `preview` | `boolean` | Preview/draft content |
| `language` | `string` | Content language |
| `fields` | `object[]` | Fields to return |
| `include` | `object[]` | Related data to include |
| `exclude` | `object[]` | Fields to exclude |

### Push notifications

Subscribe the current device to push notifications:

```js
DashX.subscribe();
```

Unsubscribe:

```js
DashX.unsubscribe();
```

### Request notification permission (iOS)

Prompt the user for push notification permission. Returns a `NotificationPermissionStatus` integer matching `UNAuthorizationStatus`:

| Value | Meaning |
|-------|---------|
| `0` | Not determined |
| `1` | Denied |
| `2` | Authorized |
| `3` | Provisional |
| `4` | Ephemeral |

```js
const status = await DashX.requestNotificationPermission();
if (status === 2) {
  DashX.subscribe();
}
```

To check the current status without prompting the user:

```js
const status = await DashX.getNotificationPermissionStatus();
```

### Listen for incoming messages

Register a listener to handle push notifications when they arrive:

```js
import { useEffect } from 'react';

useEffect(() => {
  const subscription = DashX.onMessageReceived((message) => {
    console.log('Notification received:', message);
  });

  return () => subscription.remove();
}, []);
```

### Listen for deep links / universal links (iOS)

Register a listener that fires when the SDK receives a universal link. On the native side, `DashXRCTAppDelegate` forwards links via `DashX.handleUserActivity` automatically.

```js
useEffect(() => {
  const subscription = DashX.onLinkReceived((url) => {
    console.log('Link received:', url);
  });

  return () => subscription.remove();
}, []);
```

### Notification preferences

Fetch the user's stored notification preferences:

```js
const preferences = await DashX.fetchStoredPreferences();
```

Save updated preferences:

```js
await DashX.saveStoredPreferences({
  marketing_emails: true,
  product_updates: false,
});
```

### Upload an asset (iOS)

Upload a local file to DashX and associate it with a resource and attribute:

```js
const response = await DashX.uploadAsset(
  '/path/to/local/file.jpg',
  'user',       // resource name
  'avatar'      // attribute name
);
// response: { status, data: { asset: { status, url, playbackIds } } }
```

### Fetch an asset (iOS)

Retrieve the status and URL of a previously uploaded asset by its ID:

```js
const asset = await DashX.fetchAsset('asset-id');
// asset: { status, data: { asset: { status, url, playbackIds } } }
```

### Lifecycle tracking (iOS)

Enable automatic app lifecycle event tracking (app opened, backgrounded, etc.):

```js
DashX.enableLifecycleTracking(); // no-op on Android
```

### Ad tracking / ATT (iOS)

Request App Tracking Transparency permission and enable IDFA tracking:

```js
DashX.enableAdTracking(); // no-op on Android
```

Make sure `NSUserTrackingUsageDescription` is set in your `Info.plist`.

### Logging

Set the SDK log level for debugging:

```js
DashX.setLogLevel(1); // 0 = off, 1 = errors, 2 = debug
```

## API Reference

| Method | Signature | Platforms | Returns | Description |
|--------|-----------|-----------|---------|-------------|
| `configure` | `(options: object)` | iOS, Android | `void` | Initialize the SDK with your public key |
| `identify` | `(options: object)` | iOS, Android | `void` | Identify the current user with traits |
| `setIdentity` | `(uid: string, token: string)` | iOS, Android | `void` | Set user identity with UID and auth token |
| `reset` | `()` | iOS, Android | `void` | Clear the current user identity |
| `track` | `(event: string, data?: object)` | iOS, Android | `void` | Track a named event with optional data |
| `screen` | `(screenName: string, data?: object)` | iOS, Android | `void` | Track a screen view |
| `fetchRecord` | `(urn: string, options?: object)` | iOS, Android | `Promise<object>` | Fetch a single record by URN (`"resource/uuid"`) |
| `searchRecords` | `(resource: string, options?: object)` | iOS, Android | `Promise<object[]>` | Search records with filter, order, limit, page, etc. |
| `subscribe` | `()` | iOS, Android | `void` | Subscribe device for push notifications |
| `unsubscribe` | `()` | iOS, Android | `void` | Unsubscribe device from push notifications |
| `fetchStoredPreferences` | `()` | iOS, Android | `Promise<object>` | Fetch stored notification preferences |
| `saveStoredPreferences` | `(data: object)` | iOS, Android | `Promise<object>` | Save notification preferences |
| `setLogLevel` | `(level: number)` | iOS, Android | `void` | Set SDK log verbosity (0=off, 1=errors, 2=debug) |
| `onMessageReceived` | `(callback: function)` | iOS, Android | `EmitterSubscription` | Listen for incoming push notifications |
| `requestNotificationPermission` | `()` | iOS | `Promise<number>` | Prompt for push permission; resolves with `UNAuthorizationStatus` (0-4) |
| `getNotificationPermissionStatus` | `()` | iOS | `Promise<number>` | Get current push permission status without prompting |
| `onLinkReceived` | `(callback: function)` | iOS | `EmitterSubscription` | Listen for universal/deep link events |
| `uploadAsset` | `(filePath: string, resource: string, attribute: string)` | iOS | `Promise<AssetResponse>` | Upload a local file and associate it with a resource attribute |
| `fetchAsset` | `(assetId: string)` | iOS | `Promise<AssetResponse>` | Fetch status and URL of an uploaded asset |
| `enableLifecycleTracking` | `()` | iOS | `void` | Enable automatic app lifecycle event tracking |
| `enableAdTracking` | `()` | iOS | `void` | Request ATT permission and enable IDFA tracking |

For detailed usage and advanced features, refer to the [DashX documentation](https://docs.dashx.com).

### Error Codes

Promise rejections from native methods use a consistent error code across both platforms:

| Code | Description |
|------|-------------|
| `EUNSPECIFIED` | An unspecified error occurred |

The error code is available on the `code` property of the rejected error:

```js
try {
  await DashX.fetchRecord('article/123');
} catch (error) {
  console.log(error.code);    // "EUNSPECIFIED"
  console.log(error.message); // human-readable description
}
```

A `DashXErrorCode` enum is exported from the TypeScript definitions for type-safe comparisons.

## Contributing

Please follow [these steps](https://github.com/dashxhq/dashx-js/tree/master/examples/react-native#setting-up-development-environment) to set up the development environment.

You'll also need Apollo CLI to generate files:

```sh
npm i -g apollo
```

## Publishing

Use `yarn publish` to bump the version and release, then push the commit:

```sh
yarn publish
git push origin main
```

## License

MIT
