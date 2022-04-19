//
//  DJIWaypointConfigViewController.h
//  GSDemo
//
//  Created by DJI on 12/7/15.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZCRoutePlan.h"

@class DJIWaypointConfigViewController;

@protocol DJIWaypointConfigViewControllerDelegate <NSObject>

- (void)cancelBtnActionInDJIWaypointConfigViewController:(DJIWaypointConfigViewController *)waypointConfigVC;
- (void)finishBtnActionInDJIWaypointConfigViewController:(DJIWaypointConfigViewController *)waypointConfigVC;

@end

@interface DJIWaypointConfigViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *altitudeTextField;
@property (weak, nonatomic) IBOutlet UITextField *autoFlightSpeedTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxFlightSpeedTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *actionSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *headingSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *hxChongdieTextField;
@property (weak, nonatomic) IBOutlet UILabel *hxChongdieLabel;
@property (weak, nonatomic) IBOutlet UITextField *pxChongdieTextField;
@property (weak, nonatomic) IBOutlet UILabel *pxChongdieLabel;
@property (weak, nonatomic) IBOutlet UITextField *angleTextField;
@property (weak, nonatomic) IBOutlet UILabel *qinxieAngleLabel;
@property (weak, nonatomic) IBOutlet UITextField *qinxieAngleField;

//飞行模式 本处与外部选择的mode必须一致
@property (assign, nonatomic) ZZCRouteMode mode;

@property (weak, nonatomic) id <DJIWaypointConfigViewControllerDelegate>delegate;
- (void) setModeUI:(ZZCRouteMode) mode height:(int)height angle:(int)angle px_CD:(double)px_CD hx_CD:(double)hx_CD qinxieAngle:(int) qinxieAngle;

- (IBAction)cancelBtnAction:(id)sender;
- (IBAction)finishBtnAction:(id)sender;

@end
