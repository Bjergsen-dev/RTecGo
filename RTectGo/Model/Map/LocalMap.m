//
//  LocalMap.m
//  RTectGo
//
//  Created by Apple on 2019/2/23.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import "LocalMap.h"

@implementation LocalMap

- (instancetype)init
{
    if (self = [super init]) {
        /**
         *
         在这里初始化变量
         *
         **/
        self.name = [[NSString alloc] init];
        self.time = [[NSString alloc] init];
        self.url = [[NSString alloc] init];
        
        
    }
    
    return self;
}

@end
