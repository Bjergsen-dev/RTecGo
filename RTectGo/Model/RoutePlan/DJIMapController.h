//
//  DJIMapViewController.h
//  GSDemo
//
//  Created by DJI on 7/7/15.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DJIAircraftAnnotation.h"
#import "DJIUserAnnotation.h"
#import "ZZCLocationChange.h"
#import "ZZCMiddleAnnotaion.h"
#import "sqliteRoute.h"

@interface DJIMapController : NSObject

@property (strong, nonatomic) NSMutableArray *editPoints;
@property (strong, nonatomic) NSMutableArray *mkPointAnns;
@property (strong, nonatomic) MKPolygon *polygon;
@property (strong, nonatomic) MKPolygon *wqinxie_polygon;
@property (strong, nonatomic) MKPolygon *nqinxie_polygon;
@property (strong, nonatomic) MKPolygon *eqinxie_polygon;
@property (strong, nonatomic) MKPolygon *sqinxie_polygon;
@property (strong, nonatomic) CLLocation *centerLoc;
@property (nonatomic, strong) DJIAircraftAnnotation* aircraftAnnotation;
@property (nonatomic, strong) DJIUserAnnotation* userAnnotation;
@property (nonatomic, strong) ZZCMiddleAnnotaion* midAnnotation;
@property (nonatomic, strong) ZZCLocationChange* zzcLocationChange;
@property (nonatomic, strong) sqliteRoute* route;

/**
 *  Add Waypoints in Map View
 */
- (void)addPoint:(CGPoint)point withMapView:(MKMapView *)mapView;

//中间点的添加
- (void)setMiddlePoint:(NSMutableArray*)initPoints withMapView:(MKMapView *)mapView;


//拖拽条带飞更新点的坐标  外部先判断是那个点动了——index
- (void)updateEditingPoints:(CLLocation*)newLocaton withindex:(int)index;

/**
 *  Clean All Waypoints in Map View
 */
- (void)cleanAllPointsWithMapView:(MKMapView *)mapView;

/**
 *  Update Aircraft's location in Map View
 */
-(void)updateAircraftLocation:(CLLocationCoordinate2D)location withMapView:(MKMapView *)mapView;

/**
 *  Update Aircraft's heading in Map View
 */
-(void)updateAircraftHeading:(float)heading;

/**
 *  Update User's location in Map View
 */
-(void)updateUserLocation:(CLLocationCoordinate2D)location withMapView:(MKMapView *)mapView;

/**
 *  Update User's heading in Map View
 */
-(void)updateUserHeading:(float)heading;
/**
 *
这个方法用于处理环绕飞的拖拽点更新坐标
 *
 **/
- (void)updateHuanraoPoints:(CLLocation*)newLocaton;

//这个方法用于利用初始的点标记坐标生成mapview上的overlays（覆盖物）
- (CLLocationCoordinate2D)setPolygonView:(NSMutableArray*)initPoints withMapView:(MKMapView *)mapView withCenterView:(UIView *)centerView withCenterCoor:(CLLocationCoordinate2D) centerCoor;

//倾斜飞的polygon
- (void) setqinxiePolygonView:(NSMutableArray*)westPoints northPoints:(NSMutableArray*)northPoints eastPoints:(NSMutableArray*)eastPoints southPoints:(NSMutableArray*)southPoints withMapView:(MKMapView *)mapView;

//根据初始标记点坐标来生成地图上的标记
- (void)setPointView:(NSMutableArray*)initPoints withMapView:(MKMapView *)mapView;

/**
 *  Current Edit Points
 *
 *  @return Return an NSArray contains multiple CCLocation objects
 */
- (NSArray *)wayPoints;

//保持ann和editPoints一致
- (void)annKeepEditPoints:(NSMutableArray*)annPoints;

- (CLLocationCoordinate2D)setPolygonView1:(NSMutableArray*)initPoints withMapView:(MKMapView *)mapView  withCenterView:(UIView *)centerView withCenterCoor:(CLLocationCoordinate2D) centerCoor;

@end
