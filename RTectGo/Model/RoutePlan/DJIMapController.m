//
//  DJIMapController.m
//  GSDemo
//
//  Created by DJI on 7/7/15.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import "DJIMapController.h"

@interface DJIMapController ()

@end

@implementation DJIMapController

- (instancetype)init
{
    if (self = [super init]) {
        
        self.editPoints = [[NSMutableArray alloc] init];
        self.mkPointAnns = [[NSMutableArray alloc] init];
        self.zzcLocationChange = [[ZZCLocationChange alloc] init];
        self.route = [[sqliteRoute alloc] init];
        //self.centerLoc = [[CLLocation alloc] init];
        
    }
    
    return self;
}


//g
- (void)addPoint:(CGPoint)point withMapView:(MKMapView *)mapView
{
    
    CLLocationCoordinate2D coordinate = [mapView convertPoint:point toCoordinateFromView:mapView];
    
    CLLocationCoordinate2D changedcoordinate = [self.zzcLocationChange MarsGS2WorldGS:coordinate];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    CLLocation *zzclocation = [[CLLocation alloc] initWithLatitude:changedcoordinate.latitude longitude:changedcoordinate.longitude];
    
    [_editPoints addObject:zzclocation];
    MKPointAnnotation* annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = location.coordinate;
    NSString *string1 = [[NSString alloc] initWithFormat:@"纬度:%f", annotation.coordinate.latitude];
    NSString *string2 = [[NSString alloc] initWithFormat:@"经度:%f", annotation.coordinate.longitude];
    [annotation setTitle:string1];
    [annotation setSubtitle:string2];
    //[self.mkPointAnns addObject:annotation];
    [mapView addAnnotation:annotation];

}

- (void)updateEditingPoints:(CLLocation*)newLocaton withindex:(int)index{

    CLLocationCoordinate2D changedcoordinate = [self.zzcLocationChange MarsGS2WorldGS:newLocaton.coordinate];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:changedcoordinate.latitude longitude:changedcoordinate.longitude];
    [_editPoints setObject:location atIndexedSubscript:index];
    sqlitePoint * point = [[sqlitePoint alloc] init];
    sqlitePoint * oldPoint = [_route.point_array objectAtIndex:index];
    point.Id = oldPoint.Id;
    point.index = oldPoint.index;
    point.route_Id = oldPoint.route_Id;
    point.point_x = location.coordinate.latitude;
    point.point_y = location.coordinate.longitude;
    [_route.point_array setObject:point atIndexedSubscript:index];
    
}

