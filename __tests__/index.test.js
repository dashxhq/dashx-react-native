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

const mockAddListener = jest.fn(() => ({ remove: jest.fn() }));

jest.mock('react-native', () => ({
  NativeModules: {
    DashXReactNative: mockNativeModule,
  },
  NativeEventEmitter: jest.fn().mockImplementation(() => ({
    addListener: mockAddListener,
  })),
  Platform: {
    OS: 'ios',
    select: jest.fn((obj) => obj.default || ''),
  },
  TurboModuleRegistry: {
    get: jest.fn(() => mockNativeModule),
    getEnforcing: jest.fn(() => mockNativeModule),
  },
}));

jest.mock('../src/NativeDashXReactNative', () => ({
  __esModule: true,
  default: mockNativeModule,
}));

const DashX = require('../index').default;

beforeEach(() => {
  jest.clearAllMocks();
});

// --- configure ---

describe('configure', () => {
  it('calls native configure with options', () => {
    DashX.configure({ publicKey: 'pk_test' });
    expect(mockNativeModule.configure).toHaveBeenCalledWith({
      publicKey: 'pk_test',
    });
  });

  it('throws if options is not an object', () => {
    expect(() => DashX.configure(null)).toThrow('options must be an object');
    expect(() => DashX.configure('string')).toThrow('options must be an object');
  });

  it('throws if publicKey is missing', () => {
    expect(() => DashX.configure({})).toThrow('publicKey is required');
  });

  it('throws if publicKey is not a string', () => {
    expect(() => DashX.configure({ publicKey: 123 })).toThrow(
      'publicKey is required and must be a string'
    );
  });
});

// --- identify ---

describe('identify', () => {
  it('calls native identify with options', () => {
    DashX.identify({ email: 'test@example.com' });
    expect(mockNativeModule.identify).toHaveBeenCalledWith({
      email: 'test@example.com',
    });
  });

  it('throws if options is not an object', () => {
    expect(() => DashX.identify(null)).toThrow('options must be an object');
  });
});

// --- setIdentity ---

describe('setIdentity', () => {
  it('calls native setIdentity with uid and token', () => {
    DashX.setIdentity('user-1', 'token-abc');
    expect(mockNativeModule.setIdentity).toHaveBeenCalledWith(
      'user-1',
      'token-abc'
    );
  });

  it('throws if uid is missing', () => {
    expect(() => DashX.setIdentity(null, 'token')).toThrow('uid is required');
  });

  it('passes null token through to native', () => {
    DashX.setIdentity('uid', null);
    expect(mockNativeModule.setIdentity).toHaveBeenCalledWith('uid', null);
  });

  it('passes undefined token as null to native', () => {
    DashX.setIdentity('uid');
    expect(mockNativeModule.setIdentity).toHaveBeenCalledWith('uid', null);
  });
});

// --- reset ---

describe('reset', () => {
  it('calls native reset', () => {
    DashX.reset();
    expect(mockNativeModule.reset).toHaveBeenCalled();
  });
});

// --- track ---

describe('track', () => {
  it('calls native track with event and data', () => {
    DashX.track('purchase', { amount: 100 });
    expect(mockNativeModule.track).toHaveBeenCalledWith('purchase', {
      amount: 100,
    });
  });

  it('calls native track with null data when omitted', () => {
    DashX.track('page_view');
    expect(mockNativeModule.track).toHaveBeenCalledWith('page_view', null);
  });

  it('throws if event is missing', () => {
    expect(() => DashX.track(null)).toThrow('event is required');
  });

  it('throws if event is not a string', () => {
    expect(() => DashX.track(42)).toThrow(
      'event is required and must be a string'
    );
  });
});

// --- screen ---

describe('screen', () => {
  it('calls native screen with name and data', () => {
    DashX.screen('Home', { section: 'top' });
    expect(mockNativeModule.screen).toHaveBeenCalledWith('Home', {
      section: 'top',
    });
  });

  it('calls native screen with null data when omitted', () => {
    DashX.screen('Settings');
    expect(mockNativeModule.screen).toHaveBeenCalledWith('Settings', null);
  });

  it('throws if screenName is missing', () => {
    expect(() => DashX.screen(null)).toThrow('screenName is required');
  });
});

// --- fetchRecord ---

describe('fetchRecord', () => {
  it('calls native fetchRecord with urn and options', () => {
    mockNativeModule.fetchRecord.mockResolvedValue({ id: '123' });
    const result = DashX.fetchRecord('article/123', { preview: true });
    expect(mockNativeModule.fetchRecord).toHaveBeenCalledWith('article/123', {
      preview: true,
    });
    return expect(result).resolves.toEqual({ id: '123' });
  });

  it('calls native fetchRecord with empty options when omitted', () => {
    mockNativeModule.fetchRecord.mockResolvedValue({});
    DashX.fetchRecord('article/456');
    expect(mockNativeModule.fetchRecord).toHaveBeenCalledWith(
      'article/456',
      {}
    );
  });

  it('throws if urn is missing', () => {
    expect(() => DashX.fetchRecord(null)).toThrow('urn is required');
  });
});

