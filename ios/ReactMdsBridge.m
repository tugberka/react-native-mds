//
//  ReactMdsBridge.m
//  RNMds
//
//  Created by Akdogan, Tugberk on 15/10/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ReactMds, NSObject)

RCT_EXTERN_METHOD(scan)
RCT_EXTERN_METHOD(stopScan)
RCT_EXTERN_METHOD(connect:(NSString *)address)
RCT_EXTERN_METHOD(disconnect:(NSString *)address)
RCT_EXTERN_METHOD(get:(NSString *)uri parameters:(NSDictionary *)parameters successCallback:(RCTResponseSenderBlock)successCallback errorCallback:(RCTResponseSenderBlock)errorCallback)
RCT_EXTERN_METHOD(put:(NSString *)uri parameters:(NSDictionary *)parameters successCallback:(RCTResponseSenderBlock)successCallback errorCallback:(RCTResponseSenderBlock)errorCallback)
RCT_EXTERN_METHOD(post:(NSString *)uri parameters:(NSDictionary *)parameters successCallback:(RCTResponseSenderBlock)successCallback errorCallback:(RCTResponseSenderBlock)errorCallback)
RCT_EXTERN_METHOD(del:(NSString *)uri parameters:(NSDictionary *)parameters successCallback:(RCTResponseSenderBlock)successCallback errorCallback:(RCTResponseSenderBlock)errorCallback)
RCT_EXTERN_METHOD(subscribe:(NSString *)uri parameters:(NSDictionary *)parameters key:(NSString *)key)
RCT_EXTERN_METHOD(unsubscribe:(NSString *)key)

@end
