//
//  CompanyRegisViewController.m
//  RTectGo
//
//  Created by Apple on 2019/1/4.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import "CompanyRegisViewController.h"



@interface CompanyRegisViewController ()
@property (nonatomic, strong) NSString * deviceID;//存储设备的UUID
@property (nonatomic, assign) int repeatTime;//计时器重复次数
@property (nonatomic, assign) BOOL regisOrnot;//用来判断是否可以注册按钮点击


@property (weak, nonatomic) IBOutlet UITextField *company_tfd;
@property (weak, nonatomic) IBOutlet UITextField *phone_tfd;
@property (weak, nonatomic) IBOutlet UITextField *checknum_tfd;
@property (weak, nonatomic) IBOutlet UIButton *check_btn;
@property (weak, nonatomic) IBOutlet UIButton *register_btn;

@end

@implementation CompanyRegisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化一下设备码，苹果每次设备码uuid都不是唯一的 app卸载后会发生变化 因此这里用钥匙串来存储
    [self initData];
    
    [self initUI];
    
    //这里需要check一下是不是已经激活过的
 //   [self initCheck];
    
//    NSString * jiemiMD5 = [ZZCJIami ZZCMd5JM:@"8atnZENwjvA11UoVdjcQmEs3ofW5jJ7+"];
//    NSString * zhenshiMD5 = [ZZCJIami md5_32bit:@"80259796"];
//    zhenshiMD5 = [zhenshiMD5 lowercaseString];
//
//    NSLog(@"--jiemiMD5--\n%@\n--zhenshiMD5--\n%@",jiemiMD5,zhenshiMD5);
    
//    [ZZCJIami getNowTimestamp];
    
//    [ZZCJIami timestampSwitchTime:(1546918749 + 1728000) andFormatter:@"YYYY-MM-dd HH:mm:ss"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/******************************
 init methods
 *****************************/

- (void) initUI{
    
    if (_registerInt == 0) {
        return;
    }
    
    if (_registerInt == -2) {
        ShowResult(@"设备验证失败！");
    }
    
    if (_registerInt == -1) {
        ShowResult(@"试用期已经过了!");
    }
    
}

//程序进来先判断到底是不是已经激活了 而且试用期还没过
- (void) initCheck{
    NSMutableDictionary *usernamepasswordKVPairs1 = (NSMutableDictionary *)[ZZCKeychain load:KEY_RTECHGO];
    NSString * XULIEHAO = [usernamepasswordKVPairs1 objectForKey:KEY_XULIEHAO];
    NSString * userName = [usernamepasswordKVPairs1 objectForKey:KEY_COMPANY];
    
    NSLog(@"usernamepasswordKVPairs1:\n %@",usernamepasswordKVPairs1);
    
    if ([XULIEHAO isEqualToString:@"ZZC"]) {
        return;
    }else{
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
                    ShowResult(@"登录失败！");
                    break;
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
                    ShowResult(@"试用期已过！请重新注册！");
                    break;
                    
                default:
                    break;
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            ShowResult(@"网络请求失败！");
            NSLog(@"failure--%@",error);
        }];
        
    }
    
    
}

- (void) initData{
    //设计循环次数为10s
    _repeatTime = 60;
    //设置一开始是不能点击注册按钮
    _regisOrnot = NO;
    
    NSMutableDictionary *usernamepasswordKVPairs1 = (NSMutableDictionary *)[ZZCKeychain load:KEY_RTECHGO];
    if (usernamepasswordKVPairs1 != nil) {
        
        NSString * uuid = [usernamepasswordKVPairs1 objectForKey:KEY_UUID];
        NSLog(@"--usernamepasswordKVPairs1-- == %@",usernamepasswordKVPairs1);
        //有uuid的话就把这这个拿出来
        _deviceID = uuid;
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
        _deviceID = UUID;
        NSLog(@"已存储设备码");
    }
    
}


