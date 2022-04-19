//
//  DJIRouteAnnotion.h
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/19.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIRouteAnnotionView.h"
@interface DJIRouteAnnotion : NSObject<MKAnnotation>

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) int index;//为了解决手动选择出发点的事请设置了这个参数
@property(nonatomic, weak) DJIRouteAnnotionView* annotationView;

-(id) initWithCoordiante:(CLLocationCoordinate2D)coordinate;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

- (void)setIIndex:(int)iindex;

@end
