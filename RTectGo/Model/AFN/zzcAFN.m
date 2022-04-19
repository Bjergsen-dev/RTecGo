//
//  zzcAFN.m
//  RTectGo
//
//  Created by Apple on 2019/1/7.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import "zzcAFN.h"
#import "DemoUtility.h"

@implementation zzcAFN

//封装一下Get的网络请求方法
+(NSDictionary *) zzcGet:(NSDictionary *) dict uri:(NSString *)uri{
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSDictionary * returnDic = [[NSDictionary alloc] init];
    
    //2.发送GET请求
    /*
     第一个参数:请求路径(NSString)+ 不需要加参数
     第二个参数:发送给服务器的参数数据
     第三个参数:progress 进度回调
     第四个参数:success  成功之后的回调(此处的成功或者是失败指的是整个请求)
     task:请求任务
     responseObject:注意!!!响应体信息--->(json--->oc))
     task.response: 响应头信息
     第五个参数:failure 失败之后的回调
     */
    [manager GET:uri parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success--%@--%@",[responseObject class],responseObject);
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"failure--%@",error);
    }];
    
    
//    //这里解决汉字乱码的问题
//    NSString * jsonStr = [zzcAFN convertToJsonData:returnDic];
//    NSString *jsonStr_UTF8 = [jsonStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//
//    returnDic = [zzcAFN dictionaryWithJsonString:jsonStr_UTF8];
//
//    NSLog(@"NSString--%@",jsonStr);
//
//    return returnDic;
    return returnDic;
}


+(NSDictionary *) zzcPost:(NSDictionary *) dict uri:(NSString *)uri{
    
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __block NSDictionary * returnDic = [[NSDictionary alloc] init];
    //2.发送GET请求
    /*
     第一个参数:请求路径(NSString)+ 不需要加参数
     第二个参数:发送给服务器的参数数据
     第三个参数:progress 进度回调
     第四个参数:success  成功之后的回调(此处的成功或者是失败指的是整个请求)
     task:请求任务
     responseObject:注意!!!响应体信息--->(json--->oc))
     task.response: 响应头信息
     第五个参数:failure 失败之后的回调
     */
    [manager POST:uri parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success--%@--%@",[responseObject class],responseObject);
        
        NSData*jsondata = [responseObject data];
        
        NSString*jsonString = [[NSString alloc]initWithBytes:[jsondata bytes]length:[jsondata length]encoding:NSUTF8StringEncoding];
        
        returnDic = [zzcAFN dictionaryWithJsonString:jsonString];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"failure--%@",error);
    }];
    
    return returnDic;
}


//JSON转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//字典转JSON
+(NSString *)convertToJsonData:(NSDictionary *)dict

{
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}


//判断网络状态
+ (NSString *)internetStauts{
    // 状态栏是由当前app控制的，首先获取当前app
    UIApplication *app = [UIApplication sharedApplication];
    NSArray * children;
    if ([[app valueForKeyPath:@"_statusBar"] isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]){
        
        children = [[[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
        
        for (id child in children) {
            
            //wifi
            if ([child isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) {
                //state = @"wifi";
                return @"WIFI";
            }
            //2G 3G 4G
            if ([child isKindOfClass:NSClassFromString(@"_UIStatusBarStringView")]) {
                if ([[child valueForKey:@"_originalText"] containsString:@"G"]) {
                    //state = [child valueForKey:@"_originalText"];
                    return @"ZG";
                }
            }
        }
        //state = @"无网络";
        return @"NONE";

    }
else{
        
        children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
        
        int type = 0;
        for (id child in children) {
            if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
                type = [[child valueForKeyPath:@"dataNetworkType"] intValue];
            }
        }
        switch (type) {
            case 1:
                return @"2G";
                break;
            case 2:
                return @"3G";
            case 3:
                return @"4G";
            case 5:
                return @"WIFI";
            case 6:
                return @"HOT POINT";
            default:
                
                //ShowResult(@"网络状况异常");
                return @"NONE";//代表未知网络
                break;
        }
    }
    
    
}

@end
