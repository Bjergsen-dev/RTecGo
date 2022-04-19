//
//  PointerView.m
//  CircleAnimation
//
//  Created by fujin on 15/10/21.
//  Copyright © 2015年 fujin. All rights reserved.
//

#import "PointerView.h"
#define RGBA(r,g,b,a)      [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:a]
@interface PointerView ()
@property (nonatomic, assign) CGFloat startAngle;
@end
@implementation PointerView
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addPointer];
    }
    return self;
}

-(void)addPointer{
    //三角形
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0, -(self.frame.size.height)/2.0 + (17/2.0))];
    [path addLineToPoint:CGPointMake(-10, -(self.frame.size.height)/2.0 + (17/2.0) + 10)];
    [path addLineToPoint:CGPointMake(10, -(self.frame.size.height)/2.0 + (17/2.0) + 10)];
    [path moveToPoint:CGPointMake(0, -(self.frame.size.height)/2.0 + (17/2.0))];
    
    //使用applyTransform函数来转移坐标的Transform，这样我们不用按照实际显示做坐标计算
    [path applyTransform:CGAffineTransformMakeTranslation(self.frame.size.width*0.5, self.frame.size.height*0.5)];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.fillColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:layer];
    
    
    //圆形°
    UIBezierPath *circlePath = [UIBezierPath bezierPath];
    [circlePath addArcWithCenter:CGPointMake(0, -(self.frame.size.height)/2.0 + (17/2.0) + 10 + 10) radius:10 startAngle:(3/2*M_PI) endAngle:(3/2*M_PI + 2*M_PI) clockwise:YES];
    
    //使用applyTransform函数来转移坐标的Transform，这样我们不用按照实际显示做坐标计算
    [circlePath applyTransform:CGAffineTransformMakeTranslation(self.frame.size.width*0.5, self.frame.size.height*0.5)];
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.path = circlePath.CGPath;
    circleLayer.fillColor = RGBA(116, 201, 0, 1).CGColor;
    [self.layer addSublayer:circleLayer];
}

-(void)updatePointer:(NSInteger)percent withAnimationTime:(CGFloat)animationTime{
    CGFloat angle = percent/100.0 * (M_PI*2);
    
    //旋转动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = animationTime;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    animation.autoreverses = NO;
    animation.fromValue = [NSNumber numberWithFloat:self.startAngle];
    animation.toValue = [NSNumber numberWithFloat:angle];
    animation.delegate = self;
    [animation setValue:[NSNumber numberWithFloat:angle] forKey:@"angle"];
    [self.layer addAnimation:animation forKey:@"rotationAnimation"];
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    CGFloat angle = [[anim valueForKey:@"angle"] floatValue];
    self.startAngle = angle;
    self.layer.transform = CATransform3DMakeRotation(angle, 0, 0, 1);
}

-(void)clear{
    self.transform = CGAffineTransformMakeRotation(0);
    self.startAngle = 0.0;
}
@end
