//
//  ZZCWaypoint.m
//  MediaManagerDemo
//
//  Created by Apple on 2018/12/7.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import "ZZCWaypoint.h"

@implementation ZZCWaypoint

- (id)initWithPoint:(DJIWaypoint *)waypoint index:(int)index{
    
    if (self = [super init]) {
        self.waypoint = waypoint;
        self.index = index;
    }
    return self;
}


@end
