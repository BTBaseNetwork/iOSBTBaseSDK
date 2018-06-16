//
//  UnityInterfaceDummy.m
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/16.
//  Copyright © 2018年 btbase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnityInterface.h"

// Fake Implementation For Compile Test

void    UnityPause(int pause){ }

UIViewController*       UnityGetGLViewController(){ return nil; }
UIView*                 UnityGetGLView(){ return nil; }
UIWindow*               UnityGetMainWindow(){ return nil; }
enum ScreenOrientation  UnityCurrentOrientation(){ return orientationUnknown;}
