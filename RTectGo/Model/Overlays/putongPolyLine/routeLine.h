//
//  routeLine.h
//  MediaManagerDemo
//
//  Created by Apple on 2018/9/12.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "routePolyline.h"

@interface routeLine : MKPolyline
@property(nonatomic, weak) routePolyline* polylineView;
@end
