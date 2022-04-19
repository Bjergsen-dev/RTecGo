//
//  DJIBeginPointAnnotationView.m
//  MediaManagerDemo
//
//  Created by Apple on 2018/8/20.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import "DJIBeginPointAnnotationView.h"

@implementation DJIBeginPointAnnotationView

- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.enabled = NO;
        self.draggable = NO;
        self.image = [UIImage imageNamed:@"circle_red.png"];
    }
    
    return self;
}
@end
