//
//  DJIUserAnnotationView.h
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/10.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DJIUserAnnotationView : MKAnnotationView

-(void) updateHeading:(float)heading;
@end
