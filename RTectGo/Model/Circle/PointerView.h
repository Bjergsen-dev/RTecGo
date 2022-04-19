//
//  PointerView.h
//  CircleAnimation
//
//  Created by fujin on 15/10/21.
//  Copyright © 2015年 fujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PointerView : UIView
/**
 *  转动指针
 *
 *  @param percent       （0-100）
 *  @param animationTime 动画时间
 */
-(void)updatePointer:(NSInteger)percent withAnimationTime:(CGFloat)animationTime;
/**
 *  恢复原位置
 */
-(void)clear;
@end