/******************************
custom methods
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

- (void)taction:(NSTimer *)sender{
    if (_repeatTime > 0) {
        [_check_btn setEnabled:NO];
        NSString * timeStr = [NSString stringWithFormat:@"%ds",_repeatTime];
        [_check_btn setTitle:timeStr forState:UIControlStateDisabled];
        _repeatTime = _repeatTime -1;
    }else{
        [_check_btn setTitle:@"发送验证码" forState:UIControlStateNormal];
        [_check_btn setEnabled:YES];
        _repeatTime = 60;
        [sender invalidate];
    }
    
}

//这里写一个用来规范输入的函数

- (int) guifan{
    

    NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
    NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
    NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
    
    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
    
    BOOL isMatch1 = [pred1 evaluateWithObject:_phone_tfd.text];
    
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
    
    BOOL isMatch2 = [pred2 evaluateWithObject:_phone_tfd.text];
    
    NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
    
    BOOL isMatch3 = [pred3 evaluateWithObject:_phone_tfd.text];
   
    
    if ([_company_tfd.text  isEqual: @""]) {
        ShowResult(@"单位名称不能为空哦！");
        return 0;
    }
    
    if (_phone_tfd.text.length != 11) {
        ShowResult(@"电话号码长度不对哦！");
        return 0;
    }
    
    if (!isMatch1 && !isMatch2 && !isMatch3) {
        ShowResult(@"电话号码格式不对啊！");
        return 0;
    }
    
    return 1;
    
}


/******************************
IBAction methods
 *****************************/
- (IBAction)check_btn_clicked:(id)sender {
    
    //先判断格式对不对再说
    if ([self guifan] == 0) {
        return;
    }
    
    
    
    
    //这里需要发送验证码啊
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置不做处理
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //2.封装参数
    
    NSString * uri = @"http://120.55.62.229:38008/maven_test/Fly/register";
    
    NSString * userName = [_company_tfd text];
    NSString * phoneNumber = [_phone_tfd text];
    NSString * machineNumber = _deviceID;
    NSDictionary *register_dict = @{
                           @"userName":userName,
                           @"phoneNumber":phoneNumber,
                           @"machineNumber":machineNumber,
                           @"limitDay":@"20",
                           @"userType":@"0",
                           @"type":@"JSON"
                           };
    
    
    //http://120.55.62.229:38008/maven_test/Fly/register?userName="IOSTest1"&phoneNumber="13100721637"&machineNumber="357231358"&limitDay="10"&userType="0"
    //3.发送Get请求
    /*
     第一个参数:请求路径(NSString)+ 不需要加参数
     第二个参数:发送给服务器的参数数据
     第三个参数:progress 进度回调
     第四个参数:success  成功之后的回调(此处的成功或者是失败指的是整个请求)
     task:请求任务
     responseObject:注意!!!响应体信息--->(json--->oc))
     task.response: 响应头信息
     第五个参数:failure 失败之后的回调
     */
    [manager GET:uri parameters:register_dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success--%@--%@",[responseObject class],responseObject);

        //由于返回的是文本 编码需要转换格式 才能log
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        
        NSString * encodeStr = [[NSString alloc] initWithBytes:[responseObject bytes] length:[responseObject length] encoding:enc];
        
        NSLog(@"encodeStr == %@",encodeStr);
        //请求成功应该做什么处理呢？是不是应该把这些信息存在keychain里面了呢？
        
        if ([encodeStr isEqualToString:@"1"]) {
            NSString * timestampNow = [NSString stringWithFormat:@"%ld",(long)[ZZCJIami getNowTimestamp]];
            NSString * zztimestampNow = [NSString stringWithFormat:@"%ld",(long)([ZZCJIami getNowTimestamp] + 1728000)];
            //这里默认都是试用期20days
            
            //更新keychain存储
            [self saveforKeychain:machineNumber COMPANY:userName YESORNO:@"YES" LASTDATE:timestampNow ZZDATE:zztimestampNow PHONENUM:phoneNumber XULIEHAO:@"ZZC"];
            
            
            //请求成功了就开始计数
            NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(taction:) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            
            //请求成功了说明可以进行下一步操作了
            _regisOrnot = YES;
            
        }else{
            
            ShowResult(@"设备注册失败了！");
        }
        
       
        

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        ShowResult(@"网络请求失败！");
        NSLog(@"failure--%@",error);
    }];
}




