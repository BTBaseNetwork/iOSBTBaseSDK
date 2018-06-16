//
//  BTBaseSDK+Unity.m
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/13.
//  Copyright © 2018年 btbase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BTBaseSDK/BTBaseSDK-Swift.h>
#import "UnityInterface.h"
#import "BTBaseSDK+UnityMessageReceiver.h"

BOOL pauseUnityOnBTHomeShown = true;

UIViewController* _btbaseGetUnityViewController(){
    return UnityGetGLViewController();
}

void _btbaseSDK_Start(){
    [BTBaseSDK start];
    [BTBaseSDK setupSDKUI];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"BTBaseHomeEntryDidShown" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if (pauseUnityOnBTHomeShown) {
            UnityPause(1);
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"BTBaseHomeEntryClosed" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if (pauseUnityOnBTHomeShown) {
            UnityPause(0);
        }
    }];
}

void _btbaseSDK_OpenHome(){
    UIViewController* vc = _btbaseGetUnityViewController();
    [BTBaseSDK openHome:vc];
}

BOOL _btbaseSDK_IsSDKInited(){
    return BTBaseSDK.isSDKInited;
}

BOOL _btbaseSDK_IsInMemberSubscription(){
    return BTBaseSDK.isInMemberSubscription;
}

BOOL _btbaseSDK_IsLogined(){
    return BTBaseSDK.isLogined;
}

void _btbaseSDK_TryQuickLogin(){
    UIViewController* vc = _btbaseGetUnityViewController();
    [BTBaseSDK tryShowLoginWithSharedAuthenticationAlertWithVc:vc];
}

void _btbaseSDK_StartListenNotifications(){
    [BTBaseSDK startListenBTBaseNotifications];
}

void _btbaseSDK_StopListenNotifications(){
    [BTBaseSDK stopListenBTBaseNotifications];
}

void _btbaseSDK_SetPauseUnityOnBTHomeShown(BOOL enabled)
{
    pauseUnityOnBTHomeShown = enabled;
}
