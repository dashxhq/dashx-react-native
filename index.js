import { NativeEventEmitter, NativeModules, Platform } from 'react-native';
import NativeDashXReactNative from './src/NativeDashXReactNative';

function getLinkingError() {
  return (
    `The package 'dashx-react-native' doesn't seem to be linked. Make sure: \n\n` +
    Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
    '- You rebuilt the app after installing the package\n' +
    '- You are not using Expo Go\n'
  );
}

let _nativeDashX = null;
function getNativeDashX() {
  if (!_nativeDashX) {
    const nativeModule =
      NativeDashXReactNative || NativeModules.DashXReactNative;
    _nativeDashX = nativeModule
      ? nativeModule
      : new Proxy(
          {},
          {
            get() {
              throw new Error(getLinkingError());
            },
          }
        );
  }
  return _nativeDashX;
}

let _onMessageReceivedDeprecationWarned = false;

let _eventEmitter = null;
function getEventEmitter() {
  if (!_eventEmitter) {
    _eventEmitter = new NativeEventEmitter(getNativeDashX());
  }
  return _eventEmitter;
}

// --- In-app chat ---
//
// A conversation opened from JS is a native lease. JS picks the lease id, so
// opening needs no round trip, and every lease reports back on one event.

const CHAT_EVENT = 'chatConversationEvent';
const CHAT_LOADING = { status: 'loading' };
const _chatLeases = new Map();
let _chatSubscription = null;
let _chatLeaseCount = 0;
let _chatRequestCount = 0;

function requireChatId(method, name, value) {
  if (!value || typeof value !== 'string') {
    throw new Error(`${method}: ${name} is required and must be a string`);
  }
}

// The bridge carries neither undefined nor, on Android, a null where a number
// is read, so absent options are left out.
function chatOptions(method, options, keys) {
  if (options == null) return null;
  if (typeof options !== 'object') {
    throw new Error(`${method}: options must be an object`);
  }
  const result = {};
  keys.forEach((key) => {
    if (options[key] != null) result[key] = options[key];
  });
  return result;
}

function notifyChatListeners(listeners, value) {
  Array.from(listeners).forEach((listener) => {
    try {
      listener(value);
    } catch (error) {
      console.error('DashX chat: a listener threw', error);
    }
  });
}

function handleChatEvent(event) {
  const lease = event && _chatLeases.get(event.leaseId);
  if (!lease) return;

  if (event.type === 'state') {
    lease.state = event.state;
    notifyChatListeners(lease.stateListeners, lease.state);
  } else if (event.type === 'streamingReply') {
    // Only the reply changed. Native sends this after a ready state, whose
    // messages and paging stay as they are.
    if (lease.state.status !== 'ready') return;
    lease.state = { ...lease.state, streamingReply: event.streamingReply };
    notifyChatListeners(lease.stateListeners, lease.state);
  } else if (event.type === 'terminated') {
    notifyChatListeners(lease.terminatedListeners, event.reason);
  } else if (event.type === 'loadPreviousPageError') {
    const onError = lease.pageErrorCallbacks.get(event.requestId);
    lease.pageErrorCallbacks.delete(event.requestId);
    if (onError) notifyChatListeners([onError], event.error);
  } else if (event.type === 'loadPreviousPageComplete') {
    lease.pageErrorCallbacks.delete(event.requestId);
  }
}

function addChatListener(listeners, listener) {
  listeners.add(listener);
  return { remove: () => listeners.delete(listener) };
}

function chatSessionEndedError(method) {
  const error = new Error(`${method}: the conversation is closed`);
  error.code = 'SESSION_ENDED';
  return error;
}