- (IBAction)registerBtn_Cliked:(id)sender {
    
    if ([_checknum_tfd.text isEqualToString:@""]) {
        ShowResult(@"先完善一下填写信息哦！");
        return;
    }
    
    if (_regisOrnot == NO) {
        ShowResult(@"先完善一下填写信息哦！");
        return;
    }
    
    //这里确认已经注册设备了 需要确认设备了
    //这里先通过验证码 手机号请求加密吗
    //接口为：http://120.55.62.229:38008/maven_test/Fly/getPasswordNumber
    
    
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置不做处理
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //2.封装参数
    
    NSString * uri = @"http://120.55.62.229:38008/maven_test/Fly/getPasswordNumber";
    
    NSString * phoneNumber = [_phone_tfd text];
    NSString * uuid = [_checknum_tfd text];
    NSDictionary *register_dict = @{
                                    @"uuid":uuid,
                                    @"phoneNumber":phoneNumber,
                                    @"type":@"JSON"
                                    };
    
    //3.发送Get请求
    /*
     第一个参数:请求路径(NSString)+ 不需要加参数
     第二个参数:发送给服务器的参数数据
     第三个参数:progress 进度回调
     第四个参数:success  成功之后的回调(此处的成功或者是失败指的是整个请求)
     task:请求任务
     responseObject:注意!!!响应体信息--->(json--->oc))
     task.response: 响应头信息
     第五个参数:failure 失败之后的回调
     */
    [manager GET:uri parameters:register_dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success--%@--%@",[responseObject class],responseObject);
        
        
        //由于返回的是文本 编码需要转换格式 才能log
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        
        NSString * encodeStr = [[NSString alloc] initWithBytes:[responseObject bytes] length:[responseObject length] encoding:enc];
        
        NSLog(@"encodeStr == %@",encodeStr);
        
        if ([encodeStr isEqualToString:@"0"]) {
            ShowResult(@"获取失败！");
            return;
        }else if([encodeStr isEqualToString:@"3"]){
            ShowResult(@"验证码已失效！");
            return;
            
        }else if([encodeStr isEqualToString:@"2"]){
            
             ShowResult(@"验证码错误！");
            return;
        }else{
                //获取成功了！
                //这里把序列号存起来  下次进这个界面的时候用这个可以判断是否需要再次激活 不需要就直接跳转到下一个界面了
                
                NSString * timestampNow = [NSString stringWithFormat:@"%ld",(long)[ZZCJIami getNowTimestamp]];
                NSString * zztimestampNow = [NSString stringWithFormat:@"%ld",(long)([ZZCJIami getNowTimestamp] + 1728000)];
                //这里默认都是试用期20days
                
                //设备码
                NSString * machineNumber = _deviceID;
                //单位名称
                NSString * userName = [_company_tfd text];
            
            
            
            //由于这个出来之后还带有双引号 因此必须先去掉双引号
            encodeStr = [encodeStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
                //更新keychain存储
                [self saveforKeychain:machineNumber COMPANY:userName YESORNO:@"YES" LASTDATE:timestampNow ZZDATE:zztimestampNow PHONENUM:phoneNumber XULIEHAO:encodeStr];
                
                //这里存起来之后一切正常的话 需要用序列号和手机号进行登录 在此之前还需要用序列号判断是不是确实是自己的机器在激活 因此需要解码序列号
            
                NSString * jiemiMD5 = [ZZCJIami ZZCMd5JM:encodeStr];
                NSString * jiemiDate = [ZZCJIami ZZCDateJM:encodeStr];
                NSString * zhenshiMD5 = machineNumber;
                zhenshiMD5 = [zhenshiMD5 lowercaseString];
                jiemiMD5 = [jiemiMD5 lowercaseString];
                
                //比对一下这个是不是一台机器
                if (![jiemiMD5 isEqualToString:zhenshiMD5]) {
                    ShowResult(@"设备发生变更，请别作弊！");
                    return ;
                }else{
                    //确实没做假 那就把截止日期存一下
                    //更新keychain存储
                    [self saveforKeychain:machineNumber COMPANY:userName YESORNO:@"YES" LASTDATE:timestampNow ZZDATE:jiemiDate PHONENUM:phoneNumber XULIEHAO:encodeStr];
                    
                    
                    
                    
                    
                    //确实确认没有作弊而且已经进来了那么久调用登录接口
                    //http://120.55.62.229:38008/maven_test/Fly/loginIn
                    //配置参数
                    NSString * login_uri = @"http://120.55.62.229:38008/maven_test/Fly/loginIn";
                    NSDictionary *login_dict = @{
                                                 @"userName":userName,
                                                 @"passwordNumber":encodeStr,
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
                                ShowResult(@"登录失败！");
                                break;
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
                                ShowResult(@"试用期已过！");
                                break;
                                
                            default:
                                break;
                        }
                        
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        
                        ShowResult(@"网络请求失败！");
                        NSLog(@"failure--%@",error);
                    }];
                    
                }
            }
        

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        ShowResult(@"网络请求失败！");
        NSLog(@"failure--%@",error);
    }];
    
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
