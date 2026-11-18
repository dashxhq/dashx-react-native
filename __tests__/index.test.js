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
  chatOpenConversation: jest.fn(),
  chatCloseConversation: jest.fn(),
  chatSetConversationVisible: jest.fn(),
  chatSendMessage: jest.fn(),
  chatLoadPreviousPage: jest.fn(),
  chatFetchConversations: jest.fn(),
  chatFetchConversation: jest.fn(),
  chatSummarizeConversations: jest.fn(),
  chatSummarizeUnread: jest.fn(),
  chatResolveConversation: jest.fn(),
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

  it('passes null uid through to native', () => {
    DashX.setIdentity(null, 'token');
    expect(mockNativeModule.setIdentity).toHaveBeenCalledWith(null, 'token');
  });

  it('normalizes undefined uid to null', () => {
    DashX.setIdentity(undefined, 'token');
    expect(mockNativeModule.setIdentity).toHaveBeenCalledWith(null, 'token');
  });

  it('passes empty-string uid through to native without coercing to null', () => {
    DashX.setIdentity('', 'token');
    expect(mockNativeModule.setIdentity).toHaveBeenCalledWith('', 'token');
  });

  it('throws if uid is not a string or null', () => {
    expect(() => DashX.setIdentity(42, 'token')).toThrow(
      'uid must be a string or null'
    );
  });

  it('passes null token through to native', () => {
    DashX.setIdentity('uid', null);
    expect(mockNativeModule.setIdentity).toHaveBeenCalledWith('uid', null);
  });

  it('passes empty-string token through to native without coercing to null', () => {
    DashX.setIdentity('uid', '');
    expect(mockNativeModule.setIdentity).toHaveBeenCalledWith('uid', '');
  });

  it('passes undefined token as null to native', () => {
    DashX.setIdentity('uid');
    expect(mockNativeModule.setIdentity).toHaveBeenCalledWith('uid', null);
  });

  it('throws if token is not a string or null', () => {
    expect(() => DashX.setIdentity('uid', 42)).toThrow(
      'token must be a string or null'
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
  it('calls native unsubscribe and forwards the resolved success payload', async () => {
    mockNativeModule.unsubscribe.mockResolvedValue({ success: true });
    const result = await DashX.unsubscribe();
    expect(mockNativeModule.unsubscribe).toHaveBeenCalled();
    expect(result).toEqual({ success: true });
  });

  it('forwards `success: false` (the no-matching-contact non-error outcome)', async () => {
    mockNativeModule.unsubscribe.mockResolvedValue({ success: false });
    const result = await DashX.unsubscribe();
    expect(result).toEqual({ success: false });
  });

  it('propagates the native rejection to the caller', async () => {
    mockNativeModule.unsubscribe.mockRejectedValue(new Error('EUNSPECIFIED'));
    await expect(DashX.unsubscribe()).rejects.toThrow('EUNSPECIFIED');
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

// --- onPushNotificationReceived ---

describe('onPushNotificationReceived', () => {
  it('throws if callback is not a function', () => {
    expect(() => DashX.onPushNotificationReceived('not a function')).toThrow(
      'callback must be a function'
    );
  });

  it('registers a listener for messageReceived events', () => {
    const callback = jest.fn();
    const subscription = DashX.onPushNotificationReceived(callback);
    expect(mockAddListener).toHaveBeenCalledWith('messageReceived', callback);
    expect(subscription).toBeDefined();
  });
});

// --- onMessageReceived (deprecated alias) ---

describe('onMessageReceived (deprecated)', () => {
  let warnSpy;

  beforeEach(() => {
    warnSpy = jest.spyOn(console, 'warn').mockImplementation(() => {});
  });

  afterEach(() => {
    warnSpy.mockRestore();
  });

  it('registers a listener and emits a deprecation warning on first call', () => {
    const callback = jest.fn();
    const subscription = DashX.onMessageReceived(callback);
    expect(mockAddListener).toHaveBeenCalledWith('messageReceived', callback);
    expect(subscription).toBeDefined();
    expect(warnSpy).toHaveBeenCalledWith(
      expect.stringContaining('onMessageReceived is deprecated')
    );
  });

  it('warns only once across repeated calls', () => {
    warnSpy.mockClear();
    DashX.onMessageReceived(jest.fn());
    DashX.onMessageReceived(jest.fn());
    DashX.onMessageReceived(jest.fn());
    // The first call across the whole test run already consumed the one-shot
    // warning (from the previous test). No new warnings should fire.
    expect(warnSpy).not.toHaveBeenCalled();
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

// --- enableLifecycleTracking ---

describe('enableLifecycleTracking', () => {
  it.each(['ios', 'android'])('calls native on %s', (os) => {
    const { Platform } = require('react-native');
    Platform.OS = os;
    DashX.enableLifecycleTracking();
    expect(mockNativeModule.enableLifecycleTracking).toHaveBeenCalledTimes(1);
    Platform.OS = 'ios';
  });
});

// --- trackNavigation ---

function createNavigationRef({ ready = true, routeName = 'Home' } = {}) {
  const listeners = [];
  const ref = {
    ready,
    route: routeName ? { name: routeName } : undefined,
    addListener: jest.fn((event, callback) => {
      listeners.push({ event, callback });
      return jest.fn(() => {
        const index = listeners.findIndex((l) => l.callback === callback);
        if (index !== -1) listeners.splice(index, 1);
      });
    }),
    getCurrentRoute: jest.fn(() => ref.route),
    isReady: jest.fn(() => ref.ready),
    navigate(name, params, key) {
      ref.route = { name, params, key };
      ref.emitState();
    },
    emitState() {
      listeners
        .filter((l) => l.event === 'state')
        .forEach((l) => l.callback({ data: { state: {} } }));
    },
  };
  return ref;
}

describe('trackNavigation', () => {
  it('sends the current route once when the ref is ready', () => {
    const ref = createNavigationRef();
    DashX.trackNavigation(ref);
    expect(mockNativeModule.screen).toHaveBeenCalledTimes(1);
    expect(mockNativeModule.screen).toHaveBeenCalledWith('Home', null);
    expect(ref.addListener).toHaveBeenCalledWith('state', expect.any(Function));
  });

  it('waits for readiness before sending the first screen', () => {
    const ref = createNavigationRef({ ready: false });
    DashX.trackNavigation(ref);
    expect(ref.getCurrentRoute).not.toHaveBeenCalled();
    expect(mockNativeModule.screen).not.toHaveBeenCalled();

    ref.ready = true;
    ref.emitState();
    expect(mockNativeModule.screen).toHaveBeenCalledTimes(1);
    expect(mockNativeModule.screen).toHaveBeenCalledWith('Home', null);
  });

  it('does not resend when the route name is unchanged', () => {
    const ref = createNavigationRef();
    DashX.trackNavigation(ref);
    ref.emitState();
    ref.navigate('Home', { tab: 'feed' });
    expect(mockNativeModule.screen).toHaveBeenCalledTimes(1);
  });

  it('sends the new route name on a route change, without params', () => {
    const ref = createNavigationRef();
    DashX.trackNavigation(ref);
    ref.navigate('Profile', { userId: 'u_1' });
    ref.navigate('Home');
    expect(mockNativeModule.screen.mock.calls).toEqual([
      ['Home', null],
      ['Profile', null],
      ['Home', null],
    ]);
  });

  it('sends a view per route instance when routes have keys, even with the same name', () => {
    const ref = createNavigationRef({ routeName: null });
    DashX.trackNavigation(ref);
    ref.navigate('Topic', { id: 'a' }, 'Topic-a');
    ref.navigate('Topic', { id: 'b' }, 'Topic-b');
    ref.navigate('Topic', { id: 'a' }, 'Topic-a');
    expect(mockNativeModule.screen.mock.calls).toEqual([
      ['Topic', null],
      ['Topic', null],
      ['Topic', null],
    ]);
  });

  it('does not resend when the focused route keeps its key', () => {
    const ref = createNavigationRef({ routeName: null });
    DashX.trackNavigation(ref);
    ref.navigate('Topic', { id: 'a' }, 'Topic-a');
    ref.emitState();
    ref.navigate('Topic', { id: 'a', tab: 'notes' }, 'Topic-a');
    expect(mockNativeModule.screen).toHaveBeenCalledTimes(1);
  });

  it('stops sending after unsubscribe', () => {
    const ref = createNavigationRef();
    const stop = DashX.trackNavigation(ref);
    stop();
    ref.navigate('Profile');
    expect(mockNativeModule.screen).toHaveBeenCalledTimes(1);
  });

  it('resolves a plain React ref through current', () => {
    const navigation = createNavigationRef();
    DashX.trackNavigation({ current: navigation });
    navigation.navigate('Profile');
    expect(mockNativeModule.screen.mock.calls).toEqual([
      ['Home', null],
      ['Profile', null],
    ]);
  });

  it('warns and returns a no-op when a plain ref has a null current', () => {
    const warn = jest.spyOn(console, 'warn').mockImplementation(() => {});
    const stop = DashX.trackNavigation({ current: null });
    expect(warn).toHaveBeenCalledWith(
      expect.stringContaining('navigationRef.current is null')
    );
    expect(() => stop()).not.toThrow();
    expect(mockNativeModule.screen).not.toHaveBeenCalled();
    warn.mockRestore();
  });

  it('throws on a value that is not a navigation ref', () => {
    expect(() => DashX.trackNavigation(null)).toThrow(
      'navigationRef must be a NavigationContainer ref'
    );
    expect(() => DashX.trackNavigation({ current: {} })).toThrow(
      'navigationRef must be a NavigationContainer ref'
    );
  });
});

// --- in-app chat ---

describe('chat', () => {
  const emitChatEvent = (event) => {
    const call = mockAddListener.mock.calls.find(
      ([name]) => name === 'chatConversationEvent'
    );
    call[1](event);
  };
  const leaseIdOf = (callIndex = 0) =>
    mockNativeModule.chatOpenConversation.mock.calls[callIndex][0];
  const ready = (ids) => ({
    status: 'ready',
    messages: ids.map((id) => ({ id })),
    hasOlderMessages: false,
    streamingReply: null,
  });

  // The event subscription is made once per JS runtime, so it has to survive
  // the file-wide clearAllMocks.
  let chatListenerCall = null;
  beforeEach(() => {
    if (chatListenerCall) mockAddListener.mock.calls.push(chatListenerCall);
  });
  const open = (conversationId = 'conv-1') => {
    const conversation = DashX.chat('identity-1').openConversation(
      conversationId
    );
    chatListenerCall =
      chatListenerCall ||
      mockAddListener.mock.calls.find(
        ([name]) => name === 'chatConversationEvent'
      );
    return conversation;
  };

  it('throws without a chat identity id', () => {
    expect(() => DashX.chat()).toThrow('chatIdentityId is required');
    expect(() => DashX.chat(42)).toThrow('chatIdentityId is required');
  });

  it('throws without a conversation id', () => {
    const chat = DashX.chat('identity-1');
    expect(() => chat.openConversation('')).toThrow(
      'conversationId is required'
    );
    expect(() => chat.fetchConversation()).toThrow('conversationId is required');
    expect(() => chat.resolveConversation(null)).toThrow(
      'conversationId is required'
    );
  });

  it('opens a native lease per conversation, each with its own id', () => {
    const first = open('conv-1');
    const second = open('conv-1');

    expect(first.conversationId).toBe('conv-1');
    expect(mockNativeModule.chatOpenConversation).toHaveBeenCalledTimes(2);
    expect(mockNativeModule.chatOpenConversation).toHaveBeenCalledWith(
      leaseIdOf(0),
      'identity-1',
      'conv-1'
    );
    expect(leaseIdOf(0)).not.toBe(leaseIdOf(1));
    first.close();
    second.close();
  });

  it('starts loading and replays the current state to a new listener', () => {
    const conversation = open();
    const listener = jest.fn();

    expect(conversation.state).toEqual({ status: 'loading' });
    conversation.addStateListener(listener);
    expect(listener).toHaveBeenCalledWith({ status: 'loading' });

    emitChatEvent({ leaseId: leaseIdOf(), type: 'state', state: ready(['m1']) });
    expect(conversation.state).toEqual(ready(['m1']));
    expect(listener).toHaveBeenLastCalledWith(ready(['m1']));

    const late = jest.fn();
    conversation.addStateListener(late);
    expect(late).toHaveBeenCalledWith(ready(['m1']));
    conversation.close();
  });

  it('applies a reply-only update to the state it already holds', () => {
    const conversation = open();
    const listener = jest.fn();
    conversation.addStateListener(listener);
    emitChatEvent({ leaseId: leaseIdOf(), type: 'state', state: ready(['m1']) });
    const { messages } = conversation.state;
    const reply = { turnSeq: 2, text: 'Hel', isComplete: false };

    emitChatEvent({
      leaseId: leaseIdOf(),
      type: 'streamingReply',
      streamingReply: reply,
    });
    expect(conversation.state).toEqual({
      ...ready(['m1']),
      streamingReply: reply,
    });
    expect(conversation.state.messages).toBe(messages);
    expect(listener).toHaveBeenLastCalledWith(conversation.state);

    emitChatEvent({
      leaseId: leaseIdOf(),
      type: 'streamingReply',
      streamingReply: null,
    });
    expect(conversation.state).toEqual(ready(['m1']));
    expect(listener).toHaveBeenLastCalledWith(ready(['m1']));
    conversation.close();
  });

  it('ignores a reply-only update before a ready state', () => {
    const conversation = open();
    const listener = jest.fn();
    conversation.addStateListener(listener);
    listener.mockClear();

    emitChatEvent({
      leaseId: leaseIdOf(),
      type: 'streamingReply',
      streamingReply: { turnSeq: 2, text: 'Hel', isComplete: false },
    });

    expect(conversation.state).toEqual({ status: 'loading' });
    expect(listener).not.toHaveBeenCalled();
    conversation.close();
  });

  it('delivers a state only to the lease it belongs to', () => {
    const first = open('conv-1');
    const second = open('conv-2');

    emitChatEvent({ leaseId: leaseIdOf(1), type: 'state', state: ready(['m2']) });

    expect(first.state).toEqual({ status: 'loading' });
    expect(second.state).toEqual(ready(['m2']));
    first.close();
    second.close();
  });

  it('stops delivering to a removed listener', () => {
    const conversation = open();
    const listener = jest.fn();
    const subscription = conversation.addStateListener(listener);
    listener.mockClear();

    subscription.remove();
    emitChatEvent({ leaseId: leaseIdOf(), type: 'state', state: ready([]) });

    expect(listener).not.toHaveBeenCalled();
    conversation.close();
  });

  it('keeps delivering when a listener throws', () => {
    const errorSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
    const conversation = open();
    const listener = jest.fn();
    let armed = false;
    conversation.addStateListener(() => {
      if (armed) throw new Error('boom');
    });
    conversation.addStateListener(listener);
    armed = true;

    emitChatEvent({ leaseId: leaseIdOf(), type: 'state', state: ready([]) });

    expect(listener).toHaveBeenLastCalledWith(ready([]));
    conversation.close();
    errorSpy.mockRestore();
  });

  it('reports a session that ended underneath the lease', () => {
    const conversation = open();
    const listener = jest.fn();
    conversation.onTerminated(listener);

    emitChatEvent({
      leaseId: leaseIdOf(),
      type: 'terminated',
      reason: 'sessionEnded',
    });

    expect(listener).toHaveBeenCalledWith('sessionEnded');
    conversation.close();
  });

  it('sends a message and resolves with the committed one', async () => {
    const conversation = open();
    mockNativeModule.chatSendMessage.mockResolvedValue({ id: 'm1' });

    await expect(conversation.sendMessage({ text: 'Hello' })).resolves.toEqual({
      id: 'm1',
    });
    expect(mockNativeModule.chatSendMessage).toHaveBeenCalledWith(leaseIdOf(), {
      text: 'Hello',
    });
    conversation.close();
  });

  it('reports the client message id of a failed send', async () => {
    const conversation = open();
    const failure = Object.assign(new Error('offline'), {
      code: 'NETWORK_ERROR',
      userInfo: { clientMessageId: 'client-1' },
    });
    mockNativeModule.chatSendMessage.mockRejectedValue(failure);

    await expect(conversation.sendMessage({ text: 'Hello' })).rejects.toMatchObject(
      { code: 'NETWORK_ERROR', clientMessageId: 'client-1' }
    );
    conversation.close();
  });

  it('throws when the message content is not an object', () => {
    const conversation = open();
    expect(() => conversation.sendMessage('Hello')).toThrow(
      'content must be an object'
    );
    expect(() => conversation.sendMessage(null)).toThrow(
      'content must be an object'
    );
    conversation.close();
  });

  it('reports a failed older page to the callback of that request', () => {
    const conversation = open();
    const first = jest.fn();
    const second = jest.fn();
    conversation.loadPreviousPage(first);
    conversation.loadPreviousPage(second);
    conversation.loadPreviousPage();

    expect(mockNativeModule.chatLoadPreviousPage).toHaveBeenCalledTimes(3);
    const [, secondRequestId] =
      mockNativeModule.chatLoadPreviousPage.mock.calls[1];
    const error = { code: 'NETWORK_ERROR', message: 'offline' };
    emitChatEvent({
      leaseId: leaseIdOf(),
      type: 'loadPreviousPageError',
      requestId: secondRequestId,
      error,
    });

    expect(first).not.toHaveBeenCalled();
    expect(second).toHaveBeenCalledWith(error);
    conversation.close();
  });

  it('forwards visibility as a boolean', () => {
    const conversation = open();
    conversation.setVisible(true);
    conversation.setVisible(undefined);

    expect(mockNativeModule.chatSetConversationVisible.mock.calls).toEqual([
      [leaseIdOf(), true],
      [leaseIdOf(), false],
    ]);
    conversation.close();
  });

  it('closes once and goes quiet afterwards', async () => {
    const conversation = open();
    const listener = jest.fn();
    conversation.addStateListener(listener);
    listener.mockClear();

    conversation.close();
    conversation.close();
    emitChatEvent({ leaseId: leaseIdOf(), type: 'state', state: ready(['m1']) });
    conversation.setVisible(true);
    conversation.loadPreviousPage();

    expect(mockNativeModule.chatCloseConversation).toHaveBeenCalledTimes(1);
    expect(mockNativeModule.chatCloseConversation).toHaveBeenCalledWith(
      leaseIdOf()
    );
    expect(listener).not.toHaveBeenCalled();
    expect(mockNativeModule.chatSetConversationVisible).not.toHaveBeenCalled();
    expect(mockNativeModule.chatLoadPreviousPage).not.toHaveBeenCalled();
    await expect(conversation.sendMessage({ text: 'Hello' })).rejects.toMatchObject(
      { code: 'SESSION_ENDED' }
    );
    expect(mockNativeModule.chatSendMessage).not.toHaveBeenCalled();
  });

  it('fetches conversations, leaving absent options out', () => {
    const chat = DashX.chat('identity-1');
    chat.fetchConversations({ limit: 20, page: undefined, statuses: ['ACTIVE'] });
    chat.fetchConversations();

    expect(mockNativeModule.chatFetchConversations.mock.calls).toEqual([
      ['identity-1', { limit: 20, statuses: ['ACTIVE'] }],
      ['identity-1', null],
    ]);
    expect(() => chat.fetchConversations('ACTIVE')).toThrow(
      'options must be an object'
    );
  });

  it('passes the identity to the identity-scoped operations', () => {
    const chat = DashX.chat('identity-1');
    chat.fetchConversation('conv-1');
    chat.summarizeConversations({ properties: { order: 'o1' }, limit: 5 });
    chat.summarizeUnread();
    chat.resolveConversation('conv-1');

    expect(mockNativeModule.chatFetchConversation).toHaveBeenCalledWith(
      'identity-1',
      'conv-1'
    );
    expect(mockNativeModule.chatSummarizeConversations).toHaveBeenCalledWith(
      'identity-1',
      { properties: { order: 'o1' } }
    );
    expect(mockNativeModule.chatSummarizeUnread).toHaveBeenCalledWith(
      'identity-1'
    );
    expect(mockNativeModule.chatResolveConversation).toHaveBeenCalledWith(
      'identity-1',
      'conv-1'
    );
  });
});
