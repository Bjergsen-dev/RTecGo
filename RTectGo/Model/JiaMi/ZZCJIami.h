//
//  ZZCJIami.h
//  RTectGo
//
//  Created by Apple on 2019/1/3.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

/******字符串转base64（包括DES加密）******/
#define __BASE64( text )        [ZZCJIami base64StringFromText:text]

/******base64（通过DES解密）转字符串******/
#define __TEXT( base64 )        [ZZCJIami textFromBase64String:base64]

@interface ZZCJIami : NSObject

//随机生成9位字符串作为设备🐎
+ (NSString *)sensitize;


//md5加密的过程
+ (NSString *)md5_32bit:(NSString *)input;

//unix时间戳
+ (int)unix_timein:(NSString *) input;

//unix时间戳
+ (NSString *)unix_timeback:(int) input;

/************************************************************
 函数名称 : + (NSString *)base64StringFromText:(NSString *)text
 函数描述 : 将文本转换为base64格式字符串
 输入参数 : (NSString *)text    文本
 输出参数 : N/A
 返回参数 : (NSString *)    base64格式字符串
 备注信息 :
 **********************************************************/
+ (NSString *)base64StringFromText:(NSString *)text;

/************************************************************
 函数名称 : + (NSString *)textFromBase64String:(NSString *)base64
 函数描述 : 将base64格式字符串转换为文本
 输入参数 : (NSString *)base64  base64格式字符串
 输出参数 : N/A
 返回参数 : (NSString *)    文本
 备注信息 :
 **********************************************************/
+ (NSString *)textFromBase64String:(NSString *)base64;

/************************************************************
 函数名称 : + (NSString *)ZZCDateJM:(NSString *)DESstr
 函数描述 : 完整的解谜过程
 输入参数 : (NSString *)DESstr  DES加密格式字符串
 输出参数 : 时间戳unix
 返回参数 : (NSString *)    文本
 备注信息 :
 **********************************************************/
+ (NSString *)ZZCDateJM:(NSString *)DESstr;

/************************************************************
 函数名称 : + (NSString *)ZZCMd5JM:(NSString *)DESstr
 函数描述 : 完整的解谜过程
 输入参数 : (NSString *)DESstr  DES加密格式字符串
 输出参数 : Md5码
 返回参数 : (NSString *)    文本
 备注信息 :
 **********************************************************/
+ (NSString *)ZZCMd5JM:(NSString *)DESstr;

/*
 
 *获取当前系统时间的时间戳
 
 */

+(NSInteger)getNowTimestamp;

/*
 
 *时间戳转时间
 
 *format (@"YYYY-MM-dd hh:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
 
 */

+(NSString *)timestampSwitchTime:(NSInteger)timestamp andFormatter:(NSString *)format;



@end