- (void)updateHuanraoPoints:(CLLocation*)newLocaton{

    CLLocationCoordinate2D changedcoordinate = [self.zzcLocationChange MarsGS2WorldGS:newLocaton.coordinate];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:changedcoordinate.latitude longitude:changedcoordinate.longitude];
    double lat_change = location.coordinate.latitude - _centerLoc.coordinate.latitude;
    double lon_change = location.coordinate.longitude - _centerLoc.coordinate.longitude;
    
    
    
    CLLocationCoordinate2D newCoor1 = CLLocationCoordinate2DMake(_centerLoc.coordinate.latitude+lat_change, _centerLoc.coordinate.longitude + lon_change);
    CLLocationCoordinate2D newCoor2 = CLLocationCoordinate2DMake(_centerLoc.coordinate.latitude-lat_change, _centerLoc.coordinate.longitude + lon_change);
    CLLocationCoordinate2D newCoor3 = CLLocationCoordinate2DMake(_centerLoc.coordinate.latitude-lat_change, _centerLoc.coordinate.longitude - lon_change);
    CLLocationCoordinate2D newCoor4 = CLLocationCoordinate2DMake(_centerLoc.coordinate.latitude+lat_change, _centerLoc.coordinate.longitude - lon_change);
    
    CLLocation *newLoc1 = [[CLLocation alloc] initWithLatitude:newCoor1.latitude longitude:newCoor1.longitude];
    CLLocation *newLoc2 = [[CLLocation alloc] initWithLatitude:newCoor2.latitude longitude:newCoor2.longitude];
    CLLocation *newLoc3 = [[CLLocation alloc] initWithLatitude:newCoor3.latitude longitude:newCoor3.longitude];
    CLLocation *newLoc4 = [[CLLocation alloc] initWithLatitude:newCoor4.latitude longitude:newCoor4.longitude];
    
    
    [_editPoints setObject:newLoc1 atIndexedSubscript:0];
    sqlitePoint * point1 = [_route.point_array objectAtIndex:0];
    point1.point_x = newLoc1.coordinate.latitude;
    point1.point_y = newLoc1.coordinate.longitude;
    [_editPoints setObject:newLoc2 atIndexedSubscript:1];
    sqlitePoint * point2 = [_route.point_array objectAtIndex:1];
    point2.point_x = newLoc2.coordinate.latitude;
    point2.point_y = newLoc2.coordinate.longitude;
    [_editPoints setObject:newLoc3 atIndexedSubscript:2];
    sqlitePoint * point3 = [_route.point_array objectAtIndex:2];
    point3.point_x = newLoc3.coordinate.latitude;
    point3.point_y = newLoc3.coordinate.longitude;
    [_editPoints setObject:newLoc4 atIndexedSubscript:3];
    sqlitePoint * point4 = [_route.point_array objectAtIndex:3];
    point4.point_x = newLoc4.coordinate.latitude;
    point4.point_y = newLoc4.coordinate.longitude;
    
    
}

- (void)cleanAllPointsWithMapView:(MKMapView *)mapView
{
    [_editPoints removeAllObjects];
    [_route.point_array removeAllObjects];
    [mapView removeOverlay:_polygon];
    [mapView removeOverlay:_wqinxie_polygon];
    [mapView removeOverlay:_nqinxie_polygon];
    [mapView removeOverlay:_eqinxie_polygon];
    [mapView removeOverlay:_sqinxie_polygon];
    NSArray* annos = [NSArray arrayWithArray:mapView.annotations];
    for (int i = 0; i < annos.count; i++) {
        id<MKAnnotation> ann = [annos objectAtIndex:i];
        
        if (![ann isEqual:self.aircraftAnnotation]&&![ann isEqual:self.userAnnotation]) { //Add it to check if the annotation is the aircraft's and prevent it from removing
            [mapView removeAnnotation:ann];
        }
       
    }   
}


- (NSArray *)wayPoints
{
    return self.editPoints;
}

-(void)updateAircraftLocation:(CLLocationCoordinate2D)location withMapView:(MKMapView *)mapView
{
    if (self.aircraftAnnotation == nil) {
        self.aircraftAnnotation = [[DJIAircraftAnnotation alloc] initWithCoordiante:location];
        [mapView addAnnotation:self.aircraftAnnotation];
        
    }
    
    [self.aircraftAnnotation setCoordinate:location];
}

-(void)updateAircraftHeading:(float)heading
{
    if (self.aircraftAnnotation) {
        [self.aircraftAnnotation updateHeading:heading];
    }
}

-(void)updateUserLocation:(CLLocationCoordinate2D)location withMapView:(MKMapView *)mapView
{
    if (self.userAnnotation == nil) {
        self.userAnnotation = [[DJIUserAnnotation alloc] initWithCoordiante:location];
        [mapView addAnnotation:self.userAnnotation];
    }
    
    [self.userAnnotation setCoordinate:location];
}

-(void)updateUserHeading:(float)heading
{
    if (self.userAnnotation) {
        [self.userAnnotation updateHeading:heading];
    }
}


- (void)annKeepEditPoints:(NSMutableArray*)annPoints{

    for (int i = 0 ; i < annPoints.count; i++) {
        MKPointAnnotation* ann = [annPoints objectAtIndex:i];
        CLLocationCoordinate2D coor_World = [self.zzcLocationChange MarsGS2WorldGS:ann.coordinate];
        CLLocation* location = [[CLLocation alloc] initWithLatitude:coor_World.latitude longitude:coor_World.longitude];
        self.editPoints[i] = location;
    }

}

