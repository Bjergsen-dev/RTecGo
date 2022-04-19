//
//  ViewController.m
//  MediaManagerDemo
//
//  Created by DJI on 1/8/2017.
//  Copyright © 2017 DJI. All rights reserved.
//

#import "MainViewController.h"
#import "DemoUtility.h"
#import "ZZCKeychain.h"
#import "CompanyRegisViewController.h"

#define ENTER_DEBUG_MODE 0

@interface MainViewController ()<DJISDKManagerDelegate>
@property(nonatomic, weak) DJIBaseProduct* product;
@property(nonatomic,strong) ZZCKeychain* keychain;
@property (nonatomic, assign) BOOL firstLogin;//设置这个参数来专门解决是否需要激活的判断
@property (nonatomic, strong) NSString* appTime;//设置这个参数来专门解决产品的时间限制
@property (weak, nonatomic) IBOutlet UILabel *connectStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *modelNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UITextField *deviceTxtfld;
@property (weak, nonatomic) IBOutlet UITextField *pswordTxtfld;
@property (weak, nonatomic) IBOutlet UILabel *deviceLab;
@property (weak, nonatomic) IBOutlet UILabel *pswordLab;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    

    
    [self initdata];
    //Please enter your App Key in the info.plist file.
    [DJISDKManager registerAppWithDelegate:self];
    //[self initUI];
    if(self.product){
        [self updateStatusBasedOn:self.product];
    }
}


/******************************
 init methods
 *****************************/



//程序进来先判断到底是不是已经激活了 而且试用期还没过
- (void) initCheck{
    NSMutableDictionary *usernamepasswordKVPairs1 = (NSMutableDictionary *)[ZZCKeychain load:KEY_RTECHGO];
    NSString * XULIEHAO = [usernamepasswordKVPairs1 objectForKey:KEY_XULIEHAO];
    NSString * userName = [usernamepasswordKVPairs1 objectForKey:KEY_COMPANY];
    //2019 3 8 新加入
    NSString * lastDate = [usernamepasswordKVPairs1 objectForKey:KEY_LASTDATE];
    NSInteger lastDate_int = [lastDate integerValue];
    NSString * zzDate = [usernamepasswordKVPairs1 objectForKey:KEY_ZZDATE];
    NSInteger zzDate_int = [zzDate integerValue];
    //2019 3 8 新加入
    NSLog(@"usernamepasswordKVPairs1:\n %@",usernamepasswordKVPairs1);
    
    if ([XULIEHAO isEqualToString:@"ZZC"]) {
        UIStoryboard * vb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CompanyRegisViewController* rootVC = [vb instantiateViewControllerWithIdentifier:@"registerVC"];
        [self.navigationController pushViewController:rootVC animated:YES];
    }else{
        
        
        if ([[zzcAFN internetStauts] isEqualToString:@"NONE"]) {
            //没网
            //获取当前时间戳
            NSInteger timeNow_int =  [ZZCJIami getNowTimestamp];
            if (timeNow_int < zzDate_int && timeNow_int > lastDate_int) {
                UIStoryboard * vb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UserLoginViewController* rootVC = [vb instantiateViewControllerWithIdentifier:@"userLoginView"];
                [self.navigationController pushViewController:rootVC animated:YES];
                return ;
            }else{
                ShowResult(@"用户已过期或者系统时间异常！");
                return;
            }
        }
        

        
        
        
        
        
        //确实有值
        
        //1.创建会话管理者
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        //设置不做处理
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        
        //配置参数
        NSString * login_uri = @"http://120.55.62.229:38008/maven_test/Fly/loginIn";
        NSDictionary *login_dict = @{
                                     @"userName":userName,
                                     @"passwordNumber":XULIEHAO,
                                     @"type":@"JSON"
                                     };
        
        [manager GET:login_uri parameters:login_dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"success--%@--%@",[responseObject class],responseObject);
            
            //由于返回的是文本 编码需要转换格式 才能log
            NSStringEncoding login_enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            
            NSString * login_encodeStr = [[NSString alloc] initWithBytes:[responseObject bytes] length:[responseObject length] encoding:login_enc];
            
            int login_encodeInt = [login_encodeStr intValue];
            
            NSLog(@"login_encodeStr == %@",login_encodeStr);
            
            switch (login_encodeInt) {
                case 0:
                {
                    NSLog(@"登录失败！");
                    
                    UIStoryboard * vb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    CompanyRegisViewController* rootVC = [vb instantiateViewControllerWithIdentifier:@"registerVC"];
                    rootVC.registerInt = -2;
                    [self.navigationController pushViewController:rootVC animated:YES];
                    break;
                }
                case 1:
                {
                    //登录成功了 该怎么做呢
                    //跳转到下一个页面
                    UIStoryboard * vb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    UserLoginViewController* rootVC = [vb instantiateViewControllerWithIdentifier:@"userLoginView"];
                    [self.navigationController pushViewController:rootVC animated:YES];
                    
                    break;
                }
                case -1:
                {
                    NSLog(@"试用期已过！请重新注册！");
                    UIStoryboard * vb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    CompanyRegisViewController* rootVC = [vb instantiateViewControllerWithIdentifier:@"registerVC"];
                    rootVC.registerInt = -1;
                    [self.navigationController pushViewController:rootVC animated:YES];
                    break;
                }
                default:
                    break;
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            ShowResult(@"网络请求失败！");
            NSLog(@"failure--%@",error);
        }];
    }
}


