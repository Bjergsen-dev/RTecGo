//
//  DJFlightModeViewController.h
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/16.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DJIFMViewMode) {
    DJIFMtiaodaiMode,
    DJIFMhuanxingViewMode,
    DJIFMzidingyiViewMode,
};

@class DJFlightModeViewController;

@protocol DJFlightModeViewControllerdelegate <NSObject>

- (void)tiaodaiBtnActionInFMButtonVC:(UIButton*) button inFMButtonVC:(DJFlightModeViewController *)FMBtnVC;
- (void)huanxingBtnActionInFMButtonVC:(UIButton*) button inFMButtonVC:(DJFlightModeViewController *)FMBtnVC;
- (void)zidingyiBtnActionInFMButtonVC:(UIButton*) button inFMButtonVC:(DJFlightModeViewController *)FMBtnVC;

@end





@interface DJFlightModeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *tiaodaiModeBtn;
@property (weak, nonatomic) IBOutlet UIButton *huanxingModeBtn;
@property (weak, nonatomic) IBOutlet UIButton *zidingyiModeBtn;

@property (weak, nonatomic) id <DJFlightModeViewControllerdelegate> delegate;

- (IBAction)tiaodaiModeBtnAction:(id)sender;
- (IBAction)huanxingModeBtnAction:(id)sender;
- (IBAction)zidingyiModeBtnAction:(id)sender;





@end