function openChatConversation(chatIdentityId, conversationId) {
  if (!_chatSubscription) {
    _chatSubscription = getEventEmitter().addListener(
      CHAT_EVENT,
      handleChatEvent
    );
  }

  // Unique across a JS reload too, where the count starts over.
  _chatLeaseCount += 1;
  const leaseId = `${Date.now().toString(36)}-${_chatLeaseCount}`;
  const lease = {
    state: CHAT_LOADING,
    closed: false,
    stateListeners: new Set(),
    terminatedListeners: new Set(),
    pageErrorCallbacks: new Map(),
  };
  _chatLeases.set(leaseId, lease);
  getNativeDashX().chatOpenConversation(
    leaseId,
    chatIdentityId,
    conversationId
  );

  return {
    conversationId,

    get state() {
      return lease.state;
    },

    addStateListener(listener) {
      if (typeof listener !== 'function') {
        throw new Error(
          'DashX chat addStateListener: listener must be a function'
        );
      }
      if (lease.closed) return { remove: () => {} };
      const subscription = addChatListener(lease.stateListeners, listener);
      listener(lease.state);
      return subscription;
    },

    onTerminated(listener) {
      if (typeof listener !== 'function') {
        throw new Error('DashX chat onTerminated: listener must be a function');
      }
      if (lease.closed) return { remove: () => {} };
      return addChatListener(lease.terminatedListeners, listener);
    },

    sendMessage(content) {
      if (!content || typeof content !== 'object' || Array.isArray(content)) {
        throw new Error(
          'DashX chat sendMessage: content must be an object such as { text: "Hello" }'
        );
      }
      if (lease.closed) {
        return Promise.reject(chatSessionEndedError('DashX chat sendMessage'));
      }
      return getNativeDashX()
        .chatSendMessage(leaseId, content)
        .catch((error) => {
          const clientMessageId =
            error && error.userInfo && error.userInfo.clientMessageId;
          if (clientMessageId) error.clientMessageId = clientMessageId;
          throw error;
        });
    },

    loadPreviousPage(onError) {
      if (onError != null && typeof onError !== 'function') {
        throw new Error(
          'DashX chat loadPreviousPage: onError must be a function'
        );
      }
      if (lease.closed) return;
      _chatRequestCount += 1;
      const requestId = _chatRequestCount;
      if (onError) lease.pageErrorCallbacks.set(requestId, onError);
      try {
        getNativeDashX().chatLoadPreviousPage(leaseId, requestId);
      } catch (error) {
        lease.pageErrorCallbacks.delete(requestId);
        throw error;
      }
    },

    setVisible(visible) {
      if (lease.closed) return;
      getNativeDashX().chatSetConversationVisible(leaseId, Boolean(visible));
    },

    close() {
      if (lease.closed) return;
      lease.closed = true;
      lease.stateListeners.clear();
      lease.terminatedListeners.clear();
      lease.pageErrorCallbacks.clear();
      _chatLeases.delete(leaseId);
      getNativeDashX().chatCloseConversation(leaseId);
    },
  };
}

function createChat(chatIdentityId) {
  return {
    chatIdentityId,

    openConversation(conversationId) {
      requireChatId(
        'DashX chat openConversation',
        'conversationId',
        conversationId
      );
      return openChatConversation(chatIdentityId, conversationId);
    },

    fetchConversations(options) {
      return getNativeDashX().chatFetchConversations(
        chatIdentityId,
        chatOptions('DashX chat fetchConversations', options, [
          'limit',
          'page',
          'statuses',
          'properties',
        ])
      );
    },

    fetchConversation(conversationId) {
      requireChatId(
        'DashX chat fetchConversation',
        'conversationId',
        conversationId
      );
      return getNativeDashX().chatFetchConversation(
        chatIdentityId,
        conversationId
      );
    },

    summarizeConversations(options) {
      return getNativeDashX().chatSummarizeConversations(
        chatIdentityId,
        chatOptions('DashX chat summarizeConversations', options, [
          'statuses',
          'properties',
        ])
      );
    },

    summarizeUnread() {
      return getNativeDashX().chatSummarizeUnread(chatIdentityId);
    },

    resolveConversation(conversationId) {
      requireChatId(
        'DashX chat resolveConversation',
        'conversationId',
        conversationId
      );
      return getNativeDashX().chatResolveConversation(
        chatIdentityId,
        conversationId
      );
    },
  };
}

