//
//  DJIUserAnnotation.m
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/10.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import "DJIUserAnnotation.h"

@implementation DJIUserAnnotation

-(id) initWithCoordiante:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
    }
    
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}

-(void) updateHeading:(float)heading
{
    if (self.annotationView) {
        [self.annotationView updateHeading:heading];
    }
}

@end
