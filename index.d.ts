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

export interface ProcessURLOptions {
  source?: string;
  forwardToLinkHandler?: boolean;
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
   * Set user identity using a UID and authentication token.
   */
  setIdentity(uid: string, token?: string | null): void;

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
   */
  unsubscribe(): void;

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
   * Register a listener for incoming push notification messages.
   * Returns a subscription that can be removed via `.remove()`.
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
   * Enable automatic app lifecycle event tracking (iOS only).
   */
  enableLifecycleTracking(): void;

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
   * Resolves with a NotificationPermissionStatus integer.
   */
  requestNotificationPermission(): Promise<NotificationPermissionStatus>;

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
}

declare const DashX: DashXInstance;
export default DashX;