// --- searchRecords ---

describe('searchRecords', () => {
  it('calls native searchRecords with resource and options', () => {
    mockNativeModule.searchRecords.mockResolvedValue([{ id: '1' }]);
    const result = DashX.searchRecords('articles', { limit: 10 });
    expect(mockNativeModule.searchRecords).toHaveBeenCalledWith('articles', {
      limit: 10,
    });
    return expect(result).resolves.toEqual([{ id: '1' }]);
  });

  it('throws if resource is missing', () => {
    expect(() => DashX.searchRecords(null)).toThrow('resource is required');
  });
});

// --- fetchStoredPreferences ---

describe('fetchStoredPreferences', () => {
  it('calls native fetchStoredPreferences', () => {
    mockNativeModule.fetchStoredPreferences.mockResolvedValue({
      email: true,
    });
    const result = DashX.fetchStoredPreferences();
    expect(mockNativeModule.fetchStoredPreferences).toHaveBeenCalled();
    return expect(result).resolves.toEqual({ email: true });
  });
});

// --- saveStoredPreferences ---

describe('saveStoredPreferences', () => {
  it('calls native saveStoredPreferences with data', () => {
    mockNativeModule.saveStoredPreferences.mockResolvedValue({ success: true });
    const result = DashX.saveStoredPreferences({ email: false });
    expect(mockNativeModule.saveStoredPreferences).toHaveBeenCalledWith({
      email: false,
    });
    return expect(result).resolves.toEqual({ success: true });
  });

  it('throws if preferenceData is not an object', () => {
    expect(() => DashX.saveStoredPreferences(null)).toThrow(
      'preferenceData is required'
    );
  });
});

// --- subscribe / unsubscribe ---

describe('subscribe', () => {
  it('calls native subscribe', () => {
    DashX.subscribe();
    expect(mockNativeModule.subscribe).toHaveBeenCalled();
  });
});

describe('unsubscribe', () => {
  it('calls native unsubscribe', () => {
    DashX.unsubscribe();
    expect(mockNativeModule.unsubscribe).toHaveBeenCalled();
  });
});

// --- setLogLevel ---

describe('setLogLevel', () => {
  it('calls native setLogLevel with level', () => {
    DashX.setLogLevel(2);
    expect(mockNativeModule.setLogLevel).toHaveBeenCalledWith(2);
  });

  it('throws if level is not a number', () => {
    expect(() => DashX.setLogLevel('debug')).toThrow(
      'level must be a number'
    );
  });
});

// --- onMessageReceived ---

describe('onMessageReceived', () => {
  it('throws if callback is not a function', () => {
    expect(() => DashX.onMessageReceived('not a function')).toThrow(
      'callback must be a function'
    );
  });

  it('registers a listener for messageReceived events', () => {
    const callback = jest.fn();
    const subscription = DashX.onMessageReceived(callback);
    expect(mockAddListener).toHaveBeenCalledWith('messageReceived', callback);
    expect(subscription).toBeDefined();
  });
});

// --- uploadAsset ---

describe('uploadAsset', () => {
  it('calls native uploadAsset with filePath, resource, attribute', () => {
    mockNativeModule.uploadAsset.mockResolvedValue({ status: 'ready' });
    const result = DashX.uploadAsset('/path/to/file.jpg', 'products', 'image');
    expect(mockNativeModule.uploadAsset).toHaveBeenCalledWith(
      '/path/to/file.jpg',
      'products',
      'image'
    );
    return expect(result).resolves.toEqual({ status: 'ready' });
  });

  it('throws if filePath is missing', () => {
    expect(() => DashX.uploadAsset(null, 'r', 'a')).toThrow('filePath must be a string');
  });

  it('throws if resource is missing', () => {
    expect(() => DashX.uploadAsset('/path', null, 'a')).toThrow('resource must be a string');
  });

  it('throws if attribute is missing', () => {
    expect(() => DashX.uploadAsset('/path', 'r', null)).toThrow('attribute must be a string');
  });
});

// --- fetchAsset ---

describe('fetchAsset', () => {
  it('calls native fetchAsset with assetId', () => {
    mockNativeModule.fetchAsset.mockResolvedValue({ status: 'ready' });
    const result = DashX.fetchAsset('asset-123');
    expect(mockNativeModule.fetchAsset).toHaveBeenCalledWith('asset-123');
    return expect(result).resolves.toEqual({ status: 'ready' });
  });

  it('throws if assetId is missing', () => {
    expect(() => DashX.fetchAsset(null)).toThrow('assetId must be a string');
  });
});

// --- processURL ---

