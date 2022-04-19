//
//  ModeChooseViewController.m
//  MediaManagerDemo
//
//  Created by Apple on 2018/8/1.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import "ModeChooseViewController.h"

@interface ModeChooseViewController ()



@property (weak, nonatomic) IBOutlet UIButton *tiaodaiBtn;
@property (weak, nonatomic) IBOutlet UIButton *huanraoBtn;
@property (weak, nonatomic) IBOutlet UIButton *qinxieBtn;
@property (weak, nonatomic) IBOutlet UIButton *quanjinBtn;

@end

@implementation ModeChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
    //NSLog(@"%@",_zzcUser);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Init Methods




- (void) initUI{

    _tiaodaiBtn.center = CGPointMake(self.view.bounds.size.width/8, self.view.bounds.size.height/2);
    _huanraoBtn.center = CGPointMake(3 * self.view.bounds.size.width/8, self.view.bounds.size.height/2);
    _qinxieBtn.center = CGPointMake(5 * self.view.bounds.size.width/8, self.view.bounds.size.height/2);
    _quanjinBtn.center = CGPointMake(7 * self.view.bounds.size.width/8, self.view.bounds.size.height/2);
    
    _qinxieBtn.layer.borderWidth = 1;
    _qinxieBtn.layer.cornerRadius = self.view.bounds.size.width/5;
    _quanjinBtn.layer.borderWidth = 1;
    _quanjinBtn.layer.cornerRadius = self.view.bounds.size.width/5;
    _tiaodaiBtn.layer.borderWidth = 1;
    _tiaodaiBtn.layer.cornerRadius = self.view.bounds.size.width/5;
    _huanraoBtn.layer.borderWidth = 1;
    _huanraoBtn.layer.cornerRadius = self.view.bounds.size.width/5;

    NSLog(@"ZZCUSER:%@",_zzcUser);


}


#pragma mark - IBAction Methods
- (IBAction)tiaodaiBtnAction:(id)sender {
    
    UIStoryboard * vb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DJIRootViewController * rootVC = [vb instantiateViewControllerWithIdentifier:@"rootView"];
    rootVC.mode = ZZCRouteMode_tiaodai;
    
    rootVC.zzcUser = [[FlyUser alloc] init];
    rootVC.zzcUser.Id = _zzcUser.Id;
    rootVC.zzcUser.phoneNum = _zzcUser.phoneNum;
    rootVC.zzcUser.company = _zzcUser.company;
    rootVC.zzcUser.password = _zzcUser.password;
    rootVC.zzcUser.userName = _zzcUser.userName;
    
    [self.navigationController pushViewController:rootVC animated:YES];
    
    
}

- (IBAction)huanraoBtnAction:(id)sender {
    UIStoryboard * vb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DJIRootViewController * rootVC = [vb instantiateViewControllerWithIdentifier:@"rootView"];
    rootVC.mode = ZZCRouteMode_huanxing;
    
    rootVC.zzcUser = [[FlyUser alloc] init];
    rootVC.zzcUser.Id = _zzcUser.Id;
    rootVC.zzcUser.phoneNum = _zzcUser.phoneNum;
    rootVC.zzcUser.company = _zzcUser.company;
    rootVC.zzcUser.password = _zzcUser.password;
    rootVC.zzcUser.userName = _zzcUser.userName;
    
    [self.navigationController pushViewController:rootVC animated:YES];
}

- (IBAction)qinxieBtnAction:(id)sender {
    UIStoryboard * vb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DJIRootViewController * rootVC = [vb instantiateViewControllerWithIdentifier:@"rootView"];
    rootVC.mode = ZZCRouteMode_qinxie;
    
    rootVC.zzcUser = [[FlyUser alloc] init];
    rootVC.zzcUser.Id = _zzcUser.Id;
    rootVC.zzcUser.phoneNum = _zzcUser.phoneNum;
    rootVC.zzcUser.company = _zzcUser.company;
    rootVC.zzcUser.password = _zzcUser.password;
    rootVC.zzcUser.userName = _zzcUser.userName;
    
    [self.navigationController pushViewController:rootVC animated:YES];
}

- (IBAction)quanjinBtnAction:(id)sender {
    UIStoryboard * vb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DJIRootViewController * rootVC = [vb instantiateViewControllerWithIdentifier:@"rootView"];
    rootVC.mode = ZZCRouteMode_quanjin;
    
    rootVC.zzcUser = [[FlyUser alloc] init];
    rootVC.zzcUser.Id = _zzcUser.Id;
    rootVC.zzcUser.phoneNum = _zzcUser.phoneNum;
    rootVC.zzcUser.company = _zzcUser.company;
    rootVC.zzcUser.password = _zzcUser.password;
    rootVC.zzcUser.userName = _zzcUser.userName;
    
    [self.navigationController pushViewController:rootVC animated:YES];
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
