//
//  sqliteRoute.m
//  MediaManagerDemo
//
//  Created by Apple on 2018/8/4.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import "sqliteRoute.h"

@implementation sqliteRoute

- (instancetype)init
{
    if (self = [super init]) {
        /**
         *
         在这里初始化变量
         *
         **/
        self.point_array = [[NSMutableArray alloc] init];
        self.time = [[NSString alloc] init];
        self.inittime = [[NSString alloc] init];
        self.route_name = [[NSString alloc] init];
        self.xiugaimei = NO;
    }
    
    return self;
}


@end
