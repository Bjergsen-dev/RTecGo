//
//  DJIGSButtonViewController.m
//  GSDemo
//
//  Created by DJI on 10/7/15.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import "DJIGSButtonViewController.h"

@implementation DJIGSButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //[self setMode:DJIGSViewMode_ViewMode];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Property Method

- (void)setMode:(DJIGSViewMode)mode
{
    
    _mode = mode;
    [_editBtn setHidden:(mode == DJIGSViewMode_EditMode)];
    [_focusMapBtn setHidden:(mode == DJIGSViewMode_EditMode)];
    [_backBtn setHidden:(mode == DJIGSViewMode_ViewMode)];
    [_clearBtn setHidden:(mode == DJIGSViewMode_ViewMode)];
    [_startBtn setHidden:(mode == DJIGSViewMode_ViewMode)];
    [_stopBtn setHidden:(mode == DJIGSViewMode_ViewMode)];
    [_addBtn setHidden:(mode == DJIGSViewMode_ViewMode)];
    [_configBtn setHidden:(mode == DJIGSViewMode_ViewMode)];
}

#pragma mark - IBAction Methods

- (IBAction)backBtnAction:(id)sender {
    //[self setMode:DJIGSViewMode_ViewMode];
    if ([_delegate respondsToSelector:@selector(uploadBtnActionInGSButtonVC:)]) {
        [_delegate uploadBtnActionInGSButtonVC:self];
    }
}

- (IBAction)stopBtnAction:(id)sender {
 
    if ([_delegate respondsToSelector:@selector(stopBtnActionInGSButtonVC:)]) {
        [_delegate stopBtnActionInGSButtonVC:self];
    }
    
}

- (IBAction)clearBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(clearBtnActionInGSButtonVC:)]) {
        [_delegate clearBtnActionInGSButtonVC:self];
    }
    
}

- (IBAction)focusMapBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(focusMapBtnActionInGSButtonVC:)]) {
        [_delegate focusMapBtnActionInGSButtonVC:self];
    }
}

- (IBAction)editBtnAction:(id)sender {
    
    //[self setMode:DJIGSViewMode_EditMode];
    if ([_delegate respondsToSelector:@selector(videoBtnActionInGSButtonVC:)]) {
        [_delegate videoBtnActionInGSButtonVC:self];
    }
    
}

- (IBAction)startBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(startBtnActionInGSButtonVC:btn:)]) {
        [_delegate startBtnActionInGSButtonVC:self btn:self.viewChangeBtn];
    }
}

- (IBAction)addBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(syncBtnActionInGSButtonVC:)]) {
        [_delegate syncBtnActionInGSButtonVC:self];
    }
    
}

- (IBAction)configBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(configBtnActionInGSButtonVC:)]) {
        [_delegate configBtnActionInGSButtonVC:self];
    }
}

- (IBAction)connectBtnAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(connectBtnActionInGSButtonVC:label:inGSButtonVC:)]) {
        [_delegate connectBtnActionInGSButtonVC:self.connectBtn label:self.connectLabel inGSButtonVC:self];
        
    }
}

- (IBAction)deleteBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(deleteBtnActionInGSButtonVC:)]) {
        [_delegate deleteBtnActionInGSButtonVC:self];
    }
}

- (IBAction)fixedBtnAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(fixedBtnActionInGSButtonVC:inGSButtonVC:)]) {
        [_delegate fixedBtnActionInGSButtonVC:self.fixedLabel inGSButtonVC:self];
    }
}

- (IBAction)mapchangeBtnAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(mapchangBtnActionInGSButtonVC:inGSButtonVC:)]) {
        [_delegate mapchangBtnActionInGSButtonVC:self.mapchangeLabel inGSButtonVC:self];
    }
}

- (IBAction)viewChangeBtnAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(viewChangeBtnActionInGSButtonVC:inGSButtonVC:)]) {
        [_delegate viewChangeBtnActionInGSButtonVC:_viewChangeBtn inGSButtonVC:self];
    }
    
}

@end
