//
//  DJIGSButtonViewController.h
//  GSDemo
//
//  Created by DJI on 10/7/15.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DJIGSViewMode) {
    DJIGSViewMode_ViewMode,
    DJIGSViewMode_EditMode,
};

@class DJIGSButtonViewController;

@protocol DJIGSButtonViewControllerDelegate <NSObject>

- (void)stopBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)clearBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)focusMapBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)startBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC btn:(UIButton *)button;
- (void)addBtn:(UIButton *)button withActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)configBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)switchToMode:(DJIGSViewMode)mode inGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)connectBtnActionInGSButtonVC:(UIButton *)button label:(UILabel *)label inGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)deleteBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)fixedBtnActionInGSButtonVC:(UILabel *)label inGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)mapchangBtnActionInGSButtonVC:(UILabel *)label inGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)syncBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)videoBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)uploadBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)viewChangeBtnActionInGSButtonVC:(UIButton *)button inGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;

@end

@interface DJIGSButtonViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (weak, nonatomic) IBOutlet UIButton *focusMapBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *configBtn;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *fixedBtn;
@property (weak, nonatomic) IBOutlet UIButton *mapchangeBtn;
@property (weak, nonatomic) IBOutlet UILabel *connectLabel;
@property (weak, nonatomic) IBOutlet UILabel *fixedLabel;
@property (weak, nonatomic) IBOutlet UILabel *mapchangeLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewChangeBtn;

@property (assign, nonatomic) DJIGSViewMode mode;
@property (weak, nonatomic) id <DJIGSButtonViewControllerDelegate> delegate;

- (IBAction)backBtnAction:(id)sender;
- (IBAction)stopBtnAction:(id)sender;
- (IBAction)clearBtnAction:(id)sender;
- (IBAction)focusMapBtnAction:(id)sender;
- (IBAction)editBtnAction:(id)sender;
- (IBAction)startBtnAction:(id)sender;
- (IBAction)addBtnAction:(id)sender;
- (IBAction)configBtnAction:(id)sender;
- (IBAction)connectBtnAction:(id)sender;
- (IBAction)deleteBtnAction:(id)sender;
- (IBAction)fixedBtnAction:(id)sender;
- (IBAction)mapchangeBtnAction:(id)sender;
- (IBAction)viewChangeBtnAction:(id)sender;



@end
