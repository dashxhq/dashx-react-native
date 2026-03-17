import { NativeEventEmitter, NativeModules, Platform } from 'react-native';

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
    _nativeDashX = NativeModules.DashXReactNative
      ? NativeModules.DashXReactNative
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
      throw new Error('DashX.configure: publicKey is required and must be a string');
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
      throw new Error('DashX.setIdentity: uid is required and must be a string');
    }
    if (!token || typeof token !== 'string') {
      throw new Error('DashX.setIdentity: token is required and must be a string');
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
      throw new Error('DashX.screen: screenName is required and must be a string');
    }
    return getNativeDashX().screen(screenName, data || null);
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
};

export default DashX;
