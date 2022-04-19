//
//  ZZCRoutePlan.h
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/18.
//  Copyright © 2018年 DJI. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "ZZCLocationChange.h"
#import "ZZCPoint.h"
#import "DJIRouteAnnotion.h"
#import "CircleAnimationView.h"
#import "DJIBeginPointAnnotation.h"
#import "routeLine.h"
#import "westPolyLine.h"
#import "northPolyLine.h"
#import "eastPolyLine.h"
#import "southPolyLine.h"
#import "yundongPolyLine.h"
#import "DemoUtility.h"
/**
 *
 在这里定义一些算法里面用到的参数
 *
 **/
#define H 110
#define HRH 250
#define H_MIN 100
#define ANGLE 60
#define QINXIEANGLE 60
#define HRANGLE 30
#define CW 0.0127
#define CH 0.0096
#define COURSELAP 0.8
#define SIDELAP 0.6
#define F 0.0088


/**
 *
 在这里定义一些算法里面用到的模式——条带飞 环绕飞 自定义标点飞
 *
 **/
typedef NS_ENUM(NSUInteger, ZZCRouteMode) {
    ZZCRouteMode_tiaodai,
    ZZCRouteMode_huanxing,
    ZZCRouteMode_qinxie,
    ZZCRouteMode_quanjin,
};


/**
 *
 在这里定义一些算法里面用到的倾斜飞的方向
 *
 **/
typedef NS_ENUM(NSUInteger, ZZCQinxieMode) {
    ZZCQinxieMode_west,
    ZZCQinxieMode_east,
    ZZCQinxieMode_north,
    ZZCQinxieMode_south,
    ZZCQinxieMode_none,//设置这个是为了解决一次上传四个倾斜面的要求
};

@interface ZZCRoutePlan : NSObject

//存储航点在World坐标系下的CLlocation
@property (strong, nonatomic) NSMutableArray *routeLocations;
//为了解决点扩充的问题专门提出的一个存储
@property (strong, nonatomic) NSMutableArray *kuochongPoints;
//存储满足条件的航点ZZCpoint
@property (strong, nonatomic) NSMutableArray *routePoints;
//存储初始标记转化米勒投影后的ZZCpoint
@property (strong, nonatomic) NSMutableArray *millonPoints;
//存储初步计算拿到的所有航点ZZCpoint
@property (strong, nonatomic) NSMutableArray *allRoutePoints;
//坐标变化实例
@property (nonatomic, strong) ZZCLocationChange* zzcLocationChange;
//航点自定义Annotation
@property (nonatomic, strong) DJIRouteAnnotion* routeAnnotion;
//定义该点用来存储米勒投影后坐标转换前的基数 用于最后转换回来使用
@property (nonatomic, strong) ZZCPoint* intMillonPoint;
//飞行模式 本处与外部选择的mode必须一致
@property (assign, nonatomic) ZZCRouteMode mode;
//定义初始标记多边形的最小外界矩形的xy坐标——算法需要
@property (nonatomic, assign) double max_X;
@property (nonatomic, assign) double max_Y;
@property (nonatomic, assign) double min_X;
@property (nonatomic, assign) double min_Y;

//定义航点的飞行高度——算法需要
@property (nonatomic, assign) double tiaodai_H;
@property (nonatomic, assign) double huanrao_Hmin;
@property (nonatomic, assign) double huanrao_Hmax;
@property (nonatomic, assign) double hxChongdie;
@property (nonatomic, assign) double pxChongdie;
@property (nonatomic, assign) double angle;
@property (nonatomic, assign) double qinxie_angle;
@property (nonatomic, assign) double xiangji_angle;
//定义倾斜飞的方向
@property (assign, nonatomic) ZZCQinxieMode qinxie_mode;

//在这里定义一下倾斜的四个数组来存四个不同亲些方向的航点
@property (strong, nonatomic) NSMutableArray *westLocations;
@property (strong, nonatomic) NSMutableArray *eastLocations;
@property (strong, nonatomic) NSMutableArray *northLocations;
@property (strong, nonatomic) NSMutableArray *southLocations;


//为了解决亲谢飞四部分同时显示 分别设置一下参数来记录各部分的点数
@property (nonatomic, assign) int westCount;
@property (nonatomic, assign) int northCount;
@property (nonatomic, assign) int eastCount;
@property (nonatomic, assign) int southCount;

//算法进度
@property (nonatomic, assign) int progress;

//这里定义一个出发点的下表
@property (nonatomic, assign) int begin_index;

//这里定义航线——线
@property (strong, nonatomic) routeLine *polyline;

//这里定义航线——倾斜飞1
@property (strong, nonatomic) westPolyLine *W_polyline;
//这里定义航线——倾斜飞2
@property (strong, nonatomic) northPolyLine *N_polyline;
//这里定义航线——倾斜飞3
@property (strong, nonatomic) eastPolyLine *E_polyline;
//这里定义航线——倾斜飞4
@property (strong, nonatomic) southPolyLine *S_polyline;

/**
 *  Add Waypoints in routeArray
 */
- (void)addRoutePoint:(NSMutableArray*)initPoints;
//获取边界航点的最小外接矩形的横纵坐标
- (void)outerRect:(NSMutableArray*)millonPoints;
//拿到所有边界点的xy转换后坐标
- (void)fetchAllMillonPoints:(NSMutableArray*)initPoints;
//拿到所有初步计算的条带飞航点
- (void)fetchAllRoutePoints:(NSMutableArray*)millonPoints;
//拿到所有初步计算的环形飞航点
- (void)fetchAllHuanraoRoutePoints:(NSMutableArray*)millonPoints;
//判断航点是否在边界范围内
- (bool)inorNot:(NSMutableArray*)millonPoints routePoint:(ZZCPoint*)point;
//外部唯一接口函数
- (void)fetchRouteLocations:(NSMutableArray*)initPoints;

//生成航点在mapview上面
-(void)setRouteLocation:(NSMutableArray*)routeLocations withMapView:(MKMapView *)mapView;
/**
 *  Current Edit Points
 *
 *  @return Return an NSArray contains multiple CCLocation objects
 */
- (NSArray *)getRoutePoints;

/**
 *
 清除所有mapview上的航点和航点数据
 *
 **/
- (void)cleanAllPointsWithMapView:(MKMapView *)mapView;

/**
 *
位置变动时更新航点数据重新渲染在地图上显示
 *
 **/
- (void)updateRouteView:(NSMutableArray*)initPoints withMapView:(MKMapView *)mapView;
/**
 *
点标记被拖拽时优化算法面的执行上面的暴力重新计算
 *
 **/

- (void)updateRouteViewForTT:(double)changed_x changed_y:(double)changed_y withMapView:(MKMapView *)mapView;

//初始点得到四个方向的初始点
- (void)fetchAllqinxieRound:(NSMutableArray*)initPoints;

//扩充点数的方法打包在这里

- (void)kuochongBoundPoints:(double) x_point_num y_num:(double) y_point_num offsetX:(double) offsetX offsetY:(double) offsetY type:(int)type;

//专门解决倾斜的四部分同时显示的
- (void)updateqinxieRouteView:(NSMutableArray*)westPoints northPoints:(NSMutableArray*)northPoints eastPoints:(NSMutableArray*)eastPoints southPoints:(NSMutableArray*)southPoints withMapView:(MKMapView *)mapView;

- (void)fetchQinxieRouteLocations:(NSMutableArray*)westPoints northPoints:(NSMutableArray*)northPoints eastPoints:(NSMutableArray*)eastPoints southPoints:(NSMutableArray*)southPoints;

@end
