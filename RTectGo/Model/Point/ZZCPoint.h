//
//  ZZCPoint.h
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/19.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZCPoint : NSObject
@property (nonatomic, assign) double point_x;
@property (nonatomic, assign) double point_y;
@property (nonatomic, assign) double height;
@property (nonatomic, assign) int heading;

//初始化
- (id)initWithPoint:(double)point_x point_y:(double)point_y height:(double)height;
@end
