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
