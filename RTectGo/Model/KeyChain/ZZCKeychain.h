//
//  ZZCKeychain.h
//  RTectGo
//
//  Created by Apple on 2018/11/11.
//  Copyright © 2018年 zzcBjergsen. All rights reserved.
//  相关代码链接：https://lvtao.net/ios/ios-keychain.html
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
@interface ZZCKeychain : NSObject
//keychain 的存储方法
+ (void)save:(NSString *)service data:(id)data;
//keychain 的拿取方法
+ (id)load:(NSString *)service;
//keychain 的删除方法
+ (void)zdelete:(NSString *)service;
@end
