#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(DashXReactNative, RCTEventEmitter)

RCT_EXTERN_METHOD(supportedEvents)
RCT_EXTERN_METHOD(configure:(NSDictionary *)options)
RCT_EXTERN_METHOD(identify:)
RCT_EXTERN_METHOD(setIdentity:(nonnull NSString *)uid token:(nonnull NSString *)token)
RCT_EXTERN_METHOD(reset)
RCT_EXTERN_METHOD(track:(NSString *)event data:(nullable NSDictionary *)data)
RCT_EXTERN_METHOD(screen:(NSString *)event data:(nullable NSDictionary *)data)
RCT_EXTERN_METHOD(fetchStoredPreferences:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(saveStoredPreferences:(NSDictionary *)preferenceData resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(subscribe)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
