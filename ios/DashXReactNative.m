#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(DashXReactNative, RCTEventEmitter)
+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

RCT_EXTERN_METHOD(configure:(NSDictionary *)options)
RCT_EXTERN_METHOD(identify:)
RCT_EXTERN_METHOD(setIdentity:(nonnull NSString *)uid token:(nonnull NSString *)token)
RCT_EXTERN_METHOD(reset)
RCT_EXTERN_METHOD(track:(NSString *)event data:(nullable NSDictionary *)data)
RCT_EXTERN_METHOD(screen:(NSString *)event data:(nullable NSDictionary *)data)
RCT_EXTERN_METHOD(searchContent:(NSString *)contentType options:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(fetchContent:(NSString *)urn options:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(addItemToCart:(NSString *)itemId pricingId:(NSString *)pricingId quantity:(NSString *)quantity reset:(BOOL)reset custom:(NSDictionary *)custom resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(fetchCart:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(fetchStoredPreferences:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(saveStoredPreferences:(NSDictionary *)preferenceData resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(uploadExternalAsset:(NSDictionary *)file externalColumnId:(NSString *)externalColumnId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(externalAsset:(NSString *)assetId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(subscribe)
@end
