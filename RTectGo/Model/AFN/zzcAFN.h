//
//  zzcAFN.h
//  RTectGo
//
//  Created by Apple on 2019/1/7.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface zzcAFN : NSObject

//这里存一个字典
//iOS中使用AFNetWorking时如何将responseObject传出
//bullsHit 居然为空 根本就不能穿出来好不好
//老老实实别封装了
//告辞

//封装一下Get的网络请求方法
+(NSDictionary *) zzcGet:(NSDictionary *) dict uri:(NSString *)uri;


//封装一下Post的网络请求方法
+(NSDictionary *) zzcPost:(NSDictionary *) dict uri:(NSString *)uri;


//这两个函数应该还是有点用的留着
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+(NSString *)convertToJsonData:(NSDictionary *)dict;

//判断网络状态
+(NSString *)internetStauts;

@end