describe('processURL', () => {
  it('calls native processURL with defaults', () => {
    DashX.processURL('https://example.com/path');
    expect(mockNativeModule.processURL).toHaveBeenCalledWith(
      'https://example.com/path',
      null,
      true
    );
  });

  it('passes source option', () => {
    DashX.processURL('https://example.com', { source: 'universal_link' });
    expect(mockNativeModule.processURL).toHaveBeenCalledWith(
      'https://example.com',
      'universal_link',
      true
    );
  });

  it('passes forwardToLinkHandler as false', () => {
    DashX.processURL('https://example.com', { forwardToLinkHandler: false });
    expect(mockNativeModule.processURL).toHaveBeenCalledWith(
      'https://example.com',
      null,
      false
    );
  });

  it('throws if url is missing', () => {
    expect(() => DashX.processURL(null)).toThrow('url is required');
  });

  it('throws if url is not a string', () => {
    expect(() => DashX.processURL(123)).toThrow(
      'url is required and must be a string'
    );
  });

  it('no-ops on Android', () => {
    const { Platform } = require('react-native');
    Platform.OS = 'android';
    DashX.processURL('https://example.com');
    expect(mockNativeModule.processURL).not.toHaveBeenCalled();
    Platform.OS = 'ios';
  });
});

// --- trackNotificationNavigation ---

describe('trackNotificationNavigation', () => {
  it('calls native with deepLink action', () => {
    DashX.trackNotificationNavigation(
      { type: 'deepLink', url: 'https://example.com' },
      'notif-1'
    );
    expect(mockNativeModule.trackNotificationNavigation).toHaveBeenCalledWith(
      { type: 'deepLink', url: 'https://example.com' },
      'notif-1'
    );
  });

  it('calls native with screen action', () => {
    DashX.trackNotificationNavigation(
      { type: 'screen', name: 'Home', data: { ref: 'banner' } },
      'notif-2'
    );
    expect(mockNativeModule.trackNotificationNavigation).toHaveBeenCalledWith(
      { type: 'screen', name: 'Home', data: { ref: 'banner' } },
      'notif-2'
    );
  });

  it('calls native with richLanding action', () => {
    DashX.trackNotificationNavigation(
      { type: 'richLanding', url: 'https://promo.example.com' },
      'notif-3'
    );
    expect(mockNativeModule.trackNotificationNavigation).toHaveBeenCalledWith(
      { type: 'richLanding', url: 'https://promo.example.com' },
      'notif-3'
    );
  });

  it('calls native with clickAction action', () => {
    DashX.trackNotificationNavigation(
      { type: 'clickAction', action: 'OPEN_SETTINGS' },
      'notif-4'
    );
    expect(mockNativeModule.trackNotificationNavigation).toHaveBeenCalledWith(
      { type: 'clickAction', action: 'OPEN_SETTINGS' },
      'notif-4'
    );
  });

  it('calls native with null action when omitted', () => {
    DashX.trackNotificationNavigation(null, 'notif-5');
    expect(mockNativeModule.trackNotificationNavigation).toHaveBeenCalledWith(
      null,
      'notif-5'
    );
  });

  it('calls native with null for both when both omitted', () => {
    DashX.trackNotificationNavigation();
    expect(mockNativeModule.trackNotificationNavigation).toHaveBeenCalledWith(
      null,
      null
    );
  });

  it('throws if action is not an object', () => {
    expect(() => DashX.trackNotificationNavigation('bad')).toThrow(
      'action must be an object or null'
    );
  });

  it('no-ops on Android', () => {
    const { Platform } = require('react-native');
    Platform.OS = 'android';
    DashX.trackNotificationNavigation({ type: 'deepLink', url: 'https://example.com' });
    expect(mockNativeModule.trackNotificationNavigation).not.toHaveBeenCalled();
    Platform.OS = 'ios';
  });
});

// --- requestNotificationPermission / getNotificationPermissionStatus ---

describe('requestNotificationPermission', () => {
  it('calls native requestNotificationPermission', () => {
    mockNativeModule.requestNotificationPermission.mockResolvedValue(2);
    const result = DashX.requestNotificationPermission();
    expect(mockNativeModule.requestNotificationPermission).toHaveBeenCalled();
    return expect(result).resolves.toBe(2);
  });
});

describe('getNotificationPermissionStatus', () => {
  it('calls native getNotificationPermissionStatus', () => {
    mockNativeModule.getNotificationPermissionStatus.mockResolvedValue(1);
    const result = DashX.getNotificationPermissionStatus();
    expect(mockNativeModule.getNotificationPermissionStatus).toHaveBeenCalled();
    return expect(result).resolves.toBe(1);
  });
});

// --- onLinkReceived ---

describe('onLinkReceived', () => {
  it('throws if callback is not a function', () => {
    expect(() => DashX.onLinkReceived('not a function')).toThrow(
      'callback must be a function'
    );
  });

  it('registers a listener for linkReceived events', () => {
    const callback = jest.fn();
    const subscription = DashX.onLinkReceived(callback);
    expect(mockAddListener).toHaveBeenCalledWith('linkReceived', callback);
    expect(subscription).toBeDefined();
  });
});
