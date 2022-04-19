//
//  redPolyLineView.m
//  MediaManagerDemo
//
//  Created by Apple on 2018/9/12.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import "redPolyLineView.h"

@implementation redPolyLineView

- (instancetype)initWithPolyline:(MKPolyline *)polyline{
    
    self = [super initWithPolyline:polyline];
    if (self) {
        self.strokeColor = [UIColor redColor];
        self.lineWidth = 5.0;
    }
    
    return self;
}

@end