const DashX = {
  configure(options) {
    if (!options || typeof options !== 'object') {
      throw new Error('DashX.configure: options must be an object');
    }
    if (!options.publicKey || typeof options.publicKey !== 'string') {
      throw new Error(
        'DashX.configure: publicKey is required and must be a string'
      );
    }
    return getNativeDashX().configure(options);
  },

  identify(options) {
    if (!options || typeof options !== 'object') {
      throw new Error('DashX.identify: options must be an object');
    }
    return getNativeDashX().identify(options);
  },

  setIdentity(uid, token) {
    // Both uid and token are nullable passthroughs to the native SDK. Only
    // validate TYPE here — the native side decides semantics. `undefined` is
    // normalized to `null` because the RN bridge can't carry undefined.
    if (uid !== null && uid !== undefined && typeof uid !== 'string') {
      throw new Error('DashX.setIdentity: uid must be a string or null');
    }
    if (token !== null && token !== undefined && typeof token !== 'string') {
      throw new Error('DashX.setIdentity: token must be a string or null');
    }
    return getNativeDashX().setIdentity(uid ?? null, token ?? null);
  },

  reset() {
    return getNativeDashX().reset();
  },

  track(event, data) {
    if (!event || typeof event !== 'string') {
      throw new Error('DashX.track: event is required and must be a string');
    }
    return getNativeDashX().track(event, data || null);
  },

  screen(screenName, data) {
    if (!screenName || typeof screenName !== 'string') {
      throw new Error(
        'DashX.screen: screenName is required and must be a string'
      );
    }
    return getNativeDashX().screen(screenName, data || null);
  },

  fetchRecord(urn, options = {}) {
    if (!urn || typeof urn !== 'string') {
      throw new Error(
        'DashX.fetchRecord: urn is required and must be a string (e.g. "article/123")'
      );
    }
    if (options !== null && typeof options !== 'object') {
      throw new Error('DashX.fetchRecord: options must be an object');
    }
    return getNativeDashX().fetchRecord(urn, options || null);
  },

  searchRecords(resource, options = {}) {
    if (!resource || typeof resource !== 'string') {
      throw new Error(
        'DashX.searchRecords: resource is required and must be a string'
      );
    }
    if (options !== null && typeof options !== 'object') {
      throw new Error('DashX.searchRecords: options must be an object');
    }
    return getNativeDashX().searchRecords(resource, options || null);
  },

  fetchStoredPreferences() {
    return getNativeDashX().fetchStoredPreferences();
  },

  saveStoredPreferences(preferenceData) {
    if (!preferenceData || typeof preferenceData !== 'object') {
      throw new Error(
        'DashX.saveStoredPreferences: preferenceData is required and must be an object'
      );
    }
    return getNativeDashX().saveStoredPreferences(preferenceData);
  },

  subscribe() {
    return getNativeDashX().subscribe();
  },

  unsubscribe() {
    return getNativeDashX().unsubscribe();
  },

  setLogLevel(level) {
    if (typeof level !== 'number') {
      throw new Error('DashX.setLogLevel: level must be a number');
    }
    return getNativeDashX().setLogLevel(level);
  },

  onPushNotificationReceived(callback) {
    if (typeof callback !== 'function') {
      throw new Error(
        'DashX.onPushNotificationReceived: callback must be a function'
      );
    }
    return getEventEmitter().addListener('messageReceived', callback);
  },

  onMessageReceived(callback) {
    if (!_onMessageReceivedDeprecationWarned) {
      console.warn(
        'DashX.onMessageReceived is deprecated and will be removed in the next major version. Use DashX.onPushNotificationReceived instead.'
      );
      _onMessageReceivedDeprecationWarned = true;
    }
    return DashX.onPushNotificationReceived(callback);
  },

  uploadAsset(filePath, resource, attribute) {
    if (!filePath || typeof filePath !== 'string') {
      throw new Error('DashX.uploadAsset: filePath must be a string');
    }
    if (!resource || typeof resource !== 'string') {
      throw new Error('DashX.uploadAsset: resource must be a string');
    }
    if (!attribute || typeof attribute !== 'string') {
      throw new Error('DashX.uploadAsset: attribute must be a string');
    }
    return getNativeDashX().uploadAsset(filePath, resource, attribute);
  },

  fetchAsset(assetId) {
    if (!assetId || typeof assetId !== 'string') {
      throw new Error('DashX.fetchAsset: assetId must be a string');
    }
    return getNativeDashX().fetchAsset(assetId);
  },

  enableLifecycleTracking() {
    return getNativeDashX().enableLifecycleTracking();
  },

  trackNavigation(navigationRef) {
    if (!navigationRef || typeof navigationRef !== 'object') {
      throw new Error(
        'DashX.trackNavigation: navigationRef must be a NavigationContainer ref'
      );
    }

    // A ref from createNavigationContainerRef / useNavigationContainerRef
    // queues listeners until the container mounts; a plain useRef does not.
    const navigation =
      typeof navigationRef.addListener === 'function'
        ? navigationRef
        : navigationRef.current;

    if (!navigation) {
      console.warn(
        'DashX.trackNavigation: navigationRef.current is null. Call it from NavigationContainer onReady, or pass a ref from useNavigationContainerRef().'
      );
      return () => {};
    }
    if (
      typeof navigation.addListener !== 'function' ||
      typeof navigation.getCurrentRoute !== 'function'
    ) {
      throw new Error(
        'DashX.trackNavigation: navigationRef must be a NavigationContainer ref'
      );
    }

    let lastRouteId = null;
    let active = true;

    const trackCurrentRoute = () => {
      if (!active) return;
      // getCurrentRoute() logs an error on a container ref that is not ready.
      if (typeof navigation.isReady === 'function' && !navigation.isReady()) {
        return;
      }
      const route = navigation.getCurrentRoute();
      const routeName = route && route.name;
      if (!routeName) return;
      // By key, so pushing a second instance of a screen (or going back to the
      // first) is a new view; params changes keep the key and are not.
      const routeId = route.key || routeName;
      if (routeId === lastRouteId) return;
      lastRouteId = routeId;
      DashX.screen(routeName);
    };

    const removeListener = navigation.addListener('state', trackCurrentRoute);
    trackCurrentRoute();

    return () => {
      active = false;
      if (typeof removeListener === 'function') removeListener();
    };
  },

  enableAdTracking() {
    if (Platform.OS !== 'ios') return;
    return getNativeDashX().enableAdTracking();
  },

  processURL(url, options = {}) {
    if (Platform.OS !== 'ios') return;
    if (!url || typeof url !== 'string') {
      throw new Error('DashX.processURL: url is required and must be a string');
    }
    return getNativeDashX().processURL(
      url,
      options.source || null,
      options.forwardToLinkHandler !== false
    );
  },

  trackNotificationNavigation(action, notificationId) {
    if (Platform.OS !== 'ios') return;
    if (action != null && typeof action !== 'object') {
      throw new Error(
        'DashX.trackNotificationNavigation: action must be an object or null'
      );
    }
    return getNativeDashX().trackNotificationNavigation(
      action || null,
      notificationId || null
    );
  },

  requestNotificationPermission(options) {
    const fallbackToSettings = Boolean(options && options.fallbackToSettings);
    return getNativeDashX().requestNotificationPermission(fallbackToSettings);
  },

  getNotificationPermissionStatus() {
    return getNativeDashX().getNotificationPermissionStatus();
  },

  onLinkReceived(callback) {
    if (typeof callback !== 'function') {
      throw new Error('DashX.onLinkReceived: callback must be a function');
    }
    return getEventEmitter().addListener('linkReceived', callback);
  },

  chat(chatIdentityId) {
    requireChatId('DashX.chat', 'chatIdentityId', chatIdentityId);
    return createChat(chatIdentityId);
  },

  onNotificationClicked(callback) {
    if (typeof callback !== 'function') {
      throw new Error(
        'DashX.onNotificationClicked: callback must be a function'
      );
    }
    return getEventEmitter().addListener('notificationClicked', callback);
  },
};

export default DashX;
