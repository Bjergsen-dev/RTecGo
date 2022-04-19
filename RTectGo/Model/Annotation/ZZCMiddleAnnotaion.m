//
//  ZZCMiddleAnnotaion.m
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/25.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import "ZZCMiddleAnnotaion.h"

@implementation ZZCMiddleAnnotaion


-(id) initWithCoordiante:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
    }
    
    return self;
}

@end