- (CLLocationCoordinate2D)setPolygonView:(NSMutableArray*)initPoints withMapView:(MKMapView *)mapView  withCenterView:(UIView *)centerView withCenterCoor:(CLLocationCoordinate2D) centerCoor{
    
    
    
    CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(0, 0);
    CGPoint centerPoints[initPoints.count];
    CLLocationCoordinate2D Points[initPoints.count];
    for (int i =0; initPoints != nil&&i < initPoints.count; i++) {
        CLLocation *location = [initPoints objectAtIndex:i];
        CLLocationCoordinate2D coordinate = location.coordinate;
        CLLocationCoordinate2D coordinateChange = [self.zzcLocationChange WorldGS2MarsGS:coordinate];
        Points[i] = coordinateChange;
        CGPoint temp_poi = [mapView convertCoordinate:coordinateChange toPointToView:mapView];
        centerPoints[i] = temp_poi;
        
        mapCenter.latitude = mapCenter.latitude + coordinate.latitude;
        mapCenter.longitude = mapCenter.longitude + coordinate.longitude;
    }
    
    
    _centerLoc = [[CLLocation alloc] initWithLatitude:mapCenter.latitude/_editPoints.count longitude:mapCenter.longitude/_editPoints.count];
    
    CGPoint centerPoint = CGPointMake(0, 0);
    
    for (int i = 0; i < initPoints.count ; i++) {
        centerPoint.x = centerPoint.x + centerPoints[i].x;
        centerPoint.y = centerPoint.y + centerPoints[i].y;
    }
    
    centerPoint.x = centerPoint.x / initPoints.count ;
    centerPoint.y = centerPoint.y / initPoints.count ;
    
    
    centerCoor = [mapView convertPoint:centerPoint toCoordinateFromView:mapView];
    
    centerView.center = centerPoint;
    [centerView setHidden:NO];
    
    if (_polygon == nil) {
        _polygon = [MKPolygon polygonWithCoordinates:Points count:initPoints.count];
        [mapView addOverlay:_polygon];
    }
    [mapView removeOverlay:_polygon];
    _polygon = [MKPolygon polygonWithCoordinates:Points count:initPoints.count];
    [mapView addOverlay:_polygon];
    
    return centerCoor;
}

- (CLLocationCoordinate2D)setPolygonView1:(NSMutableArray*)initPoints withMapView:(MKMapView *)mapView  withCenterView:(UIView *)centerView withCenterCoor:(CLLocationCoordinate2D) centerCoor{
    
    
    
    CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(0, 0);
    CGPoint centerPoints[initPoints.count];
    CLLocationCoordinate2D Points[initPoints.count];
    for (int i =0; initPoints != nil&&i < initPoints.count; i++) {
        CLLocation *location = [initPoints objectAtIndex:i];
        CLLocationCoordinate2D coordinate = location.coordinate;
        CLLocationCoordinate2D coordinateChange = [self.zzcLocationChange WorldGS2MarsGS:coordinate];
        Points[i] = coordinateChange;
        CGPoint temp_poi = [mapView convertCoordinate:coordinateChange toPointToView:mapView];
        centerPoints[i] = temp_poi;
        
        mapCenter.latitude = mapCenter.latitude + coordinate.latitude;
        mapCenter.longitude = mapCenter.longitude + coordinate.longitude;
    }
    
    
    _centerLoc = [[CLLocation alloc] initWithLatitude:mapCenter.latitude/_editPoints.count longitude:mapCenter.longitude/_editPoints.count];
    
    CGPoint centerPoint = CGPointMake(0, 0);
    
    for (int i = 0; i < initPoints.count ; i++) {
        centerPoint.x = centerPoint.x + centerPoints[i].x;
        centerPoint.y = centerPoint.y + centerPoints[i].y;
    }
    
    centerPoint.x = centerPoint.x / initPoints.count ;
    centerPoint.y = centerPoint.y / initPoints.count ;
    
    
    centerCoor = [mapView convertPoint:centerPoint toCoordinateFromView:mapView];
    
    if (CLLocationCoordinate2DIsValid(centerCoor)) {
        MKCoordinateRegion region = {0};
        region.center = centerCoor;
        region.span.latitudeDelta = 0.005;
        region.span.longitudeDelta = 0.005;
        
        [mapView setRegion:region animated:YES];
    }
    
    centerView.center = centerPoint;
    [centerView setHidden:NO];
    
    if (_polygon == nil) {
        _polygon = [MKPolygon polygonWithCoordinates:Points count:initPoints.count];
        [mapView addOverlay:_polygon];
    }
    [mapView removeOverlay:_polygon];
    _polygon = [MKPolygon polygonWithCoordinates:Points count:initPoints.count];
    [mapView addOverlay:_polygon];
    
    return centerCoor;
}

