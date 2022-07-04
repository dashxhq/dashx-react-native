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

_DashX SDK for React Native_

## Install

**npm**
```sh
npm install @dashx/react-native
```

**yarn**
```sh
yarn add @dashx/react-native
```

### Setup for Android

DashX requires Google Services installed in your app for Firebase to work:

- Add `google-services` plugin in your `/android/build.gradle`

```gradle
buildscript {
  dependencies {
    // ... other dependencies
    classpath 'com.google.gms:google-services:4.3.3'
  }
}
```

- Add this line in your `/android/app/build.gradle`

```gradle
apply plugin: 'com.google.gms.google-services'
```

- Add your Android app on Firebase Console: `Project Overview > Add App > Android`

- Download `google-services.json` from there.

- Add `google-services.json` at the following location: `/android/app/google-services.json`

### Setup for iOS

- At the top of the file `/ios/{projectName}/AppDelegate.m` before [#if defined(FB_SONARKIT_ENABLED)](https://github.com/react-native-camera/react-native-camera/issues/3008#issuecomment-726432198), import Firebase:

```objective-c
#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseMessaging/FirebaseMessaging.h>
```

- In the same file, inside your `didFinishLaunchingWithOptions` add this:

```objective-c
// Register for remote notifications. This shows a permission dialog on first run, to
// show the dialog at a more appropriate time move this registration accordingly.
// [START register_for_notifications]
[UNUserNotificationCenter currentNotificationCenter].delegate = self;
UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
[[UNUserNotificationCenter currentNotificationCenter]
    requestAuthorizationWithOptions:authOptions
    completionHandler:^(BOOL granted, NSError * _Nullable error) {
}];

[application registerForRemoteNotifications];
// [END register_for_notifications]

// [START configure_firebase]
if ([FIRApp defaultApp] == nil) {
  [FIRApp configure];
}
// [END configure_firebase]

// [START set_messaging_delegate]
[FIRMessaging messaging].delegate = self;
// [END set_messaging_delegate]
```

- In your `Podfile` add this:

```ruby
pod 'FirebaseMessaging', :modular_headers => true
```

- Add your iOS app on Firebase Console: `Project Overview > Add App > iOS`

- Download `GoogleService-Info.plist`

- Add `GoogleService-Info.plist` using XCode by right clicking on project and select `Add Files`, select your downloaded file and make sure `Copy items if needed` is checked.

## Usage

For detailed usage, refer to the [documentation](https://docs.dashx.com/developer).

## Contributing

Please follow [these steps](https://github.com/dashxhq/dashx-js/tree/master/examples/react-native#setting-up-development-environment) to set-up development environment.

You'll also need Apollo CLI to generate files.

```sh
$ npm i -g apollo
```

For the next steps, please follow the guide for the respective platform:

- [Android](android/README.md)
- [iOS](ios/README.md)
