//
//  BTBaseSDK+UnityMessageReceiver.m
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/16.
//  Copyright © 2018年 btbase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTBaseSDK+UnityMessageReceiver.h"

NSNotificationName const UnityMessageReceiverNotificationName = @"UnityMessageReceiverNotification";
NSString* kUnityMessageReceiverMessageName = @"kUnityMessageReceiverMessageName";
NSString* kUnityMessageReceiverMessageUserInfo = @"kUnityMessageReceiverMessageUserInfo";

@implementation BTBaseSDK(UnityMessageReceiver)
NSMutableArray* observers;
+(void)sendMessageToUnityMessageReceiver:(NSString *)msgName userInfo:(NSDictionary *)uinfo{
    NSMutableDictionary* info = [NSMutableDictionary alloc];
    if (uinfo) {
        [info setObject:uinfo forKey:kUnityMessageReceiverMessageUserInfo];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UnityMessageReceiverNotificationName object:nil userInfo:info];
}

+(void)startListenBTBaseNotifications{
    if (observers) {
        [self stopListenBTBaseNotifications];
    }else{
        observers = [NSMutableArray alloc];
    }
    NSObject* observer;
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"BTSessionService_onSessionInvalid" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        //TODO:
    }];
    [observers addObject:observer];
    
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"BTSessionService_onSessionInvalid" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        //TODO:
    }];
    [observers addObject:observer];
    
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"BTBaseHomeEntryDidShown" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        //TODO:
    }];
    [observers addObject:observer];
    
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"BTBaseHomeEntryClosed" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        //TODO:
    }];
    [observers addObject:observer];
}

+(void)stopListenBTBaseNotifications{
    for (NSObject* observer in observers) {
        [[NSNotificationCenter defaultCenter ] removeObserver:observer];
    }
}
@end
