#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(DashXReactNative, RCTEventEmitter)

RCT_EXTERN_METHOD(configure:(NSDictionary *)options);

RCT_EXTERN_METHOD(identify:(NSDictionary *)options);

RCT_EXTERN_METHOD(setIdentity:(NSString *)uid token:(NSString *)token);

RCT_EXTERN_METHOD(track:(NSString *)event data:(NSDictionary * _Nullable)data);

RCT_EXTERN_METHOD(screen:(NSString *)screenName data:(NSDictionary * _Nullable)data);

RCT_EXTERN_METHOD(fetchStoredPreferences:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(saveStoredPreferences:(NSDictionary *)preferenceData resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);

RCT_EXTERN_METHOD(reset);

RCT_EXTERN_METHOD(subscribe);

RCT_EXTERN_METHOD(unsubscribe);

RCT_EXTERN_METHOD(setLogLevel:(int *)level);

@end
