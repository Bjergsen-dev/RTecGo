//
//  UserRegisViewController.m
//  RTectGo
//
//  Created by Apple on 2019/1/3.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import "UserRegisViewController.h"

@interface UserRegisViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName_tfd;
@property (weak, nonatomic) IBOutlet UITextField *password_tfd;
@property (weak, nonatomic) IBOutlet UITextField *mail_tfd;
@property (weak, nonatomic) IBOutlet UITextField *phonenum_tfd;
@property (weak, nonatomic) IBOutlet UITextField *company_tfd;
@property (weak, nonatomic) IBOutlet UIButton *register_btn;
@property (weak, nonatomic) IBOutlet UIButton *back_btn;

@end

@implementation UserRegisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    
   
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/************************
Init Methods
 ***********************/
- (void) initData{
    
    NSMutableDictionary *usernamepasswordKVPairs1 = (NSMutableDictionary *)[ZZCKeychain load:KEY_RTECHGO];
    NSString * company = [usernamepasswordKVPairs1 objectForKey:KEY_COMPANY];
    
    [_company_tfd setText:company];
}


/************************
Custom Methods
 ***********************/
//这里写一个用来规范输入的函数

- (int) guifan{
    
    
    NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
    NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
    NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
    
    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
    
    BOOL isMatch1 = [pred1 evaluateWithObject:_phonenum_tfd.text];
    
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
    
    BOOL isMatch2 = [pred2 evaluateWithObject:_phonenum_tfd.text];
    
    NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
    
    BOOL isMatch3 = [pred3 evaluateWithObject:_phonenum_tfd.text];
    
    
    if ([_password_tfd.text  isEqual: @""]) {
        ShowResult(@"密码不能为空哦！");
        return 0;
    }
    
    if ([_userName_tfd.text  isEqual: @""]) {
        ShowResult(@"用户名称不能为空哦！");
        return 0;
    }
    
    
    if ([_company_tfd.text  isEqual: @""]) {
        ShowResult(@"单位名称不能为空哦！");
        return 0;
    }
    
    if (_phonenum_tfd.text.length != 11) {
        ShowResult(@"电话号码长度不对哦！");
        return 0;
    }
    
    if (!isMatch1 && !isMatch2 && !isMatch3) {
        ShowResult(@"电话号码格式不对啊！");
        return 0;
    }
    
    return 1;
    
}


/************************
 IBAction Methods
 ***********************/
- (IBAction)registerBtn_cliked:(id)sender {
    
    
    //先判断一下是不是规范填写了
    switch ([self guifan]) {
        case 0:
            return;
            break;
        case 1:
            NSLog(@"填写正常没问题！");
            break;
            
        default:
            break;
    }
    
    //然后进行网络请求 登录验证
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置不做处理
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //2.封装参数
    
    NSString * uri = @"http://120.55.62.229:38008/maven_test/FlyUser/register";
    
    NSString * flyUser = [_company_tfd text];
    NSString * phoneNumber = [_phonenum_tfd text];
    NSString * password = [_password_tfd text];
    NSString * userName = [_userName_tfd text];
    NSString * email = [_mail_tfd text];
    NSDictionary *register_dict = @{
                                 @"flyUser":flyUser,
                                 @"phoneNumber":phoneNumber,
                                 @"password":password,
                                 @"userName":userName,
                                 @"email":email,
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
        //请求成功应该做什么处理呢？
        if ([encodeStr isEqualToString:@"0"]) {
            ShowResult(@"注册失败！请检查重试");
            return;
        }else if([encodeStr isEqualToString:@"2"]){
            
            ShowResult(@"注册失败！该手机已被注册");
            return;
        }else{
            
            NSLog(@"注册成功了");
            //请求成功应该做什么处理呢？
            NSString* message = [NSString stringWithFormat:@"注册成功了，返回登录界面！ "];
            UIAlertAction *backAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                    [self.navigationController popViewControllerAnimated:YES];
                
            }];
            
            UIAlertController* alertViewController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
            [alertViewController addAction:backAction];
            
            UINavigationController* navController = (UINavigationController*)[[UIApplication sharedApplication] keyWindow].rootViewController;
            [navController presentViewController:alertViewController animated:YES completion:nil];

            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        ShowResult(@"网络请求失败！");
        NSLog(@"failure--%@",error);
    }];
    
}

- (IBAction)backBtn_cliked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
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
