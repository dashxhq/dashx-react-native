#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import "DashXReactNative.h"

@interface RCT_EXTERN_MODULE(DashXReactNative, RCTEventEmitter)
+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

RCT_EXTERN_METHOD(setLogLevel:(NSInteger *)to)
RCT_EXTERN_METHOD(setup:(NSDictionary *)options)
RCT_EXTERN_METHOD(identify:)
RCT_EXTERN_METHOD(setIdentity:(nonnull NSString *)uid (nonnull NSString *)token)
RCT_EXTERN_METHOD(reset)
RCT_EXTERN_METHOD(track:(NSString *)event data:(nullable NSDictionary *)data)
RCT_EXTERN_METHOD(searchContent:(NSString *)contentType options:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(fetchContent:(NSString *)urn options:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(addItemToCart:(NSString *)itemId pricingId:(NSString *)pricingId quantity:(NSString *)quantity reset:(BOOL)reset custom:(NSDictionary *)custom resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(fetchCart:resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(fetchStoredPreferences:resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(uploadExternalAsset:(NSDictionary *)file (NSString *)externalColumnId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(subscribe)
@end