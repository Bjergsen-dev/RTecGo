//
//  DJIHRWaypointConfigViewController.m
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/30.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import "DJIHRWaypointConfigViewController.h"

@interface DJIHRWaypointConfigViewController ()

@end

@implementation DJIHRWaypointConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)initUI
{
    self.low_altitudeTextField.text = @"10"; //Set the altitude to 5
    self.high_altitudeTextField.text = @"100"; //Set the altitude to 20
    self.autoFlightSpeedTextField.text = @"8"; //Set the autoFlightSpeed to 8
    self.maxFlightSpeedTextField.text = @"10"; //Set the maxFlightSpeed to 10
    self.hxChongdieTextField.text = @"0.8";
    self.pxChongdieTextField.text = @"0.6";
    [self.actionSegmentedControl setSelectedSegmentIndex:1]; //Set the finishAction to DJIWaypointMissionFinishedGoHome
    [self.headingSegmentedControl setSelectedSegmentIndex:3]; //Set the headingMode to DJIWaypointMissionHeadingAuto
    
}


- (void) setModeUI:(int) l_height height:(int)height  px_CD:(double)px_CD hx_CD:(double)hx_CD{
    
    [_low_altitudeTextField setText:[NSString stringWithFormat:@"%d",l_height]];
    [_high_altitudeTextField setText:[NSString stringWithFormat:@"%d",height]];
    [_pxChongdieTextField setText:[NSString stringWithFormat:@"%f",px_CD]];
    [_hxChongdieTextField setText:[NSString stringWithFormat:@"%f",hx_CD]];
    
    
}

- (IBAction)HR_cancelBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(cancelBtnActionInDJIHRWaypointConfigViewController:)]) {
        [_delegate cancelBtnActionInDJIHRWaypointConfigViewController:self];
    }
}

- (IBAction)HR_finishBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(finishBtnActionInDJIHRWaypointConfigViewController:)]) {
        [_delegate finishBtnActionInDJIHRWaypointConfigViewController:self];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