- (void)initdata{
    //软件默认是没有激活的
    _firstLogin = YES;
    
    NSMutableDictionary *usernamepasswordKVPairs1 = (NSMutableDictionary *)[ZZCKeychain load:KEY_RTECHGO];
    if (usernamepasswordKVPairs1 != nil) {
        
        NSString * uuid = [usernamepasswordKVPairs1 objectForKey:KEY_UUID];
        NSLog(@"--usernamepasswordKVPairs1-- == %@",usernamepasswordKVPairs1);
        //有uuid的话就把这这个拿出来
        //_deviceID = uuid;
        return;
    }else{
        //第一次用这个哦还没有设备码
        //这些信息需要存储在设备里面需要在keychain里面记录一下
        
        NSString * md5 = [ZZCJIami md5_32bit:[ZZCJIami sensitize]];
        NSString * UUID = [md5 substringWithRange:NSMakeRange(8, 10)];
        NSString * COMPANY = @"ZZC";
        NSString * YESORNO = @"NO";
        NSString * LASTDATE = @"ZZC";
        NSString * ZZDATE = @"ZZC";
        NSString * PHONENUM = @"ZZC";
        NSString * XULIEHAO = @"ZZC";
        
        [self saveforKeychain:UUID COMPANY:COMPANY YESORNO:YESORNO LASTDATE:LASTDATE ZZDATE:ZZDATE PHONENUM:PHONENUM XULIEHAO:XULIEHAO];
        
        //同样也要拿出来用一下
        //_deviceID = UUID;
        NSLog(@"已存储设备码");
    }
    
}


- (void)initUI
{
    self.title = @"RTectGo";
    self.modelNameLabel.hidden = YES;
    //Disable the connect button by default
    [self.connectButton setEnabled:YES];
    NSString *  KEY_POTENCE_APPTIME = @"com.kangtu.RTectGo.encrypt";
    NSMutableDictionary *usernamepasswordKVPairs = (NSMutableDictionary *)[ZZCKeychain load:KEY_POTENCE_APPTIME];
    if (usernamepasswordKVPairs != nil) {
        [_deviceTxtfld setHidden:YES];
        [_pswordTxtfld setHidden:YES];
        [_pswordLab setHidden:YES];
        [_deviceLab setHidden:YES];
        //已经激活了
        _firstLogin = NO;
    }else{
        //需要激活了
        _firstLogin = YES;
        NSString * randomStr = [self sensitize];
        [_deviceTxtfld setText:randomStr];
    }
    
}


/******************************
Custom methods
 *****************************/

