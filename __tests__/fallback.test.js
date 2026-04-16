const mockNativeModule = {
  configure: jest.fn(),
  identify: jest.fn(),
  setIdentity: jest.fn(),
  reset: jest.fn(),
  track: jest.fn(),
  screen: jest.fn(),
  fetchRecord: jest.fn(),
  searchRecords: jest.fn(),
  fetchStoredPreferences: jest.fn(),
  saveStoredPreferences: jest.fn(),
  subscribe: jest.fn(),
  unsubscribe: jest.fn(),
  setLogLevel: jest.fn(),
  uploadAsset: jest.fn(),
  fetchAsset: jest.fn(),
  enableLifecycleTracking: jest.fn(),
  enableAdTracking: jest.fn(),
  processURL: jest.fn(),
  trackNotificationNavigation: jest.fn(),
  requestNotificationPermission: jest.fn(),
  getNotificationPermissionStatus: jest.fn(),
  addListener: jest.fn(),
  removeListeners: jest.fn(),
};

jest.mock('react-native', () => ({
  NativeModules: {
    DashXReactNative: mockNativeModule,
  },
  NativeEventEmitter: jest.fn().mockImplementation(() => ({
    addListener: jest.fn(() => ({ remove: jest.fn() })),
  })),
  Platform: {
    OS: 'ios',
    select: jest.fn((obj) => obj.default || ''),
  },
  TurboModuleRegistry: {
    get: jest.fn(() => null),
    getEnforcing: jest.fn(() => {
      throw new Error('not available');
    }),
  },
}));

// TurboModule returns null -> should fall back to NativeModules
jest.mock('../src/NativeDashXReactNative', () => ({
  __esModule: true,
  default: null,
}));

const DashX = require('../index').default;

describe('NativeModules fallback', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('falls back to NativeModules.DashXReactNative when TurboModule is null', () => {
    DashX.configure({ publicKey: 'pk_test' });
    expect(mockNativeModule.configure).toHaveBeenCalledWith({
      publicKey: 'pk_test',
    });
  });

  it('calls track on the fallback module', () => {
    DashX.track('event_name', { key: 'value' });
    expect(mockNativeModule.track).toHaveBeenCalledWith('event_name', {
      key: 'value',
    });
  });
});
