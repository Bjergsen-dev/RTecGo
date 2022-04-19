//
//  DJFlightModeViewController.m
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/16.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import "DJFlightModeViewController.h"

@interface DJFlightModeViewController ()

@end

@implementation DJFlightModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - Property Method


- (void) setimage:(UIButton*)Button{

    if (Button.tag == 1) {
        [Button setBackgroundImage:[UIImage imageNamed:@"按钮空"] forState:UIControlStateNormal];
    }else{
        
        
        [Button setBackgroundImage:[UIImage imageNamed:@"按钮绿"] forState:UIControlStateNormal];
    }
}

-(void) setMode:(UIButton*)Button Button2:(UIButton*)Button2 Button3:(UIButton*)Button3{

    
    Button.tag = -Button.tag;
    Button2.tag = 1;
    Button3.tag = 1;
    [self setimage:Button];
    [self setimage:Button2];
    [self setimage:Button3];
    
   

}

#pragma mark - IBAction Methods

- (IBAction)tiaodaiModeBtnAction:(id)sender {
    
    
    [self setMode:self.tiaodaiModeBtn Button2:self.huanxingModeBtn Button3:self.zidingyiModeBtn];
    
    if ([_delegate respondsToSelector:@selector(tiaodaiBtnActionInFMButtonVC:inFMButtonVC:)]) {
        [_delegate tiaodaiBtnActionInFMButtonVC:self.tiaodaiModeBtn inFMButtonVC:self];
    }
}

- (IBAction)huanxingModeBtnAction:(id)sender {
    
    [self setMode:self.huanxingModeBtn Button2:self.tiaodaiModeBtn Button3:self.zidingyiModeBtn];
    if ([_delegate respondsToSelector:@selector(huanxingBtnActionInFMButtonVC:inFMButtonVC:)]) {
        [_delegate huanxingBtnActionInFMButtonVC:self.huanxingModeBtn inFMButtonVC:self];
    }
}

- (IBAction)zidingyiModeBtnAction:(id)sender {
    
    [self setMode:self.zidingyiModeBtn Button2:self.huanxingModeBtn Button3:self.tiaodaiModeBtn];
    if ([_delegate respondsToSelector:@selector(zidingyiBtnActionInFMButtonVC:inFMButtonVC:)]) {
        [_delegate zidingyiBtnActionInFMButtonVC:self.zidingyiModeBtn inFMButtonVC:self];
    }
}
@end
