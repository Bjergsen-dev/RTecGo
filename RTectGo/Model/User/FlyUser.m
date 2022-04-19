//
//  FlyUser.m
//  RTectGo
//
//  Created by Apple on 2019/1/10.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import "FlyUser.h"

@implementation FlyUser

- (instancetype)init
{
    if (self = [super init]) {
        /**
         *
         在这里初始化变量
         *
         **/
        self.company = [[NSString alloc] init];
        self.password = [[NSString alloc] init];
        self.phoneNum = [[NSString alloc] init];
        self.userName = [[NSString alloc] init];
        
        
    }
    
    return self;
}


@end
