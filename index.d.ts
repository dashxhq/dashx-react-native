import { EmitterSubscription } from 'react-native';

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
  preview?: boolean;
  language?: string;
  fields?: Record<string, unknown>[];
  include?: Record<string, unknown>[];
  exclude?: Record<string, unknown>[];
}

export interface NotificationMessage {
  [key: string]: unknown;
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
  setIdentity(uid: string, token: string): void;

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
}

declare const DashX: DashXInstance;
export default DashX;
