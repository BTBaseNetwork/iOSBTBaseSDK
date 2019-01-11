//
//  BTBaseSDK+Unity.m
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/13.
//  Copyright © 2018年 btbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <BTBaseSDK/BTBaseSDK-Swift.h>
#import "UnityInterface.h"
#import "BTBaseSDK+UnityMessageReceiver.h"

@implementation UIViewController(BTBaseSDK)
- (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}
@end

BOOL pauseUnityOnBTHomeShown = true;

UIViewController* _btbaseGetUnityViewController(){
    return UnityGetGLViewController();
}

void _btbaseSDK_Start(){
    [BTBaseSDK setupLoginedBanner];
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
    if (vc.topViewController == vc) {
        [BTBaseSDK openHome:vc];
    }
}

void _btbaseSDK_OpenHomeGamewallPage(){
    UIViewController* vc = _btbaseGetUnityViewController();
    if (vc.topViewController == vc) {
        [BTBaseSDK openHome:vc :@"gamewall"];
    }
}

void _btbaseSDK_OpenHomeMemberPage(){
    UIViewController* vc = _btbaseGetUnityViewController();
    if (vc.topViewController == vc) {
        [BTBaseSDK openHome:vc :@"member"];
    }
}

void _btbaseSDK_OpenHomeAccountPage(){
    UIViewController* vc = _btbaseGetUnityViewController();
    if (vc.topViewController == vc) {
        [BTBaseSDK openHome:vc :@"account"];
    }
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

NSInteger _btbaseSDK_GetBadgeNumber()
{
    return [BTBaseSDK getBadgeNumber];
}

void _btbaseSDK_ClearBadgeNumber()
{
    [BTBaseSDK clearBadgeNumber];
}

void _btbaseSDK_FetchGameWallList()
{
    [BTBaseSDK fetchGameWallListWithForce:false];
}

void _btbaseSDK_ForceFetchGameWallList()
{
    [BTBaseSDK fetchGameWallListWithForce:true];
}
