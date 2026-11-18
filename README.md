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

Requires **React Native 0.74+**, **iOS 15.0+**, **Android SDK 26+**, and **Node.js 16+**.

Supports both the **Old Architecture** (bridge) and **New Architecture** (TurboModule) from a single install.

> **Note:** This SDK uses native modules and is **not compatible with Expo Go**. Use a [development build](https://docs.expo.dev/develop/development-builds/introduction/) if you are using Expo.

```sh
npm install @dashx/react-native
```

or

```sh
yarn add @dashx/react-native
```

## Documentation

For detailed documentation, visit [React Native SDK documentation](https://docs.dashx.com/sdks/client-side/react-native-sdk).

## Automatic events

### App lifecycle

On iOS and Android, call `enableLifecycleTracking()` after `configure` to send these events:

- `Application Installed` and `Application Updated` on the first launch of a new install or build
- `Application Opened` on launch and when returning to the foreground (`from_background`)
- `Application Backgrounded` when the app leaves the foreground (`session_length`, in seconds)
- `Application Crashed` on an uncaught native exception (iOS only)

```js
DashX.configure({ publicKey: 'YOUR_PUBLIC_KEY' });
DashX.enableLifecycleTracking();
```

### Screen views with React Navigation

React Native screens are routes rather than native screens, so track them from the navigation container. `trackNavigation` sends `DashX.screen(route.name)`, recorded as `$screen` with the route name in `$screen_name`, for the first route and then whenever a different route instance gains focus. Instances are told apart by `route.key`, so opening a second instance of a screen, or going back to the first, counts as a new view; changing params does not. Route params are not sent. Call it from `onReady` so the first screen is captured; it returns a function that stops tracking.

```jsx
import { NavigationContainer, useNavigationContainerRef } from '@react-navigation/native';
import DashX from '@dashx/react-native';

export default function App() {
  const navigationRef = useNavigationContainerRef();

  return (
    <NavigationContainer
      ref={navigationRef}
      onReady={() => DashX.trackNavigation(navigationRef)}
    >
      {/* ... */}
    </NavigationContainer>
  );
}
```

## In-app chat

Conversations are created by your server, which returns a conversation id together with a chat identity id. Chat needs an identity token, so call `DashX.setIdentity(uid, token)` first.

Open a conversation to get its messages and live updates. The listener is called right away with the current state, then on every change:

```jsx
import { useEffect, useState } from 'react';
import DashX from '@dashx/react-native';

function useConversation(chatIdentityId, conversationId) {
  const [conversation, setConversation] = useState(null);
  const [state, setState] = useState({ status: 'loading' });

  useEffect(() => {
    const opened = DashX.chat(chatIdentityId).openConversation(conversationId);
    opened.addStateListener(setState);
    opened.setVisible(true);
    setConversation(opened);
    return () => opened.close();
  }, [chatIdentityId, conversationId]);

  return { conversation, state };
}
```

`state.status` is `loading`, `ready` or `error`:

- `ready` has `messages` (oldest first), `hasOlderMessages` and `streamingReply`. Call `conversation.loadPreviousPage()` while `hasOlderMessages` is true to load earlier history. `streamingReply` (`turnSeq`, `text`, `isComplete`) is the agent reply while it is being generated, on deployments that stream replies, and `null` otherwise. Show it below the messages; it goes away once the stored reply arrives in `messages`.
- `error` has `error.code` and `error.message`. The code is `SESSION_ENDED` once the user changes or `DashX.reset()` is called; close the conversation and open a new one to continue.

Send a message with `conversation.sendMessage({ text })`. It resolves with the stored message, which also appears in `state.messages`. If it fails, the error has a `code` and the `clientMessageId` the message was sent with.

`conversation.setVisible(true)` says the conversation is on screen: new messages are marked read and its push notifications are not shown. Call `setVisible(false)` when the screen loses focus, and `close()` when it unmounts. On iOS, foreground notifications are held back only if your app delegate routes them through `DashXNotificationHandler.handleForegroundNotification`.

For an inbox, `DashX.chat(chatIdentityId)` also has `fetchConversations({ limit, page, statuses, properties })`, `fetchConversation(conversationId)`, `summarizeConversations({ statuses, properties })`, `summarizeUnread()` and `resolveConversation(conversationId)`. The unread count is not pushed: ask for it again when the app returns to the foreground or a push arrives.

## Deep linking and push navigation

See the [Deep Linking & Push Navigation](https://docs.dashx.com/apps/messaging/deep-linking) guide for setup instructions, payload fields, and code examples.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and workflow.

## License

MIT
