//
//  WapianAnnotation.h
//  RTectGo
//
//  Created by Apple on 2019/1/22.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WapianAnnotationView.h"

@interface WapianAnnotation : NSObject<MKAnnotation>

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) int index;
@property(nonatomic, weak) WapianAnnotationView* annotationView;

-(id) initWithCoordiante:(CLLocationCoordinate2D)coordinate;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

- (void)setIIndex:(int)iindex;
@end
