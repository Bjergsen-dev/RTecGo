//
//  ZZCMiddleAnnotaion.h
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/25.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface ZZCMiddleAnnotaion : NSObject<MKAnnotation>

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) int index;

-(id) initWithCoordiante:(CLLocationCoordinate2D)coordinate;

@end
