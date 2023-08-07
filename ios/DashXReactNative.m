#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_REMAP_MODULE(DashXReactNative, DashXReactNative, RCTEventEmitter)

RCT_EXTERN_METHOD(configure:(NSDictionary *)options)

RCT_EXTERN_METHOD(identify:(NSDictionary *)options)

RCT_EXTERN_METHOD(setIdentity:(NSString *)uid token:(NSString *)token)

RCT_EXTERN_METHOD(track:(NSString *)event data:(NSDictionary *)data)

RCT_EXTERN_METHOD(screen:(NSString *)screenName data:(NSDictionary *)data)

RCT_EXTERN_METHOD(fetchStoredPreferences:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(saveStoredPreferences:(NSDictionary *)preferenceData resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(reset)

RCT_EXTERN_METHOD(subscribe)

RCT_EXTERN_METHOD(unsubscribe)

@end
