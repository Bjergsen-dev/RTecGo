//
//  WapianAnnotationView.m
//  RTectGo
//
//  Created by Apple on 2019/1/22.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import "WapianAnnotationView.h"

@implementation WapianAnnotationView

- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        rightButton.backgroundColor = [UIColor grayColor];
        [rightButton setTitle:@"删除" forState:UIControlStateNormal];
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        leftButton.backgroundColor = [UIColor grayColor];
        [leftButton setTitle:@"取消" forState:UIControlStateNormal];
        
        self.rightCalloutAccessoryView = rightButton;
        self.leftCalloutAccessoryView = leftButton;
        
        
        self.enabled = YES;
        self.canShowCallout = NO;
        self.draggable = YES;
        self.image = [UIImage imageNamed:@"wapian.png"];
    }
    
    return self;
}

@end
