import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'dashx-react-native' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const DashX = NativeModules.DashXReactNative
  ? NativeModules.DashXReactNative
  : new Proxy(
    {},
    {
      get() {
        throw new Error(LINKING_ERROR);
      },
    }
  );

const {
  configure,
  identify,
  setIdentity,
  reset,
  track,
  screen,
  fetchStoredPreferences,
  saveStoredPreferences,
  subscribe,
  unsubscribe,
  setLogLevel,
} = DashX;

DashX.configure = (options) => {
  return configure(options);
}

DashX.identify = (options) => {
  return identify(options);
};

DashX.setIdentity = (uid, token) => {
  return setIdentity(uid, token);
};

DashX.reset = () => {
  return reset();
}

DashX.track = (event, data) => {
  return track(event, data || null);
}

DashX.screen = (screenName, data) => {
  return screen(screenName, data || null)
}

DashX.fetchStoredPreferences = () => {
  return fetchStoredPreferences();
};

DashX.saveStoredPreferences = (preferenceData) => {
  return saveStoredPreferences(preferenceData);
};

DashX.subscribe = () => {
  return subscribe();
}

DashX.unsubscribe = () => {
  return unsubscribe();
}

DashX.setLogLevel = (level) => {
  return setLogLevel(level);
}

export default DashX;