- (void) setqinxiePolygonView:(NSMutableArray*)westPoints northPoints:(NSMutableArray*)northPoints eastPoints:(NSMutableArray*)eastPoints southPoints:(NSMutableArray*)southPoints withMapView:(MKMapView *)mapView{

    
    CLLocationCoordinate2D Points[westPoints.count];
    for (int i =0; westPoints != nil&&i < westPoints.count; i++) {
        CLLocation *location = [westPoints objectAtIndex:i];
        CLLocationCoordinate2D coordinate = location.coordinate;
        CLLocationCoordinate2D coordinateChange = [self.zzcLocationChange WorldGS2MarsGS:coordinate];
        Points[i] = coordinateChange;
    }
    
    if (_wqinxie_polygon == nil) {
        _wqinxie_polygon = [MKPolygon polygonWithCoordinates:Points count:westPoints.count];
        [mapView addOverlay:_wqinxie_polygon];
    }
    [mapView removeOverlay:_wqinxie_polygon];
    _wqinxie_polygon = [MKPolygon polygonWithCoordinates:Points count:westPoints.count];
    [mapView addOverlay:_wqinxie_polygon];
    
    
    CLLocationCoordinate2D Points1[northPoints.count];
    for (int i =0; northPoints != nil&&i < northPoints.count; i++) {
        CLLocation *location = [northPoints objectAtIndex:i];
        CLLocationCoordinate2D coordinate = location.coordinate;
        CLLocationCoordinate2D coordinateChange = [self.zzcLocationChange WorldGS2MarsGS:coordinate];
        Points1[i] = coordinateChange;
    }
    
    if (_nqinxie_polygon == nil) {
        _nqinxie_polygon = [MKPolygon polygonWithCoordinates:Points1 count:northPoints.count];
        [mapView addOverlay:_nqinxie_polygon];
    }
    [mapView removeOverlay:_nqinxie_polygon];
    _nqinxie_polygon = [MKPolygon polygonWithCoordinates:Points1 count:northPoints.count];
    [mapView addOverlay:_nqinxie_polygon];
    
    
    CLLocationCoordinate2D Points2[eastPoints.count];
    for (int i =0; eastPoints != nil&&i < eastPoints.count; i++) {
        CLLocation *location = [eastPoints objectAtIndex:i];
        CLLocationCoordinate2D coordinate = location.coordinate;
        CLLocationCoordinate2D coordinateChange = [self.zzcLocationChange WorldGS2MarsGS:coordinate];
        Points2[i] = coordinateChange;
    }
    
    if (_eqinxie_polygon == nil) {
        _eqinxie_polygon = [MKPolygon polygonWithCoordinates:Points2 count:eastPoints.count];
        [mapView addOverlay:_eqinxie_polygon];
    }
    [mapView removeOverlay:_eqinxie_polygon];
    _eqinxie_polygon = [MKPolygon polygonWithCoordinates:Points2 count:eastPoints.count];
    [mapView addOverlay:_eqinxie_polygon];
    
    
    CLLocationCoordinate2D Points3[southPoints.count];
    for (int i =0; southPoints != nil&&i < southPoints.count; i++) {
        CLLocation *location = [southPoints objectAtIndex:i];
        CLLocationCoordinate2D coordinate = location.coordinate;
        CLLocationCoordinate2D coordinateChange = [self.zzcLocationChange WorldGS2MarsGS:coordinate];
        Points3[i] = coordinateChange;
    }
    
    if (_sqinxie_polygon == nil) {
        _sqinxie_polygon = [MKPolygon polygonWithCoordinates:Points3 count:southPoints.count];
        [mapView addOverlay:_sqinxie_polygon];
    }
    [mapView removeOverlay:_sqinxie_polygon];
    _sqinxie_polygon = [MKPolygon polygonWithCoordinates:Points3 count:southPoints.count];
    [mapView addOverlay:_sqinxie_polygon];
    

}

