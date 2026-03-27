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
    select: jest.fn((obj) => obj.default || ''),
  },
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

  it('throws if token is missing', () => {
    expect(() => DashX.setIdentity('uid', null)).toThrow(
      'token is required'
    );
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
