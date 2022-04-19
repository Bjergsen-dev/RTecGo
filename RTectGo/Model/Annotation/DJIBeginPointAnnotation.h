//
//  DJIBeginPointAnnotation.h
//  MediaManagerDemo
//
//  Created by Apple on 2018/8/20.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIBeginPointAnnotationView.h"
@interface DJIBeginPointAnnotation : NSObject<MKAnnotation>

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, weak) DJIBeginPointAnnotationView* annotationView;

-(id) initWithCoordiante:(CLLocationCoordinate2D)coordinate;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
