//
//  CircleAnimationView.h
//  CircleAnimation
//
//  Created by fujin on 15/10/19.
//  Copyright © 2015年 fujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleAnimationView : UIView
/**
 *  传入的百分比（0-100）
 */
@property (nonatomic, strong) NSString *percentStr;
/**
 *  恢复原位置
 */
-(void)clear;
@end
