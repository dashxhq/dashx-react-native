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
[![platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS-brightgreen.svg)](#install)

_DashX SDK for React Native_

## Install

Requires **React Native 0.74+**, **iOS 13.0+**, **Android SDK 26+**, and **Node.js 16+**.

> **Note:** This SDK uses native modules and is **not compatible with Expo Go**. Use a [development build](https://docs.expo.dev/develop/development-builds/introduction/) if you are using Expo.

```sh
npm install @dashx/react-native
```

or

```sh
yarn add @dashx/react-native
```

## New Architecture support

Starting with **1.2.0**, `@dashx/react-native` is implemented as a TurboModule and supports both the **Old Architecture** and the **New Architecture** out of the box. The same package and the same JS API work on both — no code changes, no conditional imports, no flags to flip in your app code.

- Consumers on `newArchEnabled=true` get direct JSI calls and compile-time type safety via codegen.
- Consumers on `newArchEnabled=false` continue to use the legacy bridge with no changes.

### Breaking changes in 1.2.0

- Minimum React Native version is now **0.74.0** (previously 0.71.0).
- The Android package class has been renamed from `DashXPackage` to `DashXReactNativePackage` (the filename was already `DashXReactNativePackage.kt`; this resolves a long-standing filename/classname mismatch). If you manually registered packages in `MainApplication`, update your import/constructor accordingly. Most apps use autolinking and will not be affected.

## Documentation

For detailed documentation, visit [React Native SDK documentation](https://docs.dashx.com/sdks/client-side/react-native-sdk).

## Deep linking and push navigation

See the [Deep Linking & Push Navigation](https://docs.dashx.com/apps/messaging/deep-linking) guide for setup instructions, payload fields, and code examples.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and workflow.

## License

MIT
