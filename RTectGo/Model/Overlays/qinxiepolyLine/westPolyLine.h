//
//  westPolyLine.h
//  MediaManagerDemo
//
//  Created by Apple on 2018/9/12.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "redPolyLineView.h"
@interface westPolyLine : MKPolyline
@property(nonatomic, weak) redPolyLineView* polylineView;
@end
