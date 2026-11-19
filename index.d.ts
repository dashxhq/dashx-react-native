import { EmitterSubscription } from 'react-native';

/**
 * Error codes returned by native SDKs in promise rejections.
 * Consistent across iOS and Android.
 */
export enum DashXErrorCode {
  /** An unspecified error occurred. */
  EUNSPECIFIED = 'EUNSPECIFIED',
  /** The operation is not supported on this platform. */
  EUNSUPPORTED = 'EUNSUPPORTED',
}

export interface ConfigureOptions {
  publicKey: string;
  baseURI?: string;
  targetEnvironment?: string;
}

export interface IdentifyOptions {
  firstName?: string;
  lastName?: string;
  email?: string;
  phone?: string;
  [key: string]: string | undefined;
}

export type LogLevel = 0 | 1 | 2;

export interface FetchRecordOptions {
  preview?: boolean;
  language?: string;
  fields?: Record<string, unknown>[];
  include?: Record<string, unknown>[];
  exclude?: Record<string, unknown>[];
}

export interface SearchRecordsOptions {
  filter?: Record<string, unknown>;
  order?: Record<string, unknown>[];
  limit?: number;
  page?: number;
  preview?: boolean;
  language?: string;
  fields?: Record<string, unknown>[];
  include?: Record<string, unknown>[];
  exclude?: Record<string, unknown>[];
}

export interface AssetData {
  status?: string;
  url?: string;
  playbackIds?: { id?: string; policy?: string }[];
}

export interface AssetResponse {
  status?: string;
  data?: { asset?: AssetData };
}

/**
 * Mirrors UNAuthorizationStatus integer values:
 * 0 = notDetermined, 1 = denied, 2 = authorized, 3 = provisional, 4 = ephemeral
 */
export type NotificationPermissionStatus = 0 | 1 | 2 | 3 | 4;

export interface NotificationMessage {
  [key: string]: unknown;
}

export type NavigationAction =
  | { type: 'deepLink'; url: string }
  | { type: 'screen'; name: string; data?: Record<string, string> }
  | { type: 'richLanding'; url: string }
  | { type: 'clickAction'; action: string };

export interface NotificationClickedEvent {
  notification: NotificationMessage;
  action: NavigationAction | null;
  actionIdentifier: string;
}

export interface ProcessURLOptions {
  source?: string;
  forwardToLinkHandler?: boolean;
}

export interface NavigationRouteLike {
  name: string;
  /** Identifies the route instance; React Navigation always sets it. */
  key?: string;
  params?: object;
}

/**
 * The subset of a React Navigation `NavigationContainer` ref used by
 * `trackNavigation`, so this package does not depend on `@react-navigation/*`.
 */
export interface NavigationContainerLike {
  addListener(event: 'state', callback: (event: unknown) => void): () => void;
  getCurrentRoute(): NavigationRouteLike | undefined;
  isReady?(): boolean;
}

/** One chat message, from history or a live update alike. */
export interface ChatMessage {
  id: string;
  conversationId: string;
  /** Raw server key. Prefer `clientMessageId` to match a message you sent. */
  externalUid: string | null;
  /**
   * The id this visitor message was sent with, or `null` for agent, AI and
   * system messages. A failed `sendMessage` reports the same id on its error.
   */
  clientMessageId: string | null;
  senderId: string | null;
  /**
   * `user` for the visitor's own message (compare ignoring case); anything
   * else, or `null`, is an agent or AI reply.
   */
  aiRole: string | null;
  turnSeq: number;
  /** The message body, e.g. `{ text: 'Hello' }`. */
  renderedContent: Record<string, unknown>;
  createdAt: string | null;
  sentAt: string | null;
}

/** An agent reply while it is generated, for a deployment that streams replies. */
export interface ChatStreamingReply {
  /** The turn being answered: the visitor message's `turnSeq`. */
  turnSeq: number;
  /** The reply text received so far. */
  text: string;
  /** Generation is over and the stored reply is on its way. */
  isComplete: boolean;
}

