//
//  ZZCJIami.m
//  RTectGo
//
//  Created by Apple on 2019/1/3.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import "ZZCJIami.h"

//空字符串
#define     LocalStr_None           @""

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation ZZCJIami

//TODO:创造一个加密算法
//1:需要产生随机数字的9位串码作为引子
//2:需要进行结果匹配
+ (NSString *)sensitize{
    //产生1 -10 的一个随机数 并进行拼接
    NSString * resultStr = @"";
    
    for (int i = 0; i < 9; i++) {
        int x = arc4random() % 10;
        NSString *ValueString = [NSString stringWithFormat:@"%d", x];
        resultStr = [resultStr stringByAppendingString:ValueString];
    }
    
    //打印看看是谁否正确
    NSLog(@"字符串为：%@", resultStr);
    return resultStr;
}

//md5加密的过程
+ (NSString *)md5_32bit:(NSString *)input{
    
    //传入参数,转化成char
         const char * str = [input UTF8String];
         //开辟一个16字节（128位：md5加密出来就是128位/bit）的空间（一个字节=8字位=8个二进制数）
         unsigned char md[CC_MD5_DIGEST_LENGTH];
         /*
           7      extern unsigned char * CC_MD5(const void *data, CC_LONG len, unsigned char *md)官方封装好的加密方法
           8      把str字符串转换成了32位的16进制数列（这个过程不可逆转） 存储到了md这个空间中
           9      */
         CC_MD5(str, (int)strlen(str), md);
         //创建一个可变字符串收集结果
         NSMutableString * ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
         for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
                 /**
                    15          X 表示以十六进制形式输入/输出
                    16          02 表示不足两位，前面补0输出；出过两位不影响
                    17          printf("%02X", 0x123); //打印出：123
                    18          printf("%02X", 0x1); //打印出：01
                    19          */
                 [ret appendFormat:@"%02X",md[i]];
             }
         //返回一个长度为32的字符串
    
    NSLog(@"ret:%@",ret);
        return ret;
}

//unix时间戳进入
+ (int)unix_timein:(NSString *) input{
    
    //NSString *dateString = @"2016-09-21";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *mydate=[formatter dateFromString:input];
    NSTimeInterval myInterval = [mydate timeIntervalSince1970];
    int unixInterval = (int) myInterval;
    NSLog(@"%@---%d",mydate,unixInterval);
    return unixInterval;
}


//Unix 时间戳返回
+ (NSString *)unix_timeback:(int) input{
    
    //NSString *dateString = @"2016-09-21";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *mydate=[NSDate dateWithTimeIntervalSince1970: input];
    NSString *confromTimespStr = [formatter stringFromDate:mydate];
    //NSLog(@"%@---%@",mydate,confromTimespStr);
   
    return confromTimespStr;
    
}


+ (NSString *)base64StringFromText:(NSString *)text
{
    if (text && ![text isEqualToString:LocalStr_None]) {
        //取项目的bundleIdentifier作为KEY
        NSString *key = @"201530258";
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        //IOS 自带DES加密 Begin
        data = [self DESEncrypt:data WithKey:key];
        //IOS 自带DES加密 End
        return [self base64EncodedStringFrom:data];
    }
    else {
        return LocalStr_None;
    }
}

