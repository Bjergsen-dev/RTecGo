//
//  SZKCustomAlter.m
//  RTectGo
//
//  Created by Apple on 2019/3/22.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import "SZKCustomAlter.h"

@implementation SZKCustomAlter

+(void)showAlter:(NSString *)message alertTime:(int)alertTime;
{
    UIAlertView *alter=[[UIAlertView alloc]initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [NSTimer scheduledTimerWithTimeInterval:alertTime target:self selector:@selector(timerAction:) userInfo:alter repeats:NO];
    [alter show];
}
+(void)timerAction:(NSTimer *)timer
{
    UIAlertView *alter=(UIAlertView *)[timer userInfo];
    [alter dismissWithClickedButtonIndex:0 animated:YES];
}

@end
