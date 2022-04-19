//
//  ZZCLocationChange.h
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/11.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZZCPoint.h"
#import <MapKit/MapKit.h>
@interface ZZCLocationChange : NSObject
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

- (id)initWithLatitude:(double)latitude andLongitude:(double)longitude;



// World Geodetic System ==> Mars Geodetic System
- (CLLocationCoordinate2D)WorldGS2MarsGS:(CLLocationCoordinate2D)coordinate;
// Mars Geodetic System ==> World Geodetic System
- (CLLocationCoordinate2D)MarsGS2WorldGS:(CLLocationCoordinate2D)coordinate;

// WORLD 经纬度 ==> 米勒
- (ZZCPoint *)MillierConvertion:(CLLocationCoordinate2D)coordinate;
// 米勒 ==> WORLD 经纬度
- (CLLocationCoordinate2D)MillierConvertionBack:(ZZCPoint *)point;

//地理坐标是否超出中国范围
+ (BOOL)outOfChina:(double)lat lon:(double)lon;
//转换坐标
+ (double)transformLat:(double)y lon:(double)x;
+ (double)transformLon:(double)y lon:(double)x;
@end