+ (NSString *)textFromBase64String:(NSString *)base64
{
    if (base64 && ![base64 isEqualToString:LocalStr_None]) {
        //取项目的bundleIdentifier作为KEY
        NSString *key = @"201530258";
        NSData *data = [self dataWithBase64EncodedString:base64];
        //IOS 自带DES解密 Begin
        data = [self DESDecrypt:data WithKey:key];
        //IOS 自带DES加密 End
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else {
        return LocalStr_None;
    }
}



/************************************************************
 函数名称 : + (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
 函数描述 : 文本数据进行DES加密
 输入参数 : (NSData *)data
 (NSString *)key
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 : 此函数不可用于过长文本
 **********************************************************/
+ (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

/************************************************************
 函数名称 : + (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
 函数描述 : 文本数据进行DES解密
 输入参数 : (NSData *)data
 (NSString *)key
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 : 此函数不可用于过长文本
 **********************************************************/
+ (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

/************************************************************
 函数名称 : + (NSData *)dataWithBase64EncodedString:(NSString *)string
 函数描述 : base64格式字符串转换为文本数据
 输入参数 : (NSString *)string
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 :
 **********************************************************/
+ (NSData *)dataWithBase64EncodedString:(NSString *)string
{
    if (string == nil)
        [NSException raise:NSInvalidArgumentException format:nil];
    if ([string length] == 0)
        return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    bytes = realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

/************************************************************
 函数名称 : + (NSString *)base64EncodedStringFrom:(NSData *)data
 函数描述 : 文本数据转换为base64格式字符串
 输入参数 : (NSData *)data
 输出参数 : N/A
 返回参数 : (NSString *)
 备注信息 :
 **********************************************************/
+ (NSString *)base64EncodedStringFrom:(NSData *)data
{
    if ([data length] == 0)
        return @"";
    
    char *characters = malloc((([data length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [data length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [data length])
            buffer[bufferLength++] = ((char *)[data bytes])[i++];
        
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

/************************************************************
 函数名称 : + (NSString *)ZZCZJJM:(NSString *)DESstr
 函数描述 : 完整的解谜过程
 输入参数 : (NSString *)DESstr  DES加密格式字符串
 输出参数 : 时间戳unix
 返回参数 : (NSString *)    文本
 备注信息 :
 **********************************************************/
+ (NSString *)ZZCDateJM:(NSString *)DESstr{
    
    //首先进行DES解密过程  该过程产生的是20位的字符串
    NSString * DESjiemi = [ZZCJIami textFromBase64String:DESstr];
    NSLog(@"DESjiemi:%@",DESjiemi);
    //接下来进行字符串的截取组合获得
    //1.设备码的md5加密结果
    //2.到期时间的unix时间戳
    
    NSString * lastDate1 = [DESjiemi substringWithRange:NSMakeRange(2,2)];
    NSString * lastDate2 = [DESjiemi substringWithRange:NSMakeRange(6,2)];
    NSString * lastDate3 = [DESjiemi substringWithRange:NSMakeRange(10,2)];
    NSString * lastDate4 = [DESjiemi substringWithRange:NSMakeRange(14,2)];
    NSString * lastDate5 = [DESjiemi substringWithRange:NSMakeRange(18,2)];
    
    NSString * lastDate = [NSString stringWithFormat:@"%@%@%@%@%@",lastDate1,lastDate2,lastDate3,lastDate4,lastDate5];
    //NSString * Date = [ZZCJIami unix_timeback:[lastDate intValue]];
    NSLog(@"lastDate:%@",lastDate);
    return lastDate;
    
}

/************************************************************
 函数名称 : + (NSString *)ZZCMd5JM:(NSString *)DESstr
 函数描述 : 完整的解谜过程
 输入参数 : (NSString *)DESstr  DES加密格式字符串
 输出参数 : Md5码
 返回参数 : (NSString *)    文本
 备注信息 :
 **********************************************************/
+ (NSString *)ZZCMd5JM:(NSString *)DESstr{
    //首先进行DES解密过程  该过程产生的是20位的字符串
    NSString * DESjiemi = [ZZCJIami textFromBase64String:DESstr];
    
    NSLog(@"DESjiemi:%@",DESjiemi);
    //接下来进行字符串的截取组合获得
    //1.设备码的md5加密结果
    //2.到期时间的unix时间戳
    
    NSString * lastDate1 = [DESjiemi substringWithRange:NSMakeRange(0,2)];
    NSString * lastDate2 = [DESjiemi substringWithRange:NSMakeRange(4,2)];
    NSString * lastDate3 = [DESjiemi substringWithRange:NSMakeRange(8,2)];
    NSString * lastDate4 = [DESjiemi substringWithRange:NSMakeRange(12,2)];
    NSString * lastDate5 = [DESjiemi substringWithRange:NSMakeRange(16,2)];
    
    NSString * lastDate = [NSString stringWithFormat:@"%@%@%@%@%@",lastDate1,lastDate2,lastDate3,lastDate4,lastDate5];
    NSLog(@"Md5:%@",lastDate);
    return lastDate;
    
}


+(NSInteger)getNowTimestamp{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间
        NSLog(@"设备当前的时间:%@",[formatter stringFromDate:datenow]);
    //时间转时间戳的方法:
    NSInteger timeSp = [[NSNumber numberWithDouble:[datenow timeIntervalSince1970]] integerValue];
        NSLog(@"设备当前的时间戳:%ld",(long)timeSp); //时间戳的值
    return timeSp;
}


+(NSString *)timestampSwitchTime:(NSInteger)timestamp andFormatter:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    
    //十三位时间戳转时间需要/1000 十位时间戳你不需要
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
        NSLog(@"&&&&&&&confromTimespStr = : %@",confromTimespStr);
    return confromTimespStr;
}


@end
