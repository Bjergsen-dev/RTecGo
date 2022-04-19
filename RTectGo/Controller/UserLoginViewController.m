//
//  UserLoginViewController.m
//  RTectGo
//
//  Created by Apple on 2019/1/3.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import "UserLoginViewController.h"
#import "ZZCJIami.h"
#import "ZZCKeychain.h"


@interface UserLoginViewController ()
@property(nonatomic,strong) ZZCKeychain* keychain;
@property (nonatomic, assign) int deviceID;//存储设备的UUID
@property(nonatomic,strong) FlyUser* zzcUser;
@property (nonatomic, assign) sqlite3 *routeDB;//航点存储数据库
@property (weak, nonatomic) IBOutlet UITextField *company_tfd;
@property (weak, nonatomic) IBOutlet UITextField *phone_tfd;
@property (weak, nonatomic) IBOutlet UITextField *password_tfd;
@property (weak, nonatomic) IBOutlet UIButton *login_btn;
@property (weak, nonatomic) IBOutlet UIButton *defualt_btn;
@end

@implementation UserLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //    [ZZCJIami ZZCDateJM:@"1pdXs5p/eVMF5hGVmmlNhB7ROHW9GyEG"];
    //
    //    [ZZCJIami ZZCMd5JM:@"mQ5D/R3ZLpwSvMPFAXKwKf27he6Mi/YZ"];
    //
    //    [ZZCJIami sensitize];
    
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/******************************
 init methods
 *****************************/
- (void) initData{
    
    
    _zzcUser = [[FlyUser alloc] init];
    
    NSMutableDictionary *usernamepasswordKVPairs1 = (NSMutableDictionary *)[ZZCKeychain load:KEY_RTECHGO];
    NSString * company = [usernamepasswordKVPairs1 objectForKey:KEY_COMPANY];
    
    //单位钉死
    [_company_tfd setText:company];
    
    
    //创立表村数据
    [self openSqlite];
    [self createUserTable];
    
}


/******************************
 custom methods
 *****************************/

#pragma mark - sqlite3 Methods
- (void)openSqlite {
    //判断数据库是否为空,如果不为空说明已经打开
    if(_routeDB != nil) {
        NSLog(@"数据库已经打开");
        return;
    }
    
    
    //获取文件路径
    NSString *str = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *strPath = [str stringByAppendingPathComponent:@"my.sqlite"];
    NSLog(@"%@",strPath);
    //打开数据库
    //如果数据库存在就打开,如果不存在就创建一个再打开
    int result = sqlite3_open([strPath UTF8String], &_routeDB);
    //判断
    if (result == SQLITE_OK) {
        NSLog(@"数据库打开成功");
    } else {
        NSLog(@"数据库打开失败");
    }
}

- (void) createUserTable{
    
    //1.准备sqlite语句
    NSString *sqlite2 = [NSString stringWithFormat:@"create table if not exists 'user_table' ('id' integer primary key autoincrement not null,'company' text,'phoneNum' text,'password' text,'userName' text)"];
    char *error2 = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result2 = sqlite3_exec(_routeDB, [sqlite2 UTF8String], nil, nil, &error2);
    
    //3.sqlite语句是否执行成功
    
    if (result2 == SQLITE_OK) {
        NSLog(@"创建用户表成功");
    } else {
        NSLog(@"创建用户表失败");
    }
    
}

//查询
- (NSMutableArray *) selectFromUserTable{
    
    NSString * sqlite = [NSString stringWithFormat:@"select * from user_table"];
    //2.伴随指针
    sqlite3_stmt *stmt = NULL;
    //3.预执行sqlite语句
    int result = sqlite3_prepare(_routeDB, sqlite.UTF8String, -1, &stmt, NULL);//第4个参数是一次性返回所有的参数,就用-1
    
    NSMutableArray * userArray = [[NSMutableArray alloc] init];
    
    if (result == SQLITE_OK) {
        
        //4.执行n次
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            NSLog(@"用户表查询成功");
            
            FlyUser * zzcUser = [[FlyUser alloc] init];
            
            //从伴随指针获取数据,第0列
            zzcUser.Id = sqlite3_column_int(stmt, 0);
            //从伴随指针获取数据,第1列
            zzcUser.company = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)] ;
            //从伴随指针获取数据,第2列
            zzcUser.phoneNum = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)] ;
            //从伴随指针获取数据,第3列
            zzcUser.password = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)] ;
            //从伴随指针获取数据,第4列
            zzcUser.userName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)] ;
            
            [userArray addObject:zzcUser];
            
        }
        
    }else {
        NSLog(@"查询用户表失败");
    }
    
    
    return userArray;
                         
                         }