- (void)setPointView:(NSMutableArray*)initPoints withMapView:(MKMapView *)mapView{

    NSArray* annos = [NSArray arrayWithArray:mapView.annotations];
    for (int i = 0; i < annos.count; i++) {
        id<MKAnnotation> ann = [annos objectAtIndex:i];
        
        if ([ann isKindOfClass:[MKPointAnnotation class]]) { //Add it to check if the annotation is the aircraft's and prevent it from removing
            [mapView removeAnnotation:ann];
        }
        
    }
    for (int i =0; initPoints != nil&&i < initPoints.count; i++) {
        CLLocation *location = [initPoints objectAtIndex:i];
        CLLocationCoordinate2D coordinate = location.coordinate;
        CLLocationCoordinate2D coordinateChange = [self.zzcLocationChange WorldGS2MarsGS:coordinate];
        MKPointAnnotation* annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = coordinateChange;
        NSString *string1 = [[NSString alloc] initWithFormat:@"纬度:%f", annotation.coordinate.latitude];
        NSString *string2 = [[NSString alloc] initWithFormat:@"经度:%f", annotation.coordinate.longitude];
        [annotation setTitle:string1];
        [annotation setSubtitle:string2];
        [mapView addAnnotation:annotation];
    }
    

}

- (void)setMiddlePoint:(NSMutableArray*)initPoints withMapView:(MKMapView *)mapView{

    
    NSArray* annos = [NSArray arrayWithArray:mapView.annotations];
    for (int i = 0; i < annos.count; i++) {
        id<MKAnnotation> ann = [annos objectAtIndex:i];
        
        if ([ann isKindOfClass:[ZZCMiddleAnnotaion class]]) { //Add it to check if the annotation is the aircraft's and prevent it from removing
            [mapView removeAnnotation:ann];
        }
        
    }
    
    
    for (int i = 0; initPoints.count>0&&i < initPoints.count; i++) {
        CLLocation * location = [initPoints objectAtIndex:i];
        CLLocation * location1;
        if (i != initPoints.count - 1) {
            location1 = [initPoints objectAtIndex:i+1];
        }else{
            location1 = [initPoints objectAtIndex:0];
        }
        
        double midLat = (location.coordinate.latitude + location1.coordinate.latitude)/2;
        double midLon = (location.coordinate.longitude + location1.coordinate.longitude)/2;
        
        CLLocationCoordinate2D midCod = CLLocationCoordinate2DMake(midLat, midLon);
        CLLocationCoordinate2D changedMidCod = [self.zzcLocationChange WorldGS2MarsGS:midCod ];
        ZZCMiddleAnnotaion *midAnn = [[ZZCMiddleAnnotaion alloc] initWithCoordiante:changedMidCod];
        midAnn.index = i+1;
        [mapView addAnnotation:midAnn];
        
    }
    
    
}

@end
