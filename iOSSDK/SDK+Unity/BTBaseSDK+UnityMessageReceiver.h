//
//  BTBaseSDK+UnityMessageReceiver.h
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/16.
//  Copyright © 2018年 btbase. All rights reserved.
//
#pragma once

#ifndef BTBaseSDK_UnityMessageReceiver_h
#define BTBaseSDK_UnityMessageReceiver_h
#import <Foundation/Foundation.h>
@import BTBaseSDK;

extern NSNotificationName const UnityMessageReceiverNotificationName;
extern NSString* kUnityMessageReceiverMessageName;
extern NSString* kUnityMessageReceiverMessageUserInfo;

@interface BTBaseSDK(UnityMessageReceiver)
+(void) sendMessageToUnityMessageReceiver:(NSString*)msgName userInfo:(NSDictionary*) uinfo;
+(void) startListenBTBaseNotifications;
+(void) stopListenBTBaseNotifications;
@end

#endif /* BTBaseSDK_UnityMessageReceiver_h */