//CHECK USER EXSIT
- (BOOL) checkUserExsit:(NSMutableArray *) userArray{
    
    for (int i = 0; i < userArray.count; i++) {
        FlyUser * user = [userArray objectAtIndex:i];
        if ([user.phoneNum isEqualToString:_zzcUser.phoneNum] && [user.password isEqualToString:_zzcUser.password]) {
            return YES;
        }
    }
    
    return NO;
    
    
}

//CHECK USER EXSIT
- (FlyUser *) checkUserExsitAndRtu:(NSMutableArray *) userArray{
    
    for (int i = 0; i < userArray.count; i++) {
        FlyUser * user = [userArray objectAtIndex:i];
        if ([user.phoneNum isEqualToString:_zzcUser.phoneNum] && [user.password isEqualToString:_zzcUser.password]) {
            return user;
        }
    }
    
    return nil;
    
    
}
                         
                         //添加数据
                         - (void)addUser:(FlyUser *)flyUser {
                             
                             //1.准备sqlite语句 缺省currentIndex为0 最低高度为0 最大高度为110
                             NSString * sqlite = [NSString stringWithFormat:@"insert into user_table(id,company,phoneNum,password,userName) values ('%d','%@','%@','%@','%@')",_zzcUser.Id,_zzcUser.company,_zzcUser.phoneNum,_zzcUser.password,_zzcUser.userName];
                             
                             char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
                             int result = sqlite3_exec(_routeDB, [sqlite UTF8String], nil, nil, &error);
                             if (result == SQLITE_OK) {
                                 NSLog(@"添加数据至用户表成功");
                             } else {
                                 NSLog(@"添加数据至用户表失败");
                             }
                             
                         }
                         
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
                             
                             if ([_password_tfd.text isEqualToString:@""]) {
                                 ShowResult(@"密码不能为空啊！");
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
                         - (IBAction)loginBtn_cliked:(id)sender {
                             
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
                             
                             //这里还要判断是否有网络 没有网络本地登陆判断
                             if ([[zzcAFN internetStauts] isEqualToString:@"NONE"]) {
                                 //没网
                                 _zzcUser.phoneNum = [_phone_tfd text];
                                 NSLog(@"phoneNum:%@",_zzcUser.phoneNum);
                                 _zzcUser.password = [_password_tfd text];
                                 NSLog(@"password:%@",_zzcUser.password);
                                 
                                 if ([self checkUserExsit:[self selectFromUserTable]]) {
                                     //存在 登陆成功
                                     FlyUser * tempUser = [self checkUserExsitAndRtu:[self selectFromUserTable]];
                                     _zzcUser.Id = tempUser.Id;
                                     _zzcUser.company = tempUser.company;
                                     _zzcUser.userName = tempUser.userName;
                                     
                                     //跳转
                                     //登录成功就同步到数据库，检查是否存在
                                     NSMutableArray * userArray = [self selectFromUserTable];
                                     if ([self checkUserExsit:userArray]) {
                                         NSLog(@"用户已存在，不需要插入");
                                     }else{
                                         NSLog(@"用户不存在，需要插入");
                                         [self addUser:_zzcUser];
                                     }
                                     
                                     //请求成功应该做什么处理呢？
                                     UIStoryboard * vb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                     ModeChooseViewController* rootVC = [vb instantiateViewControllerWithIdentifier:@"modeView"];
                                     
                                     rootVC.zzcUser = [[FlyUser alloc] init];
                                     rootVC.zzcUser.Id = _zzcUser.Id;
                                     rootVC.zzcUser.phoneNum = _zzcUser.phoneNum;
                                     rootVC.zzcUser.company = _zzcUser.company;
                                     rootVC.zzcUser.password = _zzcUser.password;
                                     rootVC.zzcUser.userName = _zzcUser.userName;
                                     
                                     [self.navigationController pushViewController:rootVC animated:YES];
                                     
                                     return;
                                 }else{
                                     
                                     ShowResult(@"网络状况异常，请检查！");
                                     return;
                                     
                                 }
                             }
                             
                             [SZKCustomAlter showAlter:@"正在登录..." alertTime:0.5];
                             
                             //然后进行网络请求 登录验证
                             //1.创建会话管理者
                             AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                             //设置不做处理
                             manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                             //2.封装参数
                             
                             NSString * uri = @"http://120.55.62.229:38008/maven_test/FlyUser/loginIn";
                             
                             NSString * flyUser = [_company_tfd text];
                             NSString * phoneNumber = [_phone_tfd text];
                             NSString * password = [_password_tfd text];
                             NSDictionary *login_dict = @{
                                                          @"flyUser":flyUser,
                                                          @"phoneNumber":phoneNumber,
                                                          @"password":password,
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
                             [manager GET:uri parameters:login_dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                 NSLog(@"success--%@--%@",[responseObject class],responseObject);
                                 
                                 //由于返回的是文本 编码需要转换格式 才能log
                                 //        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                                 
                                 NSString * encodeStr = [[NSString alloc] initWithBytes:[responseObject bytes] length:[responseObject length] encoding:NSUTF8StringEncoding];
                                 
                                 NSLog(@"encodeStr == %@",encodeStr);
                                 //请求成功应该做什么处理呢？
                                 if ([encodeStr isEqualToString:@"null"] || encodeStr == nil) {
                                     ShowResult(@"登录失败！");
                                     return;
                                 }else{
                                     
                                     NSLog(@"登录成功了");
                                     
                                     //对象传值
                                     NSDictionary * resultDic =  [zzcAFN dictionaryWithJsonString:encodeStr];
                                     _zzcUser.Id = [[resultDic objectForKey:@"id"] intValue];
                                     _zzcUser.phoneNum = [resultDic objectForKey:@"phoneNumber"];
                                     _zzcUser.company = [resultDic objectForKey:@"flyUser"];
                                     _zzcUser.password = [resultDic objectForKey:@"password"];
                                     _zzcUser.userName = [resultDic objectForKey:@"userName"];
                                     
                                     //ShowResult(@"COMPANY:%@",_zzcUser.company);
                                     NSLog(@"ZZCUSER:%@",_zzcUser);
                                     
                                     
                                     //登录成功就同步到数据库，检查是否存在
                                     NSMutableArray * userArray = [self selectFromUserTable];
                                     if ([self checkUserExsit:userArray]) {
                                         NSLog(@"用户已存在，不需要插入");
                                     }else{
                                         NSLog(@"用户不存在，需要插入");
                                         [self addUser:_zzcUser];
                                     }
                                     
                                     //请求成功应该做什么处理呢？
                                     UIStoryboard * vb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                     ModeChooseViewController* rootVC = [vb instantiateViewControllerWithIdentifier:@"modeView"];
                                     
                                     rootVC.zzcUser = [[FlyUser alloc] init];
                                     rootVC.zzcUser.Id = _zzcUser.Id;
                                     rootVC.zzcUser.phoneNum = _zzcUser.phoneNum;
                                     rootVC.zzcUser.company = _zzcUser.company;
                                     rootVC.zzcUser.password = _zzcUser.password;
                                     rootVC.zzcUser.userName = _zzcUser.userName;
                                     
                                     [self.navigationController pushViewController:rootVC animated:YES];
                                     
                                 }
                                 
                             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                 
                                 ShowResult(@"网络请求失败！");
                                 NSLog(@"failure--%@",error);
                             }];
                             
                         }
                         
    /*单位账户登录*/
                         
                         
- (IBAction)defualtBtn_cliked:(id)sender {
    
    UIStoryboard * vb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ModeChooseViewController* rootVC = [vb instantiateViewControllerWithIdentifier:@"modeView"];
    
    rootVC.zzcUser = [[FlyUser alloc] init];
    rootVC.zzcUser.Id = -1;
    rootVC.zzcUser.phoneNum = [_company_tfd text];
    rootVC.zzcUser.company = [_company_tfd text];
    rootVC.zzcUser.password = [_company_tfd text];
    rootVC.zzcUser.userName = [_company_tfd text];
    
    
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
