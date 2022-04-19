//
//  WapianAnnotation.m
//  RTectGo
//
//  Created by Apple on 2019/1/22.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import "WapianAnnotation.h"

@implementation WapianAnnotation

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
