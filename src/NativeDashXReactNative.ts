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
  unsubscribe(): void;
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
  requestNotificationPermission(): Promise<number>;
  getNotificationPermissionStatus(): Promise<number>;

  addListener(eventName: string): void;
  removeListeners(count: number): void;
}

export default TurboModuleRegistry.get<Spec>('DashXReactNative');
