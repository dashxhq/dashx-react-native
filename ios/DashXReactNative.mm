#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import "RNDashXReactNativeSpec.h"
#endif

@interface RCT_EXTERN_MODULE(DashXReactNative, RCTEventEmitter)

RCT_EXTERN_METHOD(configure:(NSDictionary *)options);

RCT_EXTERN_METHOD(identify:(NSDictionary *)options);

RCT_EXTERN_METHOD(setIdentity:(NSString * _Nullable)uid token:(NSString * _Nullable)token);

RCT_EXTERN_METHOD(track:(NSString *)event data:(NSDictionary * _Nullable)data);

RCT_EXTERN_METHOD(screen:(NSString *)screenName data:(NSDictionary * _Nullable)data);

RCT_EXTERN_METHOD(fetchRecord:(NSString *)urn options:(NSDictionary * _Nullable)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(searchRecords:(NSString *)resource options:(NSDictionary * _Nullable)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(fetchStoredPreferences:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(saveStoredPreferences:(NSDictionary *)preferenceData resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(reset);

RCT_EXTERN_METHOD(subscribe);

RCT_EXTERN_METHOD(unsubscribe);

RCT_EXTERN_METHOD(setLogLevel:(double)level);

RCT_EXTERN_METHOD(uploadAsset:(NSString *)filePath resource:(NSString *)resource attribute:(NSString *)attribute resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(fetchAsset:(NSString *)assetId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(enableLifecycleTracking);

RCT_EXTERN_METHOD(enableAdTracking);

RCT_EXTERN_METHOD(processURL:(NSString *)url source:(NSString * _Nullable)source forwardToLinkHandler:(BOOL)forwardToLinkHandler);

RCT_EXTERN_METHOD(trackNotificationNavigation:(NSDictionary * _Nullable)action notificationId:(NSString * _Nullable)notificationId);

RCT_EXTERN_METHOD(requestNotificationPermission:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(getNotificationPermissionStatus:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);

@end

#ifdef RCT_NEW_ARCH_ENABLED
@interface DashXReactNative () <NativeDashXReactNativeSpec>
@end

@implementation DashXReactNative (TurboModule)

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
  return std::make_shared<facebook::react::NativeDashXReactNativeSpecJSI>(params);
}

@end
#endif
