//
//  CheckTFView.m
//  RTectGo
//
//  Created by Apple on 2019/3/20.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import "CheckTFView.h"

@interface CheckTFView ()

@property (weak, nonatomic)  UILabel *altitude_lab;
@property (weak, nonatomic)  UILabel *pxrate_lab;
@property (weak, nonatomic)  UILabel *hxrate_lab;
@property (weak, nonatomic)  UILabel *routePointsNum_lab;
@property (weak, nonatomic)  UILabel *routeAngle_lab;
@property (weak, nonatomic)  UILabel *xiangjiAngle_lab;
@property (weak, nonatomic)  UILabel *feihua_lab;

@end

@implementation CheckTFView

// 1.重写initWithFrame:方法，创建子控件并添加到自己上面
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        // 1. lable
        UILabel * altitude_lab = [UILabel new];
        altitude_lab.textAlignment = NSTextAlignmentCenter;
        altitude_lab.textColor = [UIColor whiteColor];
        altitude_lab.backgroundColor = [UIColor clearColor];
        [altitude_lab setFont:[UIFont systemFontOfSize:20]];
        
        UILabel * pxrate_lab = [UILabel new];
        pxrate_lab.textAlignment = NSTextAlignmentCenter;
        pxrate_lab.textColor = [UIColor whiteColor];
        pxrate_lab.backgroundColor = [UIColor clearColor];
        [pxrate_lab setFont:[UIFont systemFontOfSize:20]];
        
        UILabel * hxrate_lab = [UILabel new];
        hxrate_lab.textAlignment = NSTextAlignmentCenter;
        hxrate_lab.textColor = [UIColor whiteColor];
        hxrate_lab.backgroundColor = [UIColor clearColor];
        [hxrate_lab setFont:[UIFont systemFontOfSize:20]];
        
        UILabel * routePointsNum_lab = [UILabel new];
        routePointsNum_lab.textAlignment = NSTextAlignmentCenter;
        routePointsNum_lab.textColor = [UIColor whiteColor];
        routePointsNum_lab.backgroundColor = [UIColor clearColor];
        [routePointsNum_lab setFont:[UIFont systemFontOfSize:20]];
        
        UILabel * routeAngle_lab = [UILabel new];
        routeAngle_lab.textAlignment = NSTextAlignmentCenter;
        routeAngle_lab.textColor = [UIColor whiteColor];
        routeAngle_lab.backgroundColor = [UIColor clearColor];
        [routeAngle_lab setFont:[UIFont systemFontOfSize:20]];
        
        UILabel * xiangjiAngle_lab = [UILabel new];
        xiangjiAngle_lab.textAlignment = NSTextAlignmentCenter;
        xiangjiAngle_lab.textColor = [UIColor whiteColor];
        xiangjiAngle_lab.backgroundColor = [UIColor clearColor];
        [xiangjiAngle_lab setFont:[UIFont systemFontOfSize:20]];
        
        UILabel * feihua_lab = [UILabel new];
        feihua_lab.textAlignment = NSTextAlignmentCenter;
        feihua_lab.textColor = [UIColor whiteColor];
        feihua_lab.backgroundColor = [UIColor clearColor];
        [feihua_lab setFont:[UIFont systemFontOfSize:40]];
        feihua_lab.adjustsFontSizeToFitWidth = YES;
        
        self.altitude_lab = altitude_lab;
        [self addSubview:self.altitude_lab];
        
        self.pxrate_lab = pxrate_lab;
        [self addSubview:self.pxrate_lab];
        
        self.hxrate_lab = hxrate_lab;
        [self addSubview:self.hxrate_lab];
        
        self.routePointsNum_lab = routePointsNum_lab;
        [self addSubview:self.routePointsNum_lab];
        
        self.routeAngle_lab = routeAngle_lab;
        [self addSubview:self.routeAngle_lab];
        
        self.xiangjiAngle_lab = xiangjiAngle_lab;
        [self addSubview:self.xiangjiAngle_lab];
        
        self.feihua_lab = feihua_lab;
        [self addSubview:self.feihua_lab];

        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }
    return self;
}


// 2.重写layoutSubviews，给自己内部子控件设置frame
- (void)layoutSubviews
{
    
    
//    @property (weak, nonatomic)  UILabel *altitude_lab;
//    @property (weak, nonatomic)  UILabel *pxrate_lab;
//    @property (weak, nonatomic)  UILabel *hxrate_lab;
//    @property (weak, nonatomic)  UILabel *routePointsNum_lab;
//    @property (weak, nonatomic)  UILabel *routeAngle_lab;
//    @property (weak, nonatomic)  UILabel *xiangjiAngle_lab;
//    @property (weak, nonatomic)  UILabel *feihua_lab;
    
    
    [super layoutSubviews];
    CGSize size = self.frame.size;
    self.feihua_lab.frame = CGRectMake(0, 0, size.width , size.height * 0.4);
    self.altitude_lab.frame = CGRectMake(0, size.height * 0.4, size.width, size.height *0.1);
    self.pxrate_lab.frame = CGRectMake(0, size.height * 0.5, size.width, size.height *0.1);
    self.hxrate_lab.frame = CGRectMake(0, size.height * 0.6, size.width, size.height *0.1);
    self.routePointsNum_lab.frame = CGRectMake(0, size.height * 0.7, size.width, size.height *0.1);
    self.routeAngle_lab.frame = CGRectMake(0, size.height * 0.8, size.width, size.height *0.1);
    self.xiangjiAngle_lab.frame = CGRectMake(0, size.height * 0.9, size.width, size.height *0.1);
    
}

// 3.调用模型的set方法，给书的子控件赋值，
- (void)setRoute:(sqliteRoute *)route
{
    _route = route;
    [_feihua_lab setText:@"请检查以下参数，注意观察四周！"];
    [_altitude_lab setText:[NSString stringWithFormat:@"航高为：%f",_route.height]];
    [_pxrate_lab setText:[NSString stringWithFormat:@"旁向重叠率为：%f",_route.pxChongdie]];
    [_hxrate_lab setText:[NSString stringWithFormat:@"航向重叠率为：%f",_route.hxChongdie]];
    [_routePointsNum_lab setText:[NSString stringWithFormat:@"航点数为：%d",_route.pointCount]];
    [_routeAngle_lab setText:[NSString stringWithFormat:@"航线角度为：%d",_route.angle]];
    [_xiangjiAngle_lab setText:[NSString stringWithFormat:@"相机倾角为：%d",_route.qinxieAngle]];
    
    

}

@end
