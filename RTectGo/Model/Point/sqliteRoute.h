//
//  sqliteRoute.h
//  MediaManagerDemo
//
//  Created by Apple on 2018/8/4.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlitePoint.h"
@interface sqliteRoute : NSObject

@property (nonatomic, assign) int Id;
@property (nonatomic, assign) int user_Id;
@property (nonatomic, assign) int type;
@property (nonatomic, assign) float height;
@property (nonatomic, assign) float l_height;
@property (nonatomic, assign) int angle;
@property (nonatomic, assign) int currentIndex;
@property (nonatomic, assign) int beginIndex;
@property (nonatomic, assign) int pointCount;
@property (nonatomic, assign) float hxChongdie;
@property (nonatomic, assign) float pxChongdie;
@property (nonatomic, strong) NSString* time;
@property (nonatomic, strong) NSString* inittime;
@property (strong, nonatomic) NSMutableArray* point_array;
@property (nonatomic, assign) BOOL deleteOrnot;
@property (nonatomic, strong) NSString* route_name;
@property (nonatomic, assign) BOOL xiugaimei;
@property (nonatomic, assign) int qinxieAngle;



@end
