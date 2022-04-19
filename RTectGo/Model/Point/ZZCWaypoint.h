//
//  ZZCWaypoint.h
//  MediaManagerDemo
//
//  Created by Apple on 2018/12/7.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  <DJISDK/DJISDK.h>
@interface ZZCWaypoint : NSObject

@property (nonatomic, strong) DJIWaypoint *waypoint;
@property (nonatomic, assign) int index;


//初始化
- (id)initWithPoint:(DJIWaypoint *)waypoint index:(int)index;

@end
