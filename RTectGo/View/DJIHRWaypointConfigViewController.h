//
//  DJIHRWaypointConfigViewController.h
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/30.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZCRoutePlan.h"

@class DJIHRWaypointConfigViewController;

@protocol DJIHRWaypointConfigViewControllerDelegate <NSObject>

- (void)cancelBtnActionInDJIHRWaypointConfigViewController:(DJIHRWaypointConfigViewController *)waypointConfigVC;
- (void)finishBtnActionInDJIHRWaypointConfigViewController:(DJIHRWaypointConfigViewController *)waypointConfigVC;

@end


@interface DJIHRWaypointConfigViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *low_altitudeTextField;
@property (weak, nonatomic) IBOutlet UITextField *high_altitudeTextField;
@property (weak, nonatomic) IBOutlet UITextField *autoFlightSpeedTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxFlightSpeedTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *actionSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *headingSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *hxChongdieTextField;
@property (weak, nonatomic) IBOutlet UITextField *pxChongdieTextField;


@property (weak, nonatomic) id <DJIHRWaypointConfigViewControllerDelegate>delegate;
- (void) setModeUI:(int) l_height height:(int)height  px_CD:(double)px_CD hx_CD:(double)hx_CD;


- (IBAction)HR_cancelBtnAction:(id)sender;
- (IBAction)HR_finishBtnAction:(id)sender;


@end
