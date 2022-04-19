//
//  DJIRouteAnnotion.m
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/19.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import "DJIRouteAnnotion.h"

@implementation DJIRouteAnnotion

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

- (void)setIIndex:(int)iindex{

    self.index = iindex;

}
@end
