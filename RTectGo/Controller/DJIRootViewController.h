//
//  DJIRootViewController.h
//  GSDemo
//
//  Created by DJI on 7/7/15.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZCRoutePlan.h"
#import "CircleAnimationView.h"
#import "FlyUser.h"
#import "CompanyRegisViewController.h"
#import "ZZCKeychain.h"
#import "ZZCInt.h"
#import "UserLoginViewController.h"
#import "ZQAlterField.h"
#import <math.h>
#import "ZKTileOverlay.h"
#import "LocalMap.h"
#import "LJKSlideView.h"
#import "CheckTFView.h"
#import "SZKCustomAlter.h"

#define TIAODAI 0;
#define HUANRAO 1;
#define QINXIE 2
#define QUANJIN 3;

@interface DJIRootViewController : UIViewController


//这里是飞行模式
@property (assign, nonatomic) ZZCRouteMode mode;
//这里是倾斜飞的模式
@property (assign, nonatomic) ZZCQinxieMode qinxie_mode;
//用户实例
@property(nonatomic,strong) FlyUser* zzcUser;

@end