/**
 * `code` is the backend's error code for a GraphQL error (`UNAUTHORIZED`,
 * `FORBIDDEN`, `NOT_FOUND`, `UNPROCESSABLE_ENTITY`, ...) or `GRAPHQL_ERROR`
 * when it gave none; otherwise `NETWORK_ERROR`, `SESSION_ENDED`,
 * `SUBSCRIPTION_FAILED`, `NOT_IDENTIFIED`, `NOT_CONFIGURED` (Android only) or
 * `EUNSPECIFIED`.
 */
export interface ChatError {
  code: string;
  message: string;
}

export type ConversationState =
  | { status: 'loading' }
  | {
      status: 'ready';
      /** Oldest first. */
      messages: ChatMessage[];
      /** `loadPreviousPage` still has history to fetch. */
      hasOlderMessages: boolean;
      /** The agent reply being generated, or `null`. */
      streamingReply: ChatStreamingReply | null;
    }
  | { status: 'error'; error: ChatError };

export interface ChatConversationSummary {
  conversationId: string;
  category: string;
  context: {
    kind: string;
    subtype: string | null;
    id: string;
    reference: string | null;
    name: string | null;
  } | null;
  topic: { id: string; label: string } | null;
  status: string;
  title: string;
  lastMessagePreview: string | null;
  lastMessageAt: string | null;
  lastSenderKind: string | null;
  activityAt: string;
  assignedGroups: Array<{ id: string; name: string }>;
  /** Messages the visitor has not read yet. */
  unreadCount: number;
}

export interface ChatSubscription {
  remove(): void;
}

/** The error a failed `sendMessage` rejects with. */
export interface ChatSendError extends Error {
  code: string;
  /** The id the message was sent with; absent when nothing was sent. */
  clientMessageId?: string;
}

/**
 * A handle on one open conversation. Every `openConversation` returns a new
 * one; the connection and history are shared per conversation and released
 * when the last handle is closed. Always `close()` it, e.g. on unmount.
 */
export interface DashXConversation {
  readonly conversationId: string;

  /** The latest state; `{ status: 'loading' }` until the first one arrives. */
  readonly state: ConversationState;

  /**
   * Listen for state changes. The listener is also called right away with the
   * current state. `close()` removes every listener.
   */
  addStateListener(
    listener: (state: ConversationState) => void
  ): ChatSubscription;

  /**
   * Fires when the session ends underneath this conversation: the user
   * changed or `reset()` was called. The state becomes an error with code
   * `SESSION_ENDED`; close this conversation and open a new one to continue.
   */
  onTerminated(listener: (reason: 'sessionEnded') => void): ChatSubscription;

  /**
   * Send a visitor message. `content` is `{ text: '<1–4096 characters>' }`.
   * Resolves with the stored message, which also appears in `state`. Rejects
   * with a `ChatSendError`; after `close()` or once the session has ended
   * nothing is sent and the code is `SESSION_ENDED`.
   */
  sendMessage(content: { text: string }): Promise<ChatMessage>;

  /**
   * Fetch the page of history before the oldest loaded message; it arrives as
   * a state change. On failure the current messages stay and `onError` is called.
   */
  loadPreviousPage(onError?: (error: ChatError) => void): void;

  /**
   * Say whether this conversation is on screen. While it is, new messages are
   * marked read and its push notifications are not shown.
   */
  setVisible(visible: boolean): void;

  /** Release this handle. Safe to call more than once. */
  close(): void;
}

export interface FetchChatConversationsOptions {
  limit?: number;
  page?: number;
  statuses?: string[];
  /** Equality filter on conversation properties (key to scalar value). */
  properties?: Record<string, unknown>;
}

export interface SummarizeChatConversationsOptions {
  statuses?: string[];
  properties?: Record<string, unknown>;
}

/**
 * In-app chat for one chat identity. Conversations are created by your
 * server, which returns the conversation id together with the chat identity id.
 */
export interface DashXChat {
  readonly chatIdentityId: string;

  openConversation(conversationId: string): DashXConversation;

