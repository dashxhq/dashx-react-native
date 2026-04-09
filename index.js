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

let _eventEmitter = null;
function getEventEmitter() {
  if (!_eventEmitter) {
    _eventEmitter = new NativeEventEmitter(getNativeDashX());
  }
  return _eventEmitter;
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
    if (!uid || typeof uid !== 'string') {
      throw new Error(
        'DashX.setIdentity: uid is required and must be a string'
      );
    }
    if (!token || typeof token !== 'string') {
      throw new Error(
        'DashX.setIdentity: token is required and must be a string'
      );
    }
    return getNativeDashX().setIdentity(uid, token);
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

  onMessageReceived(callback) {
    if (typeof callback !== 'function') {
      throw new Error('DashX.onMessageReceived: callback must be a function');
    }
    return getEventEmitter().addListener('messageReceived', callback);
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
    if (Platform.OS !== 'ios') return;
    return getNativeDashX().enableLifecycleTracking();
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

  requestNotificationPermission() {
    return getNativeDashX().requestNotificationPermission();
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
};

export default DashX;