//这里写一个keychain的保存方法
- (void) saveforKeychain:(NSString *) UUID COMPANY:(NSString *) COMPANY YESORNO:(NSString *) YESORNO LASTDATE:(NSString *) LASTDATE ZZDATE:(NSString *) ZZDATE PHONENUM:(NSString *)PHONENUM XULIEHAO:(NSString *) XULIEHAO{
    
    NSMutableDictionary *usernamepasswordKVPairs = [NSMutableDictionary dictionary];
    
    [usernamepasswordKVPairs setObject:UUID forKey:KEY_UUID];
    [usernamepasswordKVPairs setObject:COMPANY forKey:KEY_COMPANY];
    [usernamepasswordKVPairs setObject:YESORNO forKey:KEY_YESORNO];
    [usernamepasswordKVPairs setObject:LASTDATE forKey:KEY_LASTDATE];
    [usernamepasswordKVPairs setObject:ZZDATE forKey:KEY_ZZDATE];
    [usernamepasswordKVPairs setObject:PHONENUM forKey:KEY_PHONENUM];
    [usernamepasswordKVPairs setObject:XULIEHAO forKey:KEY_XULIEHAO];
    [ZZCKeychain save:KEY_RTECHGO data:usernamepasswordKVPairs];
    
    NSLog(@"usernamepasswordKVPairs == %@",usernamepasswordKVPairs);
}



//TODO:创造一个加密算法
//1:需要产生随机数字的9位串码作为引子
//2:需要进行结果匹配
- (NSString *)sensitize{
    //产生1 -10 的一个随机数 并进行拼接
    NSString * resultStr = @"";
    
    for (int i = 0; i < 9; i++) {
        int x = arc4random() % 10;
        NSString *ValueString = [NSString stringWithFormat:@"%d", x];
        resultStr = [resultStr stringByAppendingString:ValueString];
    }
    
    //打印看看是谁否正确
    NSLog(@"字符串为：%@", resultStr);
    return resultStr;
}

-(NSString *)activation:(NSString *)Str time:(int) time{
    
    //存一下各个散数
    int array[6];
    
    for (int i = 0; i < 6; i++) {
        int x = [[Str substringWithRange:NSMakeRange(i, 1)] intValue];
        array[i] = x;
    }
    
    //ZZC加密算法核心部分
    //首末相加乘17 18 19 相加
    NSString * senven = [NSString stringWithFormat:@"%d",(array[0] + array[5]) * 17];
    NSString * eight = [NSString stringWithFormat:@"%d",(array[1] + array[4]) * 18];
    NSString * nine = [NSString stringWithFormat:@"%d",(array[2] + array[3]) * 19];
    NSString * timeStr = [NSString stringWithFormat:@"%d",time];
    //拼接
    
    NSString * result = [NSString stringWithFormat:@"%@%@%@", senven, eight,nine];//不带时间
    //NSString * result = [NSString stringWithFormat:@"%@%@%@%@", senven, eight,nine,timeStr];
    
    //打印出来看看
    NSLog(@"加密后结果是：%@",result);
    return result;
    
    
}

//TODO:判断是否需要激活 激活是否正确 給出状态表示
//result:
//0-成功可进入
//1-激活码为空
//2-激活码错误
//3-激活发生错误
- (int)statusOfApp:(BOOL)fstlogin deviceStr:(NSString *)deviceStr pswordStr:(NSString *)pswordStr {
    
    //软件已经激活了
    if (fstlogin == NO || [pswordStr  isEqual: @"ZZCDSG"]) {
        return 0;
    }
    
    //激活码为空
    if ([pswordStr isEqualToString:@""]) {
        return 1;
    }
    
    //激活码错误
    if (![[self activation:deviceStr time:0] isEqualToString:pswordStr]) {
        return 2;
    }
    
    return 0;
}


/******************************
 IBAction methods
 *****************************/
