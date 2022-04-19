//
//  LocalMap.h
//  RTectGo
//
//  Created by Apple on 2019/2/23.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LocalMap : NSObject

@property (nonatomic, strong) NSString* time;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, assign) int Id;
@property (nonatomic, assign) int statuscode;
@property (nonatomic, assign) CLLocationCoordinate2D coor;

@end