  /** One page of the visitor's conversations. */
  fetchConversations(
    options?: FetchChatConversationsOptions
  ): Promise<ChatConversationSummary[]>;

  fetchConversation(conversationId: string): Promise<ChatConversationSummary>;

  /** The number of conversations matching the filter, for paging. */
  summarizeConversations(
    options?: SummarizeChatConversationsOptions
  ): Promise<number>;

  /**
   * The number of unread messages across conversations. It is not pushed:
   * ask again when the app returns to the foreground or a push arrives.
   */
  summarizeUnread(): Promise<number>;

  /**
   * End the chat as the visitor. Resolves with the updated summary; a later
   * message reopens the conversation.
   */
  resolveConversation(conversationId: string): Promise<ChatConversationSummary>;
}

export interface DashXInstance {
  /**
   * Initialize the SDK with your public key and optional configuration.
   * Call this as early as possible, e.g. in your root component.
   */
  configure(options: ConfigureOptions): void;

  /**
   * Identify the current user with traits such as name and email.
   */
  identify(options: IdentifyOptions): void;

  /**
   * Set user identity using a UID and authentication token. Both are
   * nullable: a `null` uid clears it, but a `null` token for the current uid
   * keeps the token already held (`reset()` clears it). Empty strings are
   * forwarded as-is (no coercion to `null`).
   */
  setIdentity(uid: string | null, token?: string | null): void;

  /**
   * Clear the current user identity and reset SDK state.
   */
  reset(): void;

  /**
   * Track a named event with optional metadata.
   */
  track(event: string, data?: Record<string, unknown>): void;

  /**
   * Track a screen view with optional metadata.
   */
  screen(screenName: string, data?: Record<string, unknown>): void;

  /**
   * Fetch a single record by URN (e.g. "article/123") with optional preview, language, fields, include, exclude.
   * Returns a promise resolving to the record object.
   */
  fetchRecord(
    urn: string,
    options?: FetchRecordOptions
  ): Promise<Record<string, unknown>>;

  /**
   * Search records by resource with optional filter, order, limit, preview, language, fields, include, exclude.
   * Returns a promise resolving to an array of record objects.
   */
  searchRecords(
    resource: string,
    options?: SearchRecordsOptions
  ): Promise<Record<string, unknown>[]>;

  /**
   * Subscribe the current device to push notifications.
   */
  subscribe(): void;

  /**
   * Unsubscribe the current device from push notifications.
   *
   * Resolves with `{ success: true }` when the backend found and updated a
   * matching subscribed contact, or `{ success: false }` when no match was
   * found (anonymous UID rotated since subscribe, FCM token is stale,
   * contact already unsubscribed, or this device never subscribed in the
   * current session). The device ends up unsubscribed in both cases; the
   * boolean is useful for diagnostics and analytics.
   *
   * Rejects on transport / SDK-state failures: native module not configured,
   * Firebase token-delete failure, GraphQL or network error.
   */
  unsubscribe(): Promise<{ success: boolean }>;

  /**
   * Fetch stored notification preferences for the current user.
   */
  fetchStoredPreferences(): Promise<Record<string, unknown>>;

  /**
   * Save notification preferences for the current user.
   */
  saveStoredPreferences(
    data: Record<string, unknown>
  ): Promise<Record<string, unknown>>;

  /**
   * Set SDK log verbosity. 0 = off, 1 = errors, 2 = debug.
   */
  setLogLevel(level: LogLevel): void;

  /**
   * Register a listener for incoming push notifications.
   * Returns a subscription that can be removed via `.remove()`.
   */
  onPushNotificationReceived(
    callback: (message: NotificationMessage) => void
  ): EmitterSubscription;

  /**
   * @deprecated Use `onPushNotificationReceived` instead.
   * Will be removed in the next major version.
   */
  onMessageReceived(
    callback: (message: NotificationMessage) => void
  ): EmitterSubscription;

  /**
   * Upload a local file to DashX. Returns an AssetResponse with the asset status and URL.
   * @param filePath Absolute path to the local file.
   */
  uploadAsset(
    filePath: string,
    resource: string,
    attribute: string
  ): Promise<AssetResponse>;

