//
//  CompanyRegisViewController.h
//  RTectGo
//
//  Created by Apple on 2019/1/4.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZCKeychain.h"
#import "ZZCJIami.h"
#import "zzcAFN.h"
#import "DemoUtility.h"
#import "UserLoginViewController.h"
#import <sqlite3.h>


#define KEY_RTECHGO @"com.kangtu.RTectGo3"

#define KEY_UUID @"com.kangtu.RTectGo.uuid"
#define KEY_COMPANY @"com.kangtu.RTectGo.company"
#define KEY_YESORNO @"com.kangtu.RTectGo.yesorno"
#define KEY_LASTDATE @"com.kangtu.RTectGo.lastdate"
#define KEY_ZZDATE @"com.kangtu.RTectGo.zzdate"
#define KEY_PHONENUM @"com.kangtu.RTectGo.phonenum"
#define KEY_XULIEHAO @"com.kangtu.RTectGo.xuliehao"

@interface CompanyRegisViewController : UIViewController

@property (nonatomic, assign) int registerInt;//计时器重复次数

@end
