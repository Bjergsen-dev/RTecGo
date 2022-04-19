//
//  DJIUserAnnotation.h
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/10.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "DJIUserAnnotationView.h"
@interface DJIUserAnnotation : NSObject<MKAnnotation>

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, weak) DJIUserAnnotationView* annotationView;

-(id) initWithCoordiante:(CLLocationCoordinate2D)coordinate;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

-(void) updateHeading:(float)heading;

@end