  /**
   * Fetch details of a previously uploaded asset by its ID.
   */
  fetchAsset(assetId: string): Promise<AssetResponse>;

  /**
   * Enable automatic app lifecycle events (install, update, open, background)
   * on iOS and Android. Call after `configure`.
   */
  enableLifecycleTracking(): void;

  /**
   * Send a screen view for each React Navigation route change. Sends the
   * current route once the container is ready, then `screen(route.name)`
   * whenever a different route instance gains focus, told apart by
   * `route.key` (or the name, for a route without one). Pushing a second
   * instance of a screen, or going back to the first, is a new view; a params
   * change is not, and params are not sent. Returns a function that stops
   * tracking.
   *
   * Call it from `NavigationContainer`'s `onReady` so the first screen is
   * captured. A ref from `useNavigationContainerRef()` or
   * `createNavigationContainerRef()` may also be passed before the container
   * mounts.
   *
   * @example
   * const navigationRef = useNavigationContainerRef();
   *
   * <NavigationContainer
   *   ref={navigationRef}
   *   onReady={() => DashX.trackNavigation(navigationRef)}
   * >
   *   ...
   * </NavigationContainer>
   */
  trackNavigation(
    navigationRef:
      | NavigationContainerLike
      | { current: NavigationContainerLike | null }
  ): () => void;

  /**
   * Enable IDFA/ATT ad tracking and request the App Tracking Transparency permission (iOS only).
   */
  enableAdTracking(): void;

  /**
   * Track a deep link open event and optionally forward the URL to the link handler (iOS only).
   * @param url The deep link URL string.
   * @param options.source Optional attribution source (e.g. "universal_link", "notification").
   * @param options.forwardToLinkHandler Whether to forward to the link handler callback (default: true).
   */
  processURL(url: string, options?: ProcessURLOptions): void;

  /**
   * Track a notification navigation event when the user taps a notification (iOS only).
   * @param action The navigation action taken, or null/undefined for default.
   * @param notificationId Optional notification ID to associate with the event.
   */
  trackNotificationNavigation(
    action?: NavigationAction | null,
    notificationId?: string
  ): void;

  /**
   * Request push notification permission from the user.
   *
   * @param options.fallbackToSettings — when `true`, if the user has previously
   *   granted or denied permission, opens the system notification settings
   *   page so they can enable Time Sensitive notifications (or re-enable
   *   notifications). Defaults to `false`. Use this to recover users who
   *   granted permission before the SDK started requesting `.timeSensitive`,
   *   since iOS won't silently add new options to an existing grant.
   *
   * Resolves with a NotificationPermissionStatus integer.
   */
  requestNotificationPermission(options?: {
    fallbackToSettings?: boolean
  }): Promise<NotificationPermissionStatus>;

  /**
   * Get the current push notification permission status without prompting.
   * Resolves with a NotificationPermissionStatus integer.
   */
  getNotificationPermissionStatus(): Promise<NotificationPermissionStatus>;

  /**
   * Register a listener for deep link / universal link events dispatched by the SDK.
   * Returns a subscription that can be removed via `.remove()`.
   */
  onLinkReceived(callback: (url: string) => void): EmitterSubscription;

  /**
   * In-app chat for the chat identity your server issued. Requires an
   * identity token: call `setIdentity(uid, token)` first.
   */
  chat(chatIdentityId: string): DashXChat;

  /**
   * Register a listener for notification tap events. Fired when the user taps
   * a DashX notification or one of its action buttons. The callback receives
   * the full notification payload, the resolved `NavigationAction` (parsed
   * from the payload; `null` if no navigation intent could be resolved), and
   * the raw `actionIdentifier` from `UNNotificationResponse`.
   * Returns a subscription that can be removed via `.remove()`.
   */
  onNotificationClicked(
    callback: (event: NotificationClickedEvent) => void
  ): EmitterSubscription;
}

declare const DashX: DashXInstance;
export default DashX;
