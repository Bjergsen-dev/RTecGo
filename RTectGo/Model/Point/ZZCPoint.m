//
//  ZZCPoint.m
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/19.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import "ZZCPoint.h"

@implementation ZZCPoint

- (id)initWithPoint:(double)point_x point_y:(double)point_y height:(double)height{

    if (self = [super init]) {
        self.point_x = point_x;
        self.point_y = point_y;
        self.height = height;
    }
    return self;
}

@end
