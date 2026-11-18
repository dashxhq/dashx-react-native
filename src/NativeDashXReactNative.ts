import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  configure(options: Object): void;
  identify(options: Object | null): void;
  setIdentity(uid: string | null, token: string | null): void;
  reset(): void;
  track(event: string, data: Object | null): void;
  screen(screenName: string, data: Object | null): void;
  fetchRecord(urn: string, options: Object | null): Promise<Object>;
  searchRecords(resource: string, options: Object | null): Promise<Object[]>;
  fetchStoredPreferences(): Promise<Object>;
  saveStoredPreferences(preferenceData: Object): Promise<Object>;
  subscribe(): void;
  unsubscribe(): Promise<Object>;
  setLogLevel(level: number): void;
  uploadAsset(
    filePath: string,
    resource: string,
    attribute: string
  ): Promise<Object>;
  fetchAsset(assetId: string): Promise<Object>;
  enableLifecycleTracking(): void;
  enableAdTracking(): void;
  processURL(
    url: string,
    source: string | null,
    forwardToLinkHandler: boolean
  ): void;
  trackNotificationNavigation(
    action: Object | null,
    notificationId: string | null
  ): void;
  requestNotificationPermission(fallbackToSettings: boolean): Promise<number>;
  getNotificationPermissionStatus(): Promise<number>;

  chatOpenConversation(
    leaseId: string,
    chatIdentityId: string,
    conversationId: string
  ): void;
  chatCloseConversation(leaseId: string): void;
  chatSetConversationVisible(leaseId: string, visible: boolean): void;
  chatSendMessage(leaseId: string, content: Object): Promise<Object>;
  chatLoadPreviousPage(leaseId: string, requestId: number): void;
  chatFetchConversations(
    chatIdentityId: string,
    options: Object | null
  ): Promise<Object[]>;
  chatFetchConversation(
    chatIdentityId: string,
    conversationId: string
  ): Promise<Object>;
  chatSummarizeConversations(
    chatIdentityId: string,
    options: Object | null
  ): Promise<number>;
  chatSummarizeUnread(chatIdentityId: string): Promise<number>;
  chatResolveConversation(
    chatIdentityId: string,
    conversationId: string
  ): Promise<Object>;

  addListener(eventName: string): void;
  removeListeners(count: number): void;
}

export default TurboModuleRegistry.get<Spec>('DashXReactNative');