- (IBAction)connectionBtn_cliked:(id)sender {
    
    [SZKCustomAlter showAlter:@"正在验证..." alertTime:0.5];
    
    
    //[self initCheck];
    
    //2022年 4月18号 悲痛的是这个项目烂尾了
    //取消登录验证
    UIStoryboard * vb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ModeChooseViewController* rootVC = [vb instantiateViewControllerWithIdentifier:@"modeView"];
    
    rootVC.zzcUser = [[FlyUser alloc] init];
    rootVC.zzcUser.Id = 1;
    rootVC.zzcUser.phoneNum = @"123456";
    rootVC.zzcUser.company = @"Big_Dream";
    rootVC.zzcUser.password = @"123456";
    rootVC.zzcUser.userName = @"钟智超";
    
    [self.navigationController pushViewController:rootVC animated:YES];
    
    
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (IBAction)onConnectButtonClicked:(id)sender {
//
//    /*TODO：clarify that user can use tha App or not*/
//    NSString * deviceStr = _deviceTxtfld.text;
//    NSString * pswordStr = _pswordTxtfld.text;
//
//    switch ([self statusOfApp:_firstLogin deviceStr:deviceStr pswordStr:pswordStr]) {
//        case 0:
//        {
//            //激活成功了之后需要在keychain里面记录一下
//            NSString *  KEY_POTENCE_APPTIME = @"com.kangtu.RTectGo.encrypt";
//            NSString *  KEY_POTENCE = @"com.kangtu.RTectGo.potence";
//            NSString *  KEY_APPTIME = @"com.kangtu.RTectGo.apptime";//这里先设置0为时间长度
//
//            NSMutableDictionary *usernamepasswordKVPairs = [NSMutableDictionary dictionary];
//            [usernamepasswordKVPairs setObject:@"YES" forKey:KEY_POTENCE];
//            [usernamepasswordKVPairs setObject:@"0" forKey:KEY_APPTIME];
//            [ZZCKeychain save:KEY_POTENCE_APPTIME data:usernamepasswordKVPairs];
//
//            UIStoryboard * vb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            ModeChooseViewController* rootVC = [vb instantiateViewControllerWithIdentifier:@"modeView"];
//            [self.navigationController pushViewController:rootVC animated:YES];
//        }
//            break;
//        case 1:
//            ShowResult(@"激活码不能为空！");
//            break;
//        case 2:
//            ShowResult(@"激活码无效!");
//            break;
//
//        default:
//            break;
//    }
//
//
//}

-(void) updateStatusBasedOn:(DJIBaseProduct* )newConnectedProduct {
    if (newConnectedProduct){
        self.connectStatusLabel.text = NSLocalizedString(@"状态: 已连接", @"");
        self.modelNameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"模型: \%@", @""),newConnectedProduct.model];
        self.modelNameLabel.hidden = NO;
        
    }else {
        self.connectStatusLabel.text = NSLocalizedString(@"状态：未连接", @"");
        self.modelNameLabel.text = NSLocalizedString(@"模型: 未知", @"");
    }
}

#pragma mark - Keychain Methods




#pragma mark - DJISDKManager Delegate Methods
- (void)appRegisteredWithError:(NSError *)error
{
    if (!error) {
        
        ShowResult(@"产品注册成功");
#if ENTER_DEBUG_MODE
        [DJISDKManager enableBridgeModeWithBridgeAppIP:@"10.01.15.112"];
#else
        [DJISDKManager startConnectionToProduct];
#endif
        
    }else
    {
        ShowResult([NSString stringWithFormat:@"注册错误:%@", error]);
        [self.connectButton setEnabled:NO];
    }
    
}

- (void)productConnected:(DJIBaseProduct *)product
{
    if (product) {
        self.product = product;
        [self.connectButton setEnabled:YES];
    }
    
    [self updateStatusBasedOn:product];
    
    //If this demo is used in China, it's required to login to your DJI account to activate the application. Also you need to use DJI Go app to bind the aircraft to your DJI account. For more details, please check this demo's tutorial.
    [[DJISDKManager userAccountManager] logIntoDJIUserAccountWithAuthorizationRequired:NO withCompletion:^(DJIUserAccountState state, NSError * _Nullable error) {
        if (error) {
            ShowResult(@"登录失败: %@", error.description);
        }
    }];
}

- (void)productDisconnected
{
    NSString* message = [NSString stringWithFormat:@"连接断开了，返回初始界面！ "];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *backAction = [UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (![self.navigationController.topViewController isKindOfClass:[MainViewController class]]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
    
    UIAlertController* alertViewController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertViewController addAction:cancelAction];
    [alertViewController addAction:backAction];
    
    UINavigationController* navController = (UINavigationController*)[[UIApplication sharedApplication] keyWindow].rootViewController;
    [navController presentViewController:alertViewController animated:YES completion:nil];
    
    [self.connectButton setEnabled:NO];
    self.product = nil;
    
    [self updateStatusBasedOn:self.product];
    
}

@end
