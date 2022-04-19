//
//  DJIBeginPointAnnotation.m
//  MediaManagerDemo
//
//  Created by Apple on 2018/8/20.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import "DJIBeginPointAnnotation.h"

@implementation DJIBeginPointAnnotation

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

@end
