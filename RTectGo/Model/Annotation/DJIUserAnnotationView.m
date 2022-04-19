//
//  DJIUserAnnotationView.m
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/10.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import "DJIUserAnnotationView.h"

@implementation DJIUserAnnotationView

- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.enabled = NO;
        self.draggable = NO;
        self.image = [UIImage imageNamed:@"用户位置.png"];
    }
    
    return self;
}

-(void) updateHeading:(float)heading
{
    self.transform = CGAffineTransformIdentity;
    self.transform = CGAffineTransformMakeRotation(heading);
    
    
}


@end
