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
    <a href="https://dashxdemo.com">Demos</a>
    <span> | </span>
    <a href="https://docs.dashx.com/developer">Documentation</a>
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
| iOS | 12.0+ |
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

1. Add Firebase pods to your `Podfile`:

```ruby
pod 'FirebaseMessaging', :modular_headers => true
```

2. Run pod install:

```sh
cd ios && pod install
```

3. Add your iOS app on [Firebase Console](https://console.firebase.google.com/): **Project Overview > Add App > iOS**

4. Download `GoogleService-Info.plist` and add it to your Xcode project (right-click project > **Add Files**, ensure **Copy items if needed** is checked).

#### Option A: Using `DashXRCTAppDelegate` (Recommended)

The SDK ships a `DashXRCTAppDelegate` class that handles Firebase configuration, FCM token management, and push notification display out of the box. Subclass it in your `AppDelegate`:

```swift
import DashXReactNative

@main
class AppDelegate: DashXRCTAppDelegate {
  override func sourceURL(for bridge: RCTBridge) -> URL? {
    bundleURL()
  }

  override func bundleURL() -> URL? {
    #if DEBUG
    RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
    #else
    Bundle.main.url(forResource: "main", withExtension: "jsbundle")
    #endif
  }

  // Called when a notification is tapped
  override func notificationClicked(message: [AnyHashable: Any], actionIdentifier: String) {
    // Handle notification tap
  }

  // Called when a notification arrives while the app is in the foreground
  override func notificationDeliveredInForeground(message: [AnyHashable: Any]) -> UNNotificationPresentationOptions {
    return [.banner, .sound]
  }
}
```

#### Option B: Manual setup in AppDelegate

If you prefer manual control, import Firebase at the top of `/ios/{projectName}/AppDelegate.m`:

```objective-c
#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseMessaging/FirebaseMessaging.h>
```

Then inside `didFinishLaunchingWithOptions`:

```objective-c
[UNUserNotificationCenter currentNotificationCenter].delegate = self;
UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
[[UNUserNotificationCenter currentNotificationCenter]
    requestAuthorizationWithOptions:authOptions
    completionHandler:^(BOOL granted, NSError * _Nullable error) {
}];

[application registerForRemoteNotifications];

if ([FIRApp defaultApp] == nil) {
  [FIRApp configure];
}

[FIRMessaging messaging].delegate = self;
```

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

### Push notifications

Subscribe the current device to push notifications:

```js
DashX.subscribe();
```

Unsubscribe:

```js
DashX.unsubscribe();
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

### Notification preferences

Fetch the user's stored notification preferences:

```js
const preferences = await DashX.fetchStoredPreferences();
console.log(preferences);
```

Save updated preferences:

```js
await DashX.saveStoredPreferences({
  marketing_emails: true,
  product_updates: false,
});
```

### Logging

Set the SDK log level for debugging:

```js
DashX.setLogLevel(1); // 0 = off, 1 = errors, 2 = debug
```

### Android example

Below is a full example of integrating DashX in a React Native Android app:

```js
// App.js
import React from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import DashX from '@dashx/react-native';

// Initialize once at app load
DashX.configure({ publicKey: 'your-public-key' });
DashX.subscribe();

export default function App() {
  const handleLogin = () => {
    DashX.setIdentity('user-123', 'auth-token');
    DashX.identify({
      firstName: 'Jane',
      lastName: 'Doe',
      email: 'jane@example.com',
    });
  };

  const handleTrack = () => {
    DashX.track('Button Pressed', { screen: 'Home' });
  };

  const handleLogout = () => {
    DashX.unsubscribe();
    DashX.reset();
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>DashX React Native Demo</Text>
      <Button title="Login" onPress={handleLogin} />
      <Button title="Track Event" onPress={handleTrack} />
      <Button title="Logout" onPress={handleLogout} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  title: { fontSize: 24, marginBottom: 20 },
});
```

## API Reference

| Method | Signature | Returns | Description |
|--------|-----------|---------|-------------|
| `configure` | `(options: object)` | `void` | Initialize the SDK with your public key |
| `identify` | `(options: object)` | `void` | Identify the current user with traits |
| `setIdentity` | `(uid: string, token: string)` | `void` | Set user identity with UID and auth token |
| `reset` | `()` | `void` | Clear the current user identity |
| `track` | `(event: string, data?: object)` | `void` | Track a named event with optional data |
| `screen` | `(screenName: string, data?: object)` | `void` | Track a screen view with optional data |
| `subscribe` | `()` | `void` | Subscribe device for push notifications |
| `unsubscribe` | `()` | `void` | Unsubscribe device from push notifications |
| `fetchStoredPreferences` | `()` | `Promise<object>` | Fetch stored notification preferences |
| `saveStoredPreferences` | `(data: object)` | `Promise<object>` | Save notification preferences |
| `setLogLevel` | `(level: number)` | `void` | Set SDK log verbosity |
| `onMessageReceived` | `(callback: function)` | `EmitterSubscription` | Listen for incoming push notifications |

For detailed usage and advanced features, refer to the [DashX documentation](https://docs.dashx.com/developer).

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
