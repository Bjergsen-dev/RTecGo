//
//  DJIRouteAnnotionView.m
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/19.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import "DJIRouteAnnotionView.h"

@implementation DJIRouteAnnotionView

- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.enabled = YES;
        self.draggable = NO;
        self.image = [UIImage imageNamed:@"circle_yellow.png"];
    }
    
    return self;
}

@end
