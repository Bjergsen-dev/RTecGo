//
//  LJKSlideView.m
//  RTectGo
//
//  Created by Apple on 2019/3/19.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import "LJKSlideView.h"

#define COLOFOR0X(c)    [UIColor colorWithRed:((c>>16)&0xFF)/255.0  \
green:((c>>8)&0xFF)/255.0   \
blue:(c&0xFF)/255.0         \
alpha:1.0]

#define COLOFOR0XALPHA(c,a)    [UIColor colorWithRed:((c>>16)&0xFF)/255.0   \
green:((c>>8)&0xFF)/255.0   \
blue:(c&0xFF)/255.0         \
alpha:a]

@interface LJKSlideView (){
    
    UIView *_touchView;//滑动的点击区域 即绿色部分
    UIView *_shadowView;//滑动区域内部最右边的阴影 增加层次感
    
    UIImageView *_arrowImageView;//滑动区域内部 右箭头ImageView
    UIImageView *_imageView;//滑动区域右边 三个点的ImageView
    
    UILabel *_messageLabel;//立即解锁Label
    
    CGRect _touchViewFrame;//滑动区域的初始frame 重置的时候会用到
    
    CGFloat _labelXCutImageX;//立即解锁与右箭头 x坐标的差值  之后做动画会用到
    
}
@end

@implementation LJKSlideView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    
    _touchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width * 0.55, self.bounds.size.height)];
    //这里我的滑动区域初始宽度为控件宽度的0.55 可以根据需要改动
    _touchView.layer.masksToBounds = YES;//防止做动画的时候视图错乱
    //_touchView.layer.cornerRadius = 20;
    _touchView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];//这是一个16进制转RGB宏 放在文章最后
    
    _touchViewFrame = _touchView.frame;
    CGSize touchViewSize = _touchView.frame.size;
    
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.text = @"右滑开始飞行";
    _messageLabel.textColor = [UIColor whiteColor];
    [_messageLabel sizeToFit];
    [_touchView addSubview:_messageLabel];
    _messageLabel.center = _touchView.center;
    
    _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(touchViewSize.width - 23, touchViewSize.height / 2.0 - 10, 15, 20)];
    //箭头的frame可以根据需要改动 需要注意的只有x坐标就是（seize.with - (imageView的宽度 + imageView到父视图右边的距离)）
    _arrowImageView.image = [UIImage imageNamed:@"右箭头"];
    _arrowImageView.contentMode = UIViewContentModeScaleAspectFill;
    [_touchView addSubview:_arrowImageView];
    
    _labelXCutImageX = _messageLabel.frame.origin.x - _arrowImageView.frame.origin.x;
    
    _shadowView = [[UIView alloc] initWithFrame:CGRectMake(touchViewSize.width - 1, 5, 1, touchViewSize.height - 10)];
    _shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    //_shadowView.layer.borderWidth = 5;
    _shadowView.layer.shadowOpacity = 1;
    _shadowView.layer.shadowRadius = 2.5;
    _shadowView.layer.shadowOffset = CGSizeMake(0,0);
    _shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_shadowView.bounds].CGPath;
    [_touchView addSubview:_shadowView];//可以根据需要调节阴影效果
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(touchViewSize.width, 0, self.bounds.size.width - touchViewSize.width, touchViewSize.height)];
    label.text = @"右滑动操作";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = COLOFOR0X(0xd2d2d2);
    label.textAlignment = NSTextAlignmentCenter;
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(touchViewSize.width, touchViewSize.height / 2.0 - 10, 20, 20)];
    _imageView.image = [UIImage imageNamed:@"按钮空"];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    
    [self addSubview:label];
    [self addSubview:_imageView];
    [self addSubview:_touchView];//要注意保证滑动区域在视图最上层
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if (touch.view != _touchView || _touchView.frame.size.width == self.bounds.size.width) {
        return;//如果点击的不是滑动区域  或者滑动区域已经滑动到控件最右边 都不继续做变动
    }
    CGPoint pointNow = [touch locationInView:self];
    CGPoint pointPrevious = [touch previousLocationInView:self];
    
    CGRect frame = _touchView.frame;
    frame.size.width += pointNow.x - pointPrevious.x;
    
    if (frame.size.width > self.bounds.size.width) {
        frame.size.width = self.bounds.size.width;//产生滑块滑到控件最右边刚好停止的效果
    }
    
    [self changeTouchViewFrameWithFrame:frame];
}


- (void)changeTouchViewFrameWithFrame:(CGRect)frame{
    
    [UIView animateWithDuration:frame.size.width == _touchViewFrame.size.width?0.218:0 delay:0
                        options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         //这里的三目运算符主要是为了判断是不是复位 如果是复位的时候给个动画效果 否则 平时滑动的时候不需要动画效果
                         
                         _touchView.frame = frame;
                         
                         CGRect frame1 = _imageView.frame;
                         frame1.origin.x = frame.size.width;
                         _imageView.frame = frame1;
                         
                         CGRect frame2 = _shadowView.frame;
                         frame2.origin.x = frame.size.width - 1;
                         _shadowView.frame = frame2;
                         
                     } completion:^(BOOL finished) {
                     }];
    
    
    [UIView animateWithDuration:0.168 delay:0.05 options:UIViewAnimationOptionLayoutSubviews animations:^{
        //箭头的动画 放在滑动区域尺寸变化之后 形成滑动区域右边框拖拽或者挤压箭头的效果
        CGRect frame1 = _arrowImageView.frame;
        frame1.origin.x = frame.size.width - 23;
        _arrowImageView.frame = frame1;
        
    } completion:^(BOOL finished) {
    }];
    
    [UIView animateWithDuration:0.168 delay:0.15 options:UIViewAnimationOptionLayoutSubviews animations:^{
        //Label的动画 放在箭头尺寸变化之后 形成箭头拖拽或者挤压Label的效果
        CGRect frame1 = _messageLabel.frame;
        frame1.origin.x = _arrowImageView.frame.origin.x + _labelXCutImageX;
        _messageLabel.frame = frame1;
        
    } completion:^(BOOL finished) {
    }];
    
    //时间差的越多 拖拽效果越明显 但是越不柔和
}



- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    
    if (touch.view != _touchView) {
        return;
    }
    
    if (_touchView.frame.size.width >= 0.7 * self.bounds.size.width) {
        //滑动解锁触发的宽度根据需要修改  我这里是滑动到超过或等于0.7个控件宽度就视为解锁成功
        //如果需要传统的滑动到最右边才视为解锁 此处改为_touchView.frame.size.width == self.bounds.size.width即可
        
        if (self.slideNeedDoSometingBlock) {
            self.slideNeedDoSometingBlock();
        }
        
        if ([self.delegate respondsToSelector:@selector(slideNeedDoSometing)]) {
            [self.delegate slideNeedDoSometing];
        }
    }
    
    //回到初始状态
    [self changeTouchViewFrameWithFrame:_touchViewFrame];
}

@end
