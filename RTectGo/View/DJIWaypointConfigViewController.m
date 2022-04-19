//
//  DJIWaypointConfigViewController.m
//  GSDemo
//
//  Created by DJI on 12/7/15.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import "DJIWaypointConfigViewController.h"

@interface DJIWaypointConfigViewController ()

@end

@implementation DJIWaypointConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    
    
    
    self.altitudeTextField.text = @"110"; //Set the altitude to 20
    self.autoFlightSpeedTextField.text = @"8"; //Set the autoFlightSpeed to 8
    self.maxFlightSpeedTextField.text = @"10"; //Set the maxFlightSpeed to 10
    self.hxChongdieTextField.text = @"0.8";
    self.pxChongdieTextField.text = @"0.6";
    self.angleTextField.text = @"60";
    self.qinxieAngleField.text = @"45";
    [self.actionSegmentedControl setSelectedSegmentIndex:1]; //Set the finishAction to DJIWaypointMissionFinishedGoHome
    [self.headingSegmentedControl setSelectedSegmentIndex:3]; //Set the headingMode to DJIWaypointMissionHeadingAuto
}


- (void) setModeUI:(ZZCRouteMode) mode height:(int)height angle:(int)angle px_CD:(double)px_CD hx_CD:(double)hx_CD qinxieAngle:(int)qinxieAngle{
    
    if (mode == ZZCRouteMode_quanjin) {
        [_hxChongdieLabel setHidden:YES];
        [_hxChongdieTextField setHidden:YES];
        [_pxChongdieLabel setHidden:YES];
        [_pxChongdieTextField setHidden:YES];
        [_angleTextField setHidden:YES];
    }
    if (mode != ZZCRouteMode_qinxie) {
        [_qinxieAngleField setHidden:YES];
        [_qinxieAngleLabel setHidden:YES];
    }
    
    [_altitudeTextField setText:[NSString stringWithFormat:@"%d",height]];
    [_angleTextField setText:[NSString stringWithFormat:@"%d",angle]];
    [_pxChongdieTextField setText:[NSString stringWithFormat:@"%f",px_CD]];
    [_hxChongdieTextField setText:[NSString stringWithFormat:@"%f",hx_CD]];
    [_qinxieAngleField setText:[NSString stringWithFormat:@"%d",qinxieAngle]];
}

- (IBAction)cancelBtnAction:(id)sender {
 
    if ([_delegate respondsToSelector:@selector(cancelBtnActionInDJIWaypointConfigViewController:)]) {
        [_delegate cancelBtnActionInDJIWaypointConfigViewController:self];
    }
}

- (IBAction)finishBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(finishBtnActionInDJIWaypointConfigViewController:)]) {
        [_delegate finishBtnActionInDJIWaypointConfigViewController:self];
    }
    
}

@end
