//
//  ZZCLocationChange.m
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/11.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import "ZZCLocationChange.h"

@implementation ZZCLocationChange


- (id)initWithLatitude:(double)latitude andLongitude:(double)longitude {
    if (self = [super init]) {
        self.latitude = latitude;
        self.longitude = longitude;
    }
    return self;
}





// World Geodetic System ==> Mars Geodetic System
- (CLLocationCoordinate2D)WorldGS2MarsGS:(CLLocationCoordinate2D)coordinate
{
    // a = 6378245.0, 1/f = 298.3
    // b = a * (1 - f)
    // ee = (a^2 - b^2) / a^2;
    const double a = 6378245.0;
    const double ee = 0.00669342162296594323;
    
    
    
    if ([ZZCLocationChange outOfChina:coordinate.latitude lon:coordinate.longitude])
    {
        return coordinate;
    }
    double wgLat = coordinate.latitude;
    double wgLon = coordinate.longitude;
    double dLat = [ZZCLocationChange transformLat:wgLon - 105.0 lon:wgLat - 35.0];//transformLat(wgLon - 105.0, wgLat - 35.0);
    double dLon = [ZZCLocationChange transformLon:wgLon - 105.0 lon:wgLat - 35.0];
    double radLat = wgLat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    
    //NSLog(@"wgLat:%f wgLon:%f",wgLat,wgLon);
    //NSLog(@"dLat:%f dLon:%f",dLat,dLon);
    
    return CLLocationCoordinate2DMake(wgLat + dLat, wgLon + dLon);
}


// Mars Geodetic System ==>World Geodetic System
- (CLLocationCoordinate2D)MarsGS2WorldGS:(CLLocationCoordinate2D)coordinate{

    double gLat = coordinate.latitude;
    double gLon = coordinate.longitude;
    CLLocationCoordinate2D marsCoor = [self WorldGS2MarsGS:coordinate];
    double dLat = marsCoor.latitude - gLat;
    double dLon = marsCoor.longitude - gLon;
    return CLLocationCoordinate2DMake(gLat - dLat, gLon - dLon);
    
}

// WORLD 经纬度 ==> 米勒
- (ZZCPoint *)MillierConvertion:(CLLocationCoordinate2D)coordinate{

    double L = 6381372 * M_PI * 2;//地球周长
    double W = L;// 平面展开后，x轴等于周长
    double H = L / 2;// y轴约等于周长一半
    double mill = 2.3;// 米勒投影中的一个常数，范围大约在正负2.3之间
    double x = coordinate.longitude * M_PI / 180;// 将经度从度数转换为弧度
    double y = coordinate.latitude * M_PI / 180;// 将纬度从度数转换为弧度
    y = 1.25 * log(tan(0.25 * M_PI + 0.4 * y));// 米勒投影的转换
    // 弧度转为实际距离
    x = (W / 2) + (W / (2 * M_PI)) * x;
    y = (H / 2) - (H / (2 * mill)) * y;
    ZZCPoint * point = [[ZZCPoint alloc] initWithPoint:x point_y:y height:0];
    NSLog(@"MillierConvertion-point_x:%f",point.point_x);
    NSLog(@"MillierConvertion-point_y:%f",point.point_y);
    return point;
    
}


// 米勒 ==> WORLD 经纬度
- (CLLocationCoordinate2D)MillierConvertionBack:(ZZCPoint *)point{

    double L = 6381372 * M_PI * 2;//地球周长
    double W = L;// 平面展开后，x轴等于周长
    double H = L / 2;// y轴约等于周长一半
    double mill = 2.3;// 米勒投影中的一个常数，范围大约在正负2.3之间
    double lat;
    lat = ((H / 2 - point.point_y) * 2 * mill) / (1.25 * H);
    lat = ((atan(exp(lat)) - 0.25 * M_PI) * 180) / (0.4 * M_PI);
    double lon;
    lon = (point.point_x - W / 2) * 360 / W;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);
    NSLog(@"MillierConvertionBack-coordinate_lat:%f",coordinate.latitude);
    NSLog(@"MillierConvertionBack-coordinate_lon:%f",coordinate.longitude);
    return coordinate;
}

+ (double)transformLat:(double)x lon:(double)y
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
    
    
}


+ (double)transformLon:(double)x lon:(double)y
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
    
}

+ (BOOL)outOfChina:(double)lat lon:(double)lon
{
    if (lon < 72.004 || lon > 137.8347)
        return YES;
    if (lat < 0.8293 || lat > 55.8271)
        return YES;
    return NO;
}

@end
