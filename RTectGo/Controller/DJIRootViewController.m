//
//  DJIRootViewController.m
//  GSDemo
//
//  Created by ZZC on 7/7/18.
//  Copyright (c) 2018 Apple. All rights reserved.
//

#import "DJIRootViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJISDK.h>
#import "DJIMapController.h"
#import "DJIGSButtonViewController.h"
#import "DJIWaypointConfigViewController.h"
#import "DemoUtility.h"
#import "ZZCLocationChange.h"
#import "ZZCRoutePlan.h"
#import "DefaultLayoutViewController.h"
#import "DJFlightModeViewController.h"
#import "DJIHRWaypointConfigViewController.h"
#import <sqlite3.h>
#import "sqlitePoint.h"
#import "sqliteRoute.h"
//#import "zzcFPVViewController.h"
#import "ZZCWaypoint.h"
#import "WapianAnnotation.h"
#define ENTER_DEBUG_MODE 0


@interface DJIRootViewController ()<DJIGSButtonViewControllerDelegate, DJIWaypointConfigViewControllerDelegate, DJFlightModeViewControllerdelegate,  MKMapViewDelegate, CLLocationManagerDelegate, DJISDKManagerDelegate,DJIBatteryDelegate, DJIFlightControllerDelegate,DJIHRWaypointConfigViewControllerDelegate,DJICameraDelegate,UITableViewDelegate,UITableViewDataSource,LJKSlideViewDelegate>

@property (nonatomic, assign) BOOL isEditingPoints;//mapview是否可以编辑
@property (nonatomic, assign) BOOL wapianBool;//mapview是否可以编辑
@property (nonatomic, assign) BOOL lowBettery;//设置这个参数来专门解决低电量飞行的判断
@property (nonatomic, assign) BOOL quanjing_Bool;//设置这个参数来专门解决全景飞下可不可以编辑
@property (nonatomic, assign) int DragPointIndex;//判断拖拽动作发生哪个标记点上
@property (nonatomic, assign) int routeNum;//由于waypointMIssion存在99点数限制，因此设定此参数来解决超点问题
@property (nonatomic, assign) int saticRouteNum;//由于waypointMIssion存在99点数限制，因此设定此参数来解决超点问题
@property (nonatomic, assign) int oldPointsNum;//记录上次飞过了多少个点
@property (nonatomic, assign) int pointIndexNow;//记录飞到哪儿了
@property (nonatomic, assign) int pointIndexLastone;//记录断线的前一个点
@property (nonatomic, strong) DJIGSButtonViewController *gsButtonVC;//封装的button view
@property (nonatomic, strong) DJFlightModeViewController *fmButtonVC;//封装的 模式选择view
@property (nonatomic, strong) DJIWaypointConfigViewController *waypointConfigVC;//封装的条带飞配置View
@property (nonatomic, strong) DJIHRWaypointConfigViewController *HR_waypointConfigVC;//封装的环绕飞配置View
@property (nonatomic, strong) DJIMapController *mapController;//mapcontroller 实例
@property (nonatomic, strong) ZZCLocationChange *locationChange;//坐标系转换实例
@property (nonatomic, strong) ZZCRoutePlan *routePlan;//航点计算实例
@property(nonatomic, weak) DJIBaseProduct* product;
@property (nonatomic, assign) sqlite3 *routeDB;//航点存储数据库
@property (nonatomic, strong) NSMutableArray* route_Array;//定义数组来存储航线数据
@property (nonatomic, strong) NSMutableArray* map_Array;//定义数组来存储航线数据

@property(nonatomic, strong) MKTileOverlay* mkTileOverlay;//图层
@property(nonatomic, strong) CLLocationManager* locationManager;//定位管理实例
@property(nonatomic, assign) CLLocationCoordinate2D userLocation;//用户位置
@property(nonatomic, assign)  CLLocationCoordinate2D start_panLocation;//拖动开始前数组内第一个点的坐标
@property(nonatomic, assign) CLLocationCoordinate2D panLocation;//初始手势点击在地图中对应的经纬度
@property(nonatomic, assign) CLLocationCoordinate2D droneLocation;//无人机位置
@property(nonatomic, assign) CLLocationCoordinate2D centerCoor;//拖拽视图的中心坐标
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;//点击手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture1;//点击手势
@property (strong, nonatomic)  UIView *contentView;//拖拽视图  拖拽动作不能直接添加在overlays上面
@property (nonatomic, strong)CircleAnimationView *circleAniView;
@property (strong, nonatomic) yundongPolyLine *yunDPolyLine1;//单轨迹动态航线1
@property (strong, nonatomic) yundongPolyLine *q_yunDPolyLine1;//动态航线1
@property (strong, nonatomic) yundongPolyLine *q_yunDPolyLine2;//动态航线1
@property (strong, nonatomic) yundongPolyLine *q_yunDPolyLine3;//动态航线1
@property (strong, nonatomic) yundongPolyLine *q_yunDPolyLine4;//动态航线1
@property (strong, nonatomic) MKPolygon *wapianPolygon;
@property (strong, nonatomic) LJKSlideView *slide;
@property (strong, nonatomic) CheckTFView *tfview;
//下面是测试数据
@property(nonatomic, assign)  NSArray * tastData;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;//地图
@property (weak, nonatomic) IBOutlet UIView *topBarView;//顶部View
@property(nonatomic, strong) IBOutlet UILabel* modeLabel;
@property(nonatomic, strong) IBOutlet UILabel* gpsLabel;
@property(nonatomic, strong) IBOutlet UILabel* hsLabel;
@property(nonatomic, strong) IBOutlet UILabel* vsLabel;
@property(nonatomic, strong) IBOutlet UILabel* altitudeLabel;
@property (weak, nonatomic) IBOutlet UIButton *userlocaBtn;

@property (weak, nonatomic) IBOutlet UIButton *tasksBtn;

@property (weak, nonatomic) IBOutlet UILabel *batryLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *qinxieSegment;
@property (weak, nonatomic) IBOutlet UITableView *taskTableView;
@property (weak, nonatomic) IBOutlet UIView *taskView;
@property (weak, nonatomic) IBOutlet UILabel *flightMode_lab;
@property (weak, nonatomic) IBOutlet UILabel *uvaType_lb;
@property (weak, nonatomic) IBOutlet UILabel *userName_lb;
@property (weak, nonatomic) IBOutlet UILabel *company_lb;
@property (weak, nonatomic) IBOutlet UILabel *zzDate_lb;
@property (weak, nonatomic) IBOutlet UILabel *uvaState_lb;
@property (weak, nonatomic) IBOutlet UIButton *changeMode_btn;
@property (weak, nonatomic) IBOutlet UIButton *changeUser_btn;
@property (weak, nonatomic) IBOutlet UIButton *laqu_Btn;
@property (weak, nonatomic) IBOutlet UITableView *mapTableView;
@property (weak, nonatomic) IBOutlet UIView *mapHideView;
@property (weak, nonatomic) IBOutlet UIButton *maoHide_btn;
@property (weak, nonatomic) IBOutlet UIButton *mapShow_btn;


@property(nonatomic, strong) DJIMutableWaypointMission* waypointMission;//存储任务
@property(nonatomic, strong) DJIMutableWaypointMission* loadpointMission;//存储低电量下载任务
@property (nonatomic, assign) int routeIndex;//存储低电量下任务的处理进度
@property (nonatomic, assign) int beginIndex;//记录出发点的下表
@property (nonatomic, strong) NSMutableArray* wapian_Array;//定义数组来存储瓦片坐标
@property (nonatomic, strong) NSMutableArray* mission_Array;//定义数组来存储航线
@property (nonatomic, strong) NSMutableArray * index_Array;//定义数组来存储航线老的下表
@property (nonatomic, strong) NSMutableArray* dync_Points1;//定义数组来存储动态绘制航线1
@property (nonatomic, strong) NSMutableArray* q_dync_Points1;//定义数组来存储动态绘制航线1
@property (nonatomic, strong) NSMutableArray* q_dync_Points2;//定义数组来存储动态绘制航线1
@property (nonatomic, strong) NSMutableArray* q_dync_Points3;//定义数组来存储动态绘制航线1
@property (nonatomic, strong) NSMutableArray* q_dync_Points4;//定义数组来存储动态绘制航线1

@end

@implementation DJIRootViewController

- (void)viewWillAppear:(BOOL)animated
{
    
    //视图加载前开始定位
    [super viewWillAppear:animated];
    [self startUpdateLocation];
    [self.locationManager startUpdatingHeading];
    
    [self openSqlite];//打开数据库
    
    [self createTable];//建立新表格
    
    _route_Array = [self selectWithRtu];//查询所有数据
    _map_Array = [self selectLocalMap];//查询所有地图
    NSLog(@"数量：%lu",(unsigned long)_map_Array.count);
    
    
    

}

- (void)viewWillDisappear:(BOOL)animated
{
    //视图注销前结束定位
    [super viewWillDisappear:animated];
    
    DJICamera *camera = [self fetchCamera];
    if (camera && camera.delegate == self) {
        [camera setDelegate:nil];
    }
    [self.locationManager stopUpdatingLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    

    //无人机注册
    [self registerApp];
    //试图初始化  数据对象初始化
    [self initUI];
    [self initData];

    
//    MKTileOverlay * tile = [[MKTileOverlay alloc] initWithURLTemplate:@"http://mt0.google.cn/maps/vt?lyrs=s@773&gl=cn&x=84040&y=203207&z=19"];
//    [_mapView addOverlay:tile];

    
//    NSString * reviseTime = @"2019-1-22 19:27:23.08";
//    NSArray * strArray = [reviseTime componentsSeparatedByString:@"."];
//    int unixTime = [[self getTimeStrWithString:strArray[0]] intValue];
//    NSLog(@"unixTime:%d",unixTime);


    
    
    NSLog(@"ZZCUSER:%@",_zzcUser);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark Init Methods
-(void)initData
{
    
    NSLog(@"ZZCUSER:%@",_zzcUser);
    
    _wapianBool = NO;
    _pointIndexLastone = 0;
    //默认从头开始
    _beginIndex = 0;
    //默认一开始是不能全景编辑的
    _quanjing_Bool = NO;
    //默认理想状态下这个航线的点数是不超过99的因此将其设置为1
    _routeNum = 1;
    _saticRouteNum = 1;
    //默认试图开始是可以编辑的
    _isEditingPoints = YES;
    //默认低电量不存在
    _lowBettery = NO;
    //理想是全新航线
    _oldPointsNum = 0;
    _pointIndexNow = 0;
    //初始化认为这个倾斜飞的朝向是west
    _qinxie_mode = ZZCQinxieMode_west;
    //图层初始化
    self.mkTileOverlay = [self mapTileOverlay];
    self.userLocation = kCLLocationCoordinate2DInvalid;
    self.droneLocation = kCLLocationCoordinate2DInvalid;
    self.locationChange = [[ZZCLocationChange alloc] init];
    self.routePlan = [[ZZCRoutePlan alloc] init];
    _routePlan.mode = _mode;
    self.mapController = [[DJIMapController alloc] init];
    self.route_Array = [[NSMutableArray alloc] init];
    self.mission_Array = [[NSMutableArray alloc] init];
    self.index_Array = [[NSMutableArray alloc] init];
    self.dync_Points1 = [[NSMutableArray alloc] init];
    self.q_dync_Points1 = [[NSMutableArray alloc] init];
    self.q_dync_Points2 = [[NSMutableArray alloc] init];
    self.q_dync_Points3 = [[NSMutableArray alloc] init];
    self.q_dync_Points4 = [[NSMutableArray alloc] init];
    self.wapian_Array = [[NSMutableArray alloc] init];
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addWaypoints:)];
    [self.mapView addGestureRecognizer:self.tapGesture];
    
    
    self.tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addWaypoints1:)];
    [self.mapView addGestureRecognizer:self.tapGesture1];
    
    self.slide.delegate = self;
    
}

-(void)initRoute
{
    
    CLLocationCoordinate2D centerLoc;
    //新建任务的矩形自己跟你设定好 无人机有定位就用无人机为中心 没有定位就用设备位置为中心
    if (CLLocationCoordinate2DIsValid(_droneLocation)) {
        centerLoc = _droneLocation;
    }else{
        
        centerLoc = _userLocation;
        
    }
    
    //_loadOrNot = false;
    
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(centerLoc.latitude, centerLoc.longitude);
    CLLocationCoordinate2D coor_changed = [_locationChange MarsGS2WorldGS:coor];
    CLLocationCoordinate2D coor1 = CLLocationCoordinate2DMake(centerLoc.latitude + 0.001, centerLoc.longitude + 0.001);
    CLLocationCoordinate2D coor1_changed = [_locationChange MarsGS2WorldGS:coor1];
    CLLocationCoordinate2D coor2 = CLLocationCoordinate2DMake(centerLoc.latitude - 0.001, centerLoc.longitude + 0.001);
    CLLocationCoordinate2D coor2_changed = [_locationChange MarsGS2WorldGS:coor2];
    CLLocationCoordinate2D coor3 = CLLocationCoordinate2DMake(centerLoc.latitude - 0.001, centerLoc.longitude - 0.001);
    CLLocationCoordinate2D coor3_changed = [_locationChange MarsGS2WorldGS:coor3];
    CLLocationCoordinate2D coor4 = CLLocationCoordinate2DMake(centerLoc.latitude + 0.001, centerLoc.longitude - 0.001);
    CLLocationCoordinate2D coor4_changed = [_locationChange MarsGS2WorldGS:coor4];
    
    CLLocation * location = [[CLLocation alloc] initWithLatitude:coor_changed.latitude longitude:coor_changed.longitude];
    CLLocation * location1 = [[CLLocation alloc] initWithLatitude:coor1_changed.latitude longitude:coor1_changed.longitude];
    CLLocation * location2 = [[CLLocation alloc] initWithLatitude:coor2_changed.latitude longitude:coor2_changed.longitude];
    CLLocation * location3 = [[CLLocation alloc] initWithLatitude:coor3_changed.latitude longitude:coor3_changed.longitude];
    CLLocation * location4 = [[CLLocation alloc] initWithLatitude:coor4_changed.latitude longitude:coor4_changed.longitude];
    
    [_mapController.editPoints removeAllObjects];
    [_mapController.route.point_array removeAllObjects];
    if (_mode == ZZCRouteMode_quanjin) {
        [_mapController.editPoints addObject:location];
        sqlitePoint * point = [[sqlitePoint alloc] init];
        point.point_x = location.coordinate.latitude;
        point.point_y = location.coordinate.longitude;
        [_mapController.route.point_array addObject:point];
    }else{
    
        [_mapController.editPoints addObject:location1];
        sqlitePoint * point1 = [[sqlitePoint alloc] init];
        point1.point_x = location1.coordinate.latitude;
        point1.point_y = location1.coordinate.longitude;
        [_mapController.route.point_array addObject:point1];
        [_mapController.editPoints addObject:location2];
        sqlitePoint * point2 = [[sqlitePoint alloc] init];
        point2.point_x = location2.coordinate.latitude;
        point2.point_y = location2.coordinate.longitude;
        [_mapController.route.point_array addObject:point2];
        [_mapController.editPoints addObject:location3];
        sqlitePoint * point3 = [[sqlitePoint alloc] init];
        point3.point_x = location3.coordinate.latitude;
        point3.point_y = location3.coordinate.longitude;
        [_mapController.route.point_array addObject:point3];
        [_mapController.editPoints addObject:location4];
        sqlitePoint * point4 = [[sqlitePoint alloc] init];
        point4.point_x = location4.coordinate.latitude;
        point4.point_y = location4.coordinate.longitude;
        [_mapController.route.point_array addObject:point4];
    }
    
    
    switch (self.mode) {
        case ZZCRouteMode_tiaodai:
        {
            _routePlan.mode = _mode;
            [self.mapController setPointView:_mapController.editPoints withMapView:_mapView];
            _centerCoor = [self.mapController setPolygonView:self.mapController.editPoints withMapView:self.mapView withCenterView:_contentView withCenterCoor:_centerCoor];
            NSLog(@"_centerCoor:%f   %f",_centerCoor.latitude,_centerCoor.longitude);
            [self.mapController setMiddlePoint:self.mapController.editPoints withMapView:self.mapView];
            //[_routePlan updateRouteView:_mapController.editPoints withMapView:_mapView];
            NSLog(@"模式为条带飞");
        }
            break;
        case ZZCRouteMode_huanxing:
        {
            _routePlan.mode = _mode;
            _centerCoor = [self.mapController setPolygonView:self.mapController.editPoints withMapView:self.mapView withCenterView:_contentView withCenterCoor:_centerCoor];
            [self.mapController setPointView:_mapController.editPoints withMapView:_mapView];
            //[self.mapController setMiddlePoint:self.mapController.editPoints withMapView:self.mapView];
            //[_routePlan updateRouteView:_mapController.editPoints withMapView:_mapView];
            NSLog(@"模式为环形飞");
        }
            break;
        case ZZCRouteMode_qinxie:
        {
            {
                _routePlan.mode = _mode;
                _routePlan.qinxie_mode = _qinxie_mode;
                [self.mapController setPointView:_mapController.editPoints withMapView:_mapView];
                _centerCoor = [self.mapController setPolygonView:self.mapController.editPoints withMapView:self.mapView withCenterView:_contentView withCenterCoor:_centerCoor];
                [self.mapController setMiddlePoint:self.mapController.editPoints withMapView:self.mapView];
                //[_routePlan updateRouteView:_mapController.editPoints withMapView:_mapView];
                
                
                //一开始默认为显示西边的
                [_routePlan fetchAllqinxieRound:_mapController.editPoints];
                //[self.mapController setPointView:_routePlan.westLocations withMapView:_mapView];
                [_mapController setqinxiePolygonView:_routePlan.westLocations northPoints:_routePlan.northLocations eastPoints:_routePlan.eastLocations southPoints:_routePlan.southLocations withMapView:_mapView];
                //[_routePlan updateRouteView:_routePlan.westLocations withMapView:_mapView];
                NSLog(@"模式为倾斜飞");
            }
        }
            break;
        case ZZCRouteMode_quanjin:
        {
            {
            _routePlan.mode = _mode;
                _waypointConfigVC.mode = _mode;
                [_waypointConfigVC setModeUI:_mode height:50 angle:_mapController.route.angle px_CD:0.6 hx_CD:0.8 qinxieAngle:45];
                [self.mapController setPointView:_mapController.editPoints withMapView:_mapView];
            NSLog(@"模式为全景飞");
            }
        }
            break;
            
        default:
            //self.mode = ZZCRouteMode_zidingyi;
            break;
    }
    
    
    
    
    
    
}

-(void) initUI
{
    
    CGFloat width = self.view.bounds.size.width * 1/2;
    CGFloat height = self.view.bounds.size.height * 1/6;
    CGFloat x = self.view.bounds.size.width * 1/4;
    CGFloat y = self.view.bounds.size.height * 2/3;
    self.slide = [[LJKSlideView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [self.view addSubview:_slide];
    [_slide setHidden:YES];
    
    self.tfview = [[CheckTFView alloc] initWithFrame:CGRectMake(x, y - height*3, width, height*3)];
    [self.view addSubview:_tfview];
    [_tfview setHidden:YES];
    
    [_mapHideView setHidden:NO];
    [_userlocaBtn setHidden:YES];
    [_tasksBtn setHidden:YES];
    [_mapShow_btn setHidden:YES];
    
    //底部更新
    [self updateDibuLabels];
    
    //隐藏鸡无敌
    [_changeMode_btn setHidden:YES];
    [_changeUser_btn setHidden:YES];
    
    _flightMode_lab.userInteractionEnabled=YES;
    _userName_lb.userInteractionEnabled=YES;

    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(modelabelTouchUpInside:)];
        UITapGestureRecognizer *labelTapGestureRecognizer1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userabelTouchUpInside:)];
    
    [_flightMode_lab addGestureRecognizer:labelTapGestureRecognizer];
    [_userName_lb addGestureRecognizer:labelTapGestureRecognizer1];
    

  
    
    //topbar 设置
    [_topBarView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, _topBarView.bounds.size.height)];
    
    
    
    //先把任务列表隐藏起来
    [_taskTableView setHidden:NO];
    
    _mapTableView.delegate = self;
    _mapTableView.dataSource = self;
    
    
    switch (_mode) {
        case ZZCRouteMode_quanjin:
            [_qinxieSegment setHidden:NO];
            [_qinxieSegment setSelectedSegmentIndex:1];
            break;
            
        default:
            [_qinxieSegment setHidden:YES];
            break;
    }
    
    self.circleAniView = [[CircleAnimationView alloc] initWithFrame:CGRectMake(100,100, 200, 200)];
    self.circleAniView.center = self.view.center;
    self.circleAniView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.circleAniView];
    [_circleAniView setHidden:YES];
    
    self.modeLabel.text = @"N/A";
    self.gpsLabel.text = @"0";
    self.vsLabel.text = @"0.0 M/S";
    self.hsLabel.text = @"0.0 M/S";
    self.altitudeLabel.text = @"0 M";
    
    CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
    //statusRect.size.height
    NSLog(@"statusRect.origin.y:%f",statusRect.origin.y);
    self.gsButtonVC = [[DJIGSButtonViewController alloc] initWithNibName:@"DJIGSButtonViewController" bundle:[NSBundle mainBundle]];

   [self.gsButtonVC.view setFrame:CGRectMake(0, self.topBarView.frame.origin.y + self.view.bounds.size.height/12, self.gsButtonVC.view.frame.size.width, self.gsButtonVC.view.frame.size.height)];
    NSLog(@"self.topBarView.frame.origin.y:%f",self.topBarView.frame.origin.y);
    NSLog(@"self.topBarView.frame.size.height:%f",self.topBarView.frame.size.height);
    NSLog(@"self.topBarView.frame.size.width:%f",self.topBarView.frame.size.width);
    NSLog(@"self.gsButtonVC.frame.origin.y:%f",self.gsButtonVC.view.frame.origin.y);
    self.gsButtonVC.delegate = self;
    [self.view addSubview:self.gsButtonVC.view];
    
    
    self.fmButtonVC = [[DJFlightModeViewController alloc] initWithNibName:@"DJFlightModeViewController" bundle:[NSBundle mainBundle]];
    self.fmButtonVC.view.alpha = 0;
    self.fmButtonVC.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    
    [self.fmButtonVC.view setCenter:self.view.center];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) //Check if it's using iPad and center the config view
    {
        self.fmButtonVC.view.center = self.view.center;
    }
    
    self.fmButtonVC.delegate = self;
    [self.view addSubview:self.fmButtonVC.view];
    
    
    self.waypointConfigVC = [[DJIWaypointConfigViewController alloc] initWithNibName:@"DJIWaypointConfigViewController" bundle:[NSBundle mainBundle]];
    self.waypointConfigVC.view.alpha = 0;
    self.waypointConfigVC.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    
    [self.waypointConfigVC.view setCenter:self.view.center];
    
    
    self.HR_waypointConfigVC = [[DJIHRWaypointConfigViewController alloc] initWithNibName:@"DJIHRWaypointConfigViewController" bundle:[NSBundle mainBundle]];
    self.HR_waypointConfigVC.view.alpha = 0;
    self.HR_waypointConfigVC.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    
    [self.HR_waypointConfigVC.view setCenter:self.view.center];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) //Check if it's using iPad and center the config view
    {
        self.waypointConfigVC.view.center = self.view.center;
        self.HR_waypointConfigVC.view.center = self.view.center;
    }

    self.waypointConfigVC.delegate = self;
    self.HR_waypointConfigVC.delegate = self;
    
    [self.view addSubview:self.waypointConfigVC.view];
    [self.view addSubview:self.HR_waypointConfigVC.view];
    
    
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(300, 300, 100, 100)];
    _contentView.backgroundColor = [UIColor clearColor];
    _contentView.layer.borderWidth = 0.1;
    [_contentView setHidden:YES];
    _contentView.layer.cornerRadius = _contentView.bounds.size.width / 2;
    //[_contentView setImage:[UIImage imageNamed:@"center"]];
    
    [self.mapView addSubview:_contentView];
    
//    //加涂层
//    _mkTileOverlay = [self mapTileOverlay];
//    [self.mapView addOverlay:_mkTileOverlay];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewHandlePan:)];
    [_contentView addGestureRecognizer:pan];
}

-(void) registerApp
{
    
    //Please enter your App key in the info.plist file to register the app.
    [DJISDKManager registerAppWithDelegate:self];
}



//设置本函数来决定试图是否可以被拖移
-(void) setEditMode:(BOOL) isediting{


    if (isediting == YES) {
        [_contentView setHidden:NO];
        
    }else{
        [_contentView setHidden:YES];
    }
    
}

#pragma mark Mapview Methods

- (void) tiaodai_LineView:(int)beginIndex realIndex:(int)realIndex pointCount:(int)pointCount {
   
   // 这里需要处理断线重新渲染的问题
                if (_pointIndexLastone != 0) {
    
//                    ShowResult(@"_pointIndexLastone:%d\nrealIndex:%d",_pointIndexLastone,realIndex);
                    ShowResult(@"重新连接啦！");
                    for (int i = _pointIndexLastone; i < realIndex; i++) {
    
                        DJIWaypoint * waypoint = [_mission_Array objectAtIndex:i];
                        CLLocationCoordinate2D waypoint2D = [_locationChange WorldGS2MarsGS:waypoint.coordinate];
                        CLLocation * unkowmLoc = [[CLLocation alloc] initWithLatitude:waypoint2D.latitude longitude:waypoint2D.longitude];
    
    
                        if ([self dyncPolyLine:_beginIndex nextIndex:i pointCount:(int)_mission_Array.count] == 1) {
                            [_dync_Points1 addObject:unkowmLoc];
                        }else{
                            [_dync_Points1 insertObject:unkowmLoc atIndex:0];
                        }
                    }
    
                    _pointIndexLastone = 0;
                }
    
    
    
    
    //不等于零说明需要绘制 这里需要担心点轨迹重复的问题
    if ([self dyncPolyLine:beginIndex nextIndex:realIndex pointCount:pointCount] != 0 && _pointIndexLastone == 0) {
        
        //ShowMessage(@"需要绘制", @"", nil, @"OK");
        
        if ([self dyncPolyLine:_beginIndex nextIndex:realIndex pointCount:(int)_mission_Array.count] == 1) {
            
//            ShowResult(@"_begiIndex:%d\n realIndex:%d\n pointCount:%d\n currentIndex:%d",_beginIndex,realIndex,_mission_Array.count,_mapController.route.currentIndex);
            CLLocation * location = [[CLLocation alloc] initWithLatitude:_droneLocation.latitude longitude:_droneLocation.longitude];
            [_dync_Points1 addObject:location];
        }else{
            
//            ShowResult(@"_begiIndex:%d\n realIndex:%d\n pointCount:%d\n currentIndex:%d",_beginIndex,realIndex,_mission_Array.count,_mapController.route.currentIndex);
            CLLocation * location = [[CLLocation alloc] initWithLatitude:_droneLocation.latitude longitude:_droneLocation.longitude];
            [_dync_Points1 insertObject:location atIndex:0];
        }
        [self tiaodai_huizhi];
        
        
    }
    
}


-(void) qinxie_LineView:(int)beginIndex realIndex:(int)realIndex pointCount:(int)pointCount{
    
    
    //不等于零说明需要绘制 这里需要担心点轨迹重复的问题
    if ([self q_dyncPolyLine:beginIndex nextIndex:realIndex pointCount:pointCount] != 0) {
        
        
        
        // 这里需要处理断线重新渲染的问题
        if (_pointIndexLastone != 0) {
            
//            ShowResult(@"_pointIndexLastone:%d\nrealIndex:%d",_pointIndexLastone,(_saticRouteNum - _routeNum - 1) * 99 + (int)[self.missionOperator.latestExecutionProgress targetWaypointIndex]);
            ShowResult(@"重新连接啦！");
            for (int i = _pointIndexLastone; i < (_saticRouteNum - _routeNum - 1) * 99 + (int)[self.missionOperator.latestExecutionProgress targetWaypointIndex]; i++) {
                
                DJIWaypoint * waypoint = [_mission_Array objectAtIndex:i];
                ZZCWaypoint * zzcWP = [_index_Array objectAtIndex:i];
                CLLocationCoordinate2D waypoint2D = [_locationChange WorldGS2MarsGS:waypoint.coordinate];
                CLLocation * unkowmLoc = [[CLLocation alloc] initWithLatitude:waypoint2D.latitude longitude:waypoint2D.longitude];
                
                int nextIndex;
                
                if (zzcWP.index >= _mapController.route.beginIndex) {
                    nextIndex = zzcWP.index - _mapController.route.beginIndex;
                }else{
                    nextIndex = _mapController.route.pointCount - zzcWP.index - 1;
                    
                }
                
                
               int siweich =  [self q_dyncPolyLine:_mapController.route.beginIndex nextIndex:nextIndex pointCount:_mapController.route.pointCount];
                
                switch (siweich) {
                    case 1:
                        
                        [_q_dync_Points1 addObject:unkowmLoc];
                        break;
                    case -1:
                        
                        [_q_dync_Points1 insertObject:unkowmLoc atIndex:0];
                        break;
                    case 2:
                        
                        [_q_dync_Points2 addObject:unkowmLoc];
                        break;
                    case 3:
                        
                        [_q_dync_Points3 addObject:unkowmLoc];
                        break;
                    case 4:
                        
                        [_q_dync_Points4 addObject:unkowmLoc];
                        break;
                        
                    default:
                        break;
                }
            }
            
            _pointIndexLastone = 0;
        }else{
        
        if ([self q_dyncPolyLine:_beginIndex nextIndex:realIndex pointCount:(int)_mission_Array.count] == 1) {
//            ShowResult(@"_begiIndex:%d\n realIndex:%d\n pointCount:%d\n currentIndex:%d",_mapController.route.beginIndex,realIndex,_mapController.route.pointCount,_mapController.route.currentIndex);
            CLLocation * location = [[CLLocation alloc] initWithLatitude:_droneLocation.latitude longitude:_droneLocation.longitude];
            [_q_dync_Points1 addObject:location];
        }else if([self q_dyncPolyLine:_beginIndex nextIndex:realIndex pointCount:(int)_mission_Array.count] == -1){
//            ShowResult(@"_begiIndex:%d\n realIndex:%d\n pointCount:%d\n currentIndex:%d",_mapController.route.beginIndex,realIndex,_mapController.route.pointCount,_mapController.route.currentIndex);
            CLLocation * location = [[CLLocation alloc] initWithLatitude:_droneLocation.latitude longitude:_droneLocation.longitude];
            [_q_dync_Points1 insertObject:location atIndex:0];
        }else if([self q_dyncPolyLine:_beginIndex nextIndex:realIndex pointCount:(int)_mission_Array.count] == 2){
//            ShowResult(@"_begiIndex:%d\n realIndex:%d\n pointCount:%d\n currentIndex:%d",_mapController.route.beginIndex,realIndex,_mapController.route.pointCount,_mapController.route.currentIndex);
            CLLocation * location = [[CLLocation alloc] initWithLatitude:_droneLocation.latitude longitude:_droneLocation.longitude];
            [_q_dync_Points2 addObject:location];
        }else if([self q_dyncPolyLine:_beginIndex nextIndex:realIndex pointCount:(int)_mission_Array.count] == 3){
//            ShowResult(@"_begiIndex:%d\n realIndex:%d\n pointCount:%d\n currentIndex:%d",_mapController.route.beginIndex,realIndex,_mapController.route.pointCount,_mapController.route.currentIndex);
            CLLocation * location = [[CLLocation alloc] initWithLatitude:_droneLocation.latitude longitude:_droneLocation.longitude];
            [_q_dync_Points3 addObject:location];
        }else {
//            ShowResult(@"_begiIndex:%d\n realIndex:%d\n pointCount:%d\n currentIndex:%d",_mapController.route.beginIndex,realIndex,_mapController.route.pointCount,_mapController.route.currentIndex);
            CLLocation * location = [[CLLocation alloc] initWithLatitude:_droneLocation.latitude longitude:_droneLocation.longitude];
            [_q_dync_Points4 addObject:location];
        }
        }
        
        [self qinxie_huizhi];
        
        
    }
}


-(void) qinxie_huizhi{
    
    //在这里声明一个数组专门存这些点的2d坐标用来绘制路线
    CLLocationCoordinate2D  points1[_q_dync_Points1.count];
    CLLocationCoordinate2D * pPoint1 = points1;
    CLLocationCoordinate2D  points2[_q_dync_Points2.count];
    CLLocationCoordinate2D * pPoint2 = points2;
    CLLocationCoordinate2D  points3[_q_dync_Points3.count];
    CLLocationCoordinate2D * pPoint3 = points3;
    CLLocationCoordinate2D  points4[_q_dync_Points4.count];
    CLLocationCoordinate2D * pPoint4 = points4;
    
    [_q_dync_Points1 enumerateObjectsUsingBlock:^(CLLocation *location, NSUInteger idx, BOOL *stop){
        pPoint1[idx] = location.coordinate;
    }];
    [_q_dync_Points2 enumerateObjectsUsingBlock:^(CLLocation *location, NSUInteger idx, BOOL *stop){
        pPoint2[idx] = location.coordinate;
    }];
    [_q_dync_Points3 enumerateObjectsUsingBlock:^(CLLocation *location, NSUInteger idx, BOOL *stop){
        pPoint3[idx] = location.coordinate;
    }];
    [_q_dync_Points4 enumerateObjectsUsingBlock:^(CLLocation *location, NSUInteger idx, BOOL *stop){
        pPoint4[idx] = location.coordinate;
    }];
    
    
    //绘制路线
    if (_q_yunDPolyLine1 == nil) {
        _q_yunDPolyLine1 = [yundongPolyLine polylineWithCoordinates:points1 count:_q_dync_Points1.count];
        [_mapView addOverlay:_q_yunDPolyLine1];
    }else{
        
        [_mapView removeOverlay:_q_yunDPolyLine1];
        _q_yunDPolyLine1 = [yundongPolyLine polylineWithCoordinates:points1 count:_q_dync_Points1.count];
        [_mapView addOverlay:_q_yunDPolyLine1];
        
        
    }
    //绘制路线
    if (_q_yunDPolyLine2 == nil) {
        _q_yunDPolyLine2 = [yundongPolyLine polylineWithCoordinates:points2 count:_q_dync_Points2.count];
        [_mapView addOverlay:_q_yunDPolyLine2];
    }else{
        
        [_mapView removeOverlay:_q_yunDPolyLine2];
        _q_yunDPolyLine2 = [yundongPolyLine polylineWithCoordinates:points2 count:_q_dync_Points2.count];
        [_mapView addOverlay:_q_yunDPolyLine2];
        
        
    }
    
    //绘制路线
    if (_q_yunDPolyLine3 == nil) {
        _q_yunDPolyLine3 = [yundongPolyLine polylineWithCoordinates:points3 count:_q_dync_Points3.count];
        [_mapView addOverlay:_q_yunDPolyLine3];
    }else{
        
        [_mapView removeOverlay:_q_yunDPolyLine3];
        _q_yunDPolyLine3 = [yundongPolyLine polylineWithCoordinates:points3 count:_q_dync_Points3.count];
        [_mapView addOverlay:_q_yunDPolyLine3];
        
        
    }
    
    //绘制路线
    if (_q_yunDPolyLine4 == nil) {
        _q_yunDPolyLine4 = [yundongPolyLine polylineWithCoordinates:points4 count:_q_dync_Points4.count];
        [_mapView addOverlay:_q_yunDPolyLine4];
    }else{
        
        [_mapView removeOverlay:_q_yunDPolyLine4];
        _q_yunDPolyLine4 = [yundongPolyLine polylineWithCoordinates:points4 count:_q_dync_Points4.count];
        [_mapView addOverlay:_q_yunDPolyLine4];
 
    }
}


-(void) tiaodai_huizhi{
    
    CLLocationCoordinate2D  points1[_dync_Points1.count];
    CLLocationCoordinate2D * pPoint = points1;
    
    [_dync_Points1 enumerateObjectsUsingBlock:^(CLLocation *location, NSUInteger idx, BOOL *stop){
        pPoint[idx] = location.coordinate;
    }];
    
    
    //绘制路线
    if (_yunDPolyLine1 == nil) {
        _yunDPolyLine1 = [yundongPolyLine polylineWithCoordinates:points1 count:_dync_Points1.count];
        [_mapView addOverlay:_yunDPolyLine1];
    }else{
        
        [_mapView removeOverlay:_yunDPolyLine1];
        _yunDPolyLine1 = [yundongPolyLine polylineWithCoordinates:points1 count:_dync_Points1.count];
        [_mapView addOverlay:_yunDPolyLine1];
        
        
    }
}


- (void) newRouteLine{
    
    _mapController.route.currentIndex = -1;
    _mapController.route.beginIndex = 0;
    _mapController.route.pointCount = 0;
    [self updateWithRoute:_mapController.route];
}

#pragma mark Custom Methods
/*******************************
求取多边形中心
 *******************************/

-(CLLocationCoordinate2D) fetchCenter:(NSMutableArray *)Array{
    
    double coorLat = 0.0;
    double coorLon = 0.0;
    
    for (int  i = 0; i < Array.count; i++) {
        WapianAnnotation * ann = [Array objectAtIndex:i];
        
        coorLat += ann.coordinate.latitude;
        coorLon += ann.coordinate.longitude;
        
    }
    
    return  CLLocationCoordinate2DMake(coorLat/Array.count, coorLon/Array.count);
    
}

/*******************************
 NSMutableArray 2 NSString methods
 *******************************/
- (NSString *)array2str:(NSMutableArray *) Array{
    
    NSString * resultStr = @"";
    for (int i = 0; i < Array.count; i++) {
        NSString * tempStr = [Array objectAtIndex:i];
        if ([resultStr isEqualToString:@""]) {
            resultStr = tempStr;
        }else{
        resultStr = [NSString stringWithFormat:@"%@*%@",resultStr,tempStr];
        }
    }
    
    return resultStr;
    
}


/*******************************
 NSString 2 NSMutableArray methods
 *******************************/
- (NSMutableArray *)str2array:(NSString *) str{
    
    NSMutableArray * resultArray = [[NSMutableArray alloc] init];
    NSArray * strArray = [str componentsSeparatedByString:@"*"];
    
    resultArray = [[NSMutableArray alloc] initWithArray:strArray];
    
    return resultArray;
}


/******************************
 paixu Download methods
 ******************************/

- (NSMutableArray *)addWithTime:(NSMutableArray *) rtus rtu:(sqliteRoute*)rtu{
    for (int i = 0; i < rtus.count; i++) {
        sqliteRoute * old = [rtus objectAtIndex:i];
        NSArray * strArray = [old.time componentsSeparatedByString:@"."];
        int oldTime = [[self getTimeStrWithString:strArray[0]] intValue];
        
        NSArray * strArray1 = [rtu.time componentsSeparatedByString:@"."];
        int newTime = [[self getTimeStrWithString:strArray1[0]] intValue];
        
        if (newTime > oldTime) {
            [rtus insertObject:rtu atIndex:i];
            return rtus;
        }
        
    }
    
    return rtus;
    
}


/******************************
AFN Download methods
 ******************************/
- (void) AFNdownloadWapian:(NSMutableArray * ) urls localUrls:(NSMutableArray *)localUrls map:(LocalMap *) map{
    
    /* 创建网络下载对象 */
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    if (urls.count == 0) {
        //所有瓦片都下载完成了
        map.statuscode = 1;
        map.url = [self array2str:localUrls];
        //[self updateLocalMap:map];
        [self updateLocalMap:map];
        return;
    }
    
    //每次取urls数组的第一个 下完就删掉
    NSString * urlStr = [urls objectAtIndex:0];
    //把下载的瓦片的x y z 信息保存到本地 后面离线加载寻址
    NSArray * arry = [urlStr componentsSeparatedByString:@"x"];
    NSString * urlStrHeli = [arry objectAtIndex:1];
    urlStrHeli = [NSString stringWithFormat:@"x%@",urlStrHeli];
    /* 下载地址 */
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    /* 保存路径 */
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",urlStrHeli]];
    ////把下载的瓦片的x y z 信息保存到本地 后面离线加载寻址
    NSString * zzcPath = [NSString stringWithFormat:@"%@.png",urlStrHeli];
    NSLog(@"zzcPath:%@",zzcPath);
    [localUrls addObject:zzcPath];

    

    /* 开始请求下载 */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"下载进度：%.0f％", downloadProgress.fractionCompleted * 100);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //如果需要进行UI操作，需要获取主线程进行操作
        });
        /* 设定下载到的位置 */
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [urls removeObjectAtIndex:0];
        NSLog(@"下载完成,剩余:%lu",(unsigned long)urls.count);
        NSLog(@"ZZCfilePath:%@",filePath);
        [self AFNdownloadWapian:urls localUrls:localUrls map:map];
    }];
    [downloadTask resume];

    
}

/******************************
MKmaptiles methods
 ******************************/
- (NSMutableArray *)mapTileOverlays:(NSMutableArray *)urls{
    
    NSMutableArray * tiles = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < urls.count; i++) {
        NSString * url = [urls objectAtIndex:i];
        MKTileOverlay * tile = [[MKTileOverlay alloc] initWithURLTemplate:url];
        [tile setCanReplaceMapContent:NO];
        [tile setMinimumZ:3];
        [tile setMaximumZ:30];
        //[tile setCoordinate:CLLocationCoordinate2DMake(30.532876,114.36202)];
        [tiles addObject:tile];
    }
    
    return tiles;
    
}


/******************************
 WaPian URL methods
 ******************************/
- (NSMutableArray *) wapianUrl:(NSMutableArray *) ann_array{
    
    NSMutableArray * loc_Change = [[NSMutableArray alloc] init];
    for (int i = 0; i < ann_array.count; i++) {
        WapianAnnotation * anni = [ann_array objectAtIndex:i];
        //CLLocationCoordinate2D new2D = [_locationChange WorldGS2MarsGS:anni.coordinate];
        CLLocationCoordinate2D new2D = anni.coordinate;
        WapianAnnotation * newAnn = [[WapianAnnotation alloc] initWithCoordiante:new2D];
        [loc_Change addObject:newAnn];
    }

    WapianAnnotation * ann0 = [loc_Change objectAtIndex:0];
    double min_X = ann0.coordinate.longitude;
    double min_Y = ann0.coordinate.latitude;
    double max_X = ann0.coordinate.longitude;
    double max_Y = ann0.coordinate.latitude;
    
    for (int i = 0; i < loc_Change.count; i++) {
        WapianAnnotation* anni = [loc_Change objectAtIndex:i];
        if(anni.coordinate.longitude < min_X) min_X = anni.coordinate.longitude;
        if(anni.coordinate.longitude > max_X) max_X = anni.coordinate.longitude;
        if(anni.coordinate.latitude < min_Y) min_Y = anni.coordinate.latitude;
        if(anni.coordinate.latitude > max_Y) max_Y = anni.coordinate.latitude;
    }
    NSMutableArray * returnStr = [[NSMutableArray alloc] init];
    int zoomLevel = 19;
    
   // for (int z = 0; z < zoomLevel ; z++) {
        //起始结束行
        int minR = [self getOSMTileYFromLatitude:max_Y zoom:zoomLevel];
        int maxR = [self getOSMTileYFromLatitude:min_Y zoom:zoomLevel];
        //起始结束列
        int minC = [self getOSMTileXFromLongitude:min_X zoom:zoomLevel];
        int maxC = [self getOSMTileXFromLongitude:max_X zoom:zoomLevel];
        NSLog(@"minX:%f\nmaxX:%f\nminY:%f\nmaxY:%f",min_X,max_X,min_Y,max_Y);
        NSLog(@"minR:%d\nmaxR:%d\nminC:%d\nmaxC:%d",minR,maxR,minC,maxC);
        
        
        for(int y=minR;y<=maxR;y++){
            for(int x=minC;x<=maxC;x++){
                
                NSString * urlstr = [NSString stringWithFormat:@"http://mt0.google.cn/maps/vt?lyrs=s@773&gl=cn&x=%d&y=%d&z=%d",x,y,zoomLevel];
                NSLog(@"minR:%d\nmaxR:%d\nminC:%d\nmaxC:%d\nurl:%@",minR,maxR,minC,maxC,urlstr);
                [returnStr addObject:urlstr];
            }
        }
   // }
    
    
    return returnStr;

}

/******************************
Polygon methods
 ******************************/

- (void) polygonInmapview:(MKMapView *)mapView points:(NSMutableArray*)points{
    
    CLLocationCoordinate2D cooPoints[points.count];
    for (int i = 0; i < points.count; i++) {
        WapianAnnotation * location = [points objectAtIndex:i];
        CLLocationCoordinate2D coordinate = location.coordinate;
        cooPoints[i] = coordinate;
    }
    
    if (_wapianPolygon == nil) {
        _wapianPolygon = [MKPolygon polygonWithCoordinates:cooPoints count:points.count];
        [mapView addOverlay:_wapianPolygon];
    }
    [mapView removeOverlay:_wapianPolygon];
    _wapianPolygon = [MKPolygon polygonWithCoordinates:cooPoints count:points.count];
    [mapView addOverlay:_wapianPolygon];
    
}


/******************************
 MKtile methods
 ******************************/

//get x from lon
- (int) getOSMTileXFromLongitude:(double) lon zoom:(int) zoom {
 
    return (int) (floor((lon + 180) / 360 * pow(2, zoom)));
 

 }

//get y from lat
- (int) getOSMTileYFromLatitude:(double) lat zoom:(int) zoom {
    
    return (int) (floor((1 - log(tan(lat * M_PI / 180) + 1 / cos(lat * M_PI / 180)) /M_PI) / 2 * pow(2, zoom)));
    
}


/******************************
labekdianji methods
 ******************************/
-(void) modelabelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    
    if (_changeMode_btn.isHidden == YES) {
        [_changeMode_btn setHidden:NO];
    }else{
        [_changeMode_btn setHidden:YES];
        
    }
    
}

-(void) userabelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    
    if (_changeUser_btn.isHidden == YES) {
        [_changeUser_btn setHidden:NO];
    }else{
        [_changeUser_btn setHidden:YES];
        
    }

}
/******************************
选择性本地删除 methods
 ******************************/
-(void) loc_sync_delete:(NSDictionary *)Dic route_Array:(NSMutableArray *)route_Array{
    NSMutableArray * listArry = [Dic objectForKey:@"list"];
    NSMutableArray * testArry = [[NSMutableArray alloc] init];

    
    for (int i =0; i < route_Array.count; i++) {
        sqliteRoute * rtu = [route_Array objectAtIndex:i];
        ZZCInt * zzcInt = [[ZZCInt alloc] init];
        zzcInt.Id = rtu.Id;
        [testArry addObject:zzcInt];
    }
    
    for (int i = 0; i < testArry.count; i++) {
        BOOL yesOrno = YES;
        ZZCInt * zzc = [testArry objectAtIndex:i];
        //便利看看这个是不是存在
        for (int j = 0; j < listArry.count; j++) {
            NSDictionary * dic = [listArry objectAtIndex:j];
            int Id = [[dic objectForKey:@"id"] intValue];
            if (zzc.Id == Id) {
                yesOrno = NO;
            }
        }
        
        if (yesOrno == YES) {
            //不存在就删除
            [self deleteLocalRtu:[route_Array objectAtIndex:i]];
        }

    }
    
}

/******************************
 数据库同步 methods
 ******************************/

- (int) syncSqlite:(NSDictionary *) Dic{
    
    NSString * reviseTime = [Dic objectForKey:@"reviseTime"];
    int Id = [[Dic objectForKey:@"id"] intValue];
    
        NSArray * strArray = [reviseTime componentsSeparatedByString:@"."];
        int unixTime = [[self getTimeStrWithString:strArray[0]] intValue];
        
        //根据ID查询 查到了就比较时间戳 没查到就添加进去
        sqliteRoute * rtu = [self selectWithId:Id];
        if (rtu.Id == Id) {
            //前新后旧
            //有东西就比较这个时间戳判断是不是要同步到数据库里里面
            NSArray * strArray1 = [rtu.time componentsSeparatedByString:@"."];
            int loc_unixTime = [[self getTimeStrWithString:strArray1[0]] intValue];
            if (loc_unixTime > unixTime) {
                return 2;
            }else{
                //是老航线 需要更新
                //前久后新
                return 1;
            }
        }else{
            //前无后有
            //没有说明是新的航线
            return 0;
            
        }
}


//字符串转时间戳 如：2017-4-10 17:15:10
- (NSString *)getTimeStrWithString:(NSString *)str{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; //设定时间的格式
    NSDate *tempDate = [dateFormatter dateFromString:str];//将字符串转换为时间对象
    NSString *timeStr = [NSString stringWithFormat:@"%ld", (long)[tempDate timeIntervalSince1970]];//字符串转成时间戳,精确到毫秒*1000
    return timeStr;
}


/******************************
数组转成字符串 methods
 *****************************/
- (NSSet *) arrayStr:(NSMutableArray *) Ids{
    
    NSMutableArray * returnStr = [[NSMutableArray alloc] init];
    for (int i = 0; i < Ids.count; i++) {
        sqliteRoute * rtu = [Ids objectAtIndex:i];
        int Id = rtu.Id;
        [returnStr addObject:[NSString stringWithFormat:@"%d",Id]];
    }
    
    NSSet * set = [NSSet setWithArray:returnStr];
    return set;
    
    
}

/******************************
字典转成字符串 methods
 *****************************/
- (NSSet *) dicToStr:(NSDictionary *) Dic{
    NSMutableArray * listArry = [Dic objectForKey:@"list"];
        NSMutableArray * returnStr = [[NSMutableArray alloc] init];
    for (int i = 0; i < listArry.count; i++) {
        NSDictionary * dic = [listArry objectAtIndex:i];
        NSString * Id = [dic objectForKey:@"id"];
        [returnStr addObject:Id];
    }
    
    NSSet * resturnSet = [NSSet setWithArray:returnStr];
    return resturnSet;
    
}


/******************************
坐标字符串包装接包装 methods
 *****************************/
//POLYGON((112.275468762964 24.6979772018441, 112.277024444193 24.6974800837804, 112.277560885996 24.6979382122638, 112.27801149711 24.6974995786438, 112.278344091028 24.6969537213155, 112.278644498438 24.6961154357619, 112.2777110897 24.695462348922, 112.276520188898 24.6937662566619, 112.275243457407 24.6935323110901, 112.274524625391 24.6943706140229, 112.274288590997 24.6953161349813, 112.274953778833 24.6951699208691, 112.275490220636 24.6951114351762, 112.268200144172 24.6953551253823, 112.275554593652 24.6953746205782, 112.274835761636 24.6956378054242, 112.275967821479 24.6965638217596, 112.270388826728 24.6934640768822, 112.267663702369 24.6954915916895, 112.266612276435 24.6935030678627, 112.264509424567 24.6958035141162, 112.273221239448 24.6984158337825, 112.266612276435 24.6990591578318, 112.275275643915 24.6977335167666, 112.275468762964 24.6979772018441))
- (NSString *) pointxy2str:(NSMutableArray *)route_points{
    
    NSString * Loc_str = [[NSString alloc] init];
    
    for (int i = 0; i < route_points.count; i++) {
        CLLocation * location = [route_points objectAtIndex:i];
        CLLocationCoordinate2D new = [_locationChange WorldGS2MarsGS:location.coordinate];
        CLLocation* newlocation = [[CLLocation alloc] initWithLatitude:new.latitude longitude:new.longitude];
        if (i != route_points.count - 1) {
            Loc_str = [NSString stringWithFormat:@"%@%f %f, ",Loc_str,newlocation.coordinate.longitude,newlocation.coordinate.latitude];
        }else{
            //最后一次循环
            CLLocation * firstLoc = [route_points objectAtIndex:0];
            CLLocationCoordinate2D new1 = [_locationChange WorldGS2MarsGS:firstLoc.coordinate];
            firstLoc = [[CLLocation alloc] initWithLatitude:new1.latitude longitude:new1.longitude];
            
             Loc_str = [NSString stringWithFormat:@"POLYGON((%@%f %f, %f %f))",Loc_str,newlocation.coordinate.longitude,newlocation.coordinate.latitude,firstLoc.coordinate.longitude,firstLoc.coordinate.latitude];
        }
    }
    
    NSLog(@"Loc_str:%@",Loc_str);
    
    return Loc_str;
}

- (NSString *) sqlpointxy2str:(NSMutableArray *)route_points{
    
    NSString * Loc_str = [[NSString alloc] init];
    
    for (int i = 0; i < route_points.count; i++) {
        sqlitePoint * location = [route_points objectAtIndex:i];
        CLLocationCoordinate2D old = CLLocationCoordinate2DMake(location.point_x, location.point_y);
        CLLocationCoordinate2D new = [_locationChange WorldGS2MarsGS:old];
        location.point_x = new.latitude;
        location.point_y = new.longitude;
        if (i != route_points.count - 1) {
            Loc_str = [NSString stringWithFormat:@"%@%f %f, ",Loc_str,location.point_y,location.point_x];
        }else{
            //最后一次循环
            sqlitePoint * firstLoc = [route_points objectAtIndex:0];
            
            Loc_str = [NSString stringWithFormat:@"POLYGON((%@%f %f, %f %f))",Loc_str,location.point_y,location.point_x,firstLoc.point_y,firstLoc.point_x];
        }
    }
    
    NSLog(@"Loc_str:%@",Loc_str);
    
    return Loc_str;
}

- (NSMutableArray *) str2pointxy:(NSString *)loc_str{
    NSMutableArray * route_points = [[NSMutableArray alloc] init];
    
    //去掉逗号
    loc_str = [loc_str stringByReplacingOccurrencesOfString:@"," withString:@" "];
    //去掉首位
    loc_str = [loc_str substringFromIndex:9];
    loc_str = [loc_str stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    //按照空格分离
    NSArray *str_array = [loc_str componentsSeparatedByString:@" "];
    
    for (int i = 0; i < str_array.count; i++) {
        NSString * loc_x = [str_array objectAtIndex:i+1];
        NSString * loc_y = [str_array objectAtIndex:i];
        

        CLLocation * location = [[CLLocation alloc] initWithLatitude:[loc_x doubleValue] longitude:[loc_y doubleValue]];
        if (i != str_array.count - 2) {
            CLLocationCoordinate2D coor = [_locationChange MarsGS2WorldGS:location.coordinate];
            location = [[CLLocation alloc] initWithLatitude:coor.latitude longitude:coor.longitude];
            [route_points addObject:location];
            NSLog(@"---location---\n%f %f",location.coordinate.latitude,location.coordinate.longitude);
        }
        
        i = i + 1;
        
    }
    
    return route_points;
    
    
}





//无人机状态的更新
- (void) updateStateLabels{
    
    switch ([[self missionOperator] currentState]) {
        case DJIWaypointMissionStateUnknown:
            [_uvaState_lb setText:@"未知"];
            break;
        case DJIWaypointMissionStateExecuting:
            [_uvaState_lb setText:@"正在执行任务"];
            break;
        case DJIWaypointMissionStateUploading:
            [_uvaState_lb setText:@"任务正在上传"];
            break;
        case DJIWaypointMissionStateRecovering:
            [_uvaState_lb setText:@"连接正在恢复"];
            break;
        case DJIWaypointMissionStateDisconnected:
            [_uvaState_lb setText:@"失去连接"];
            break;
        case DJIWaypointMissionStateNotSupported:
            [_uvaState_lb setText:@"连接不支持"];
            break;
        case DJIWaypointMissionStateReadyToUpload:
            [_uvaState_lb setText:@"准备上传"];
            break;
        case DJIWaypointMissionStateReadyToExecute:
            [_uvaState_lb setText:@"准备执行"];
            break;
        case DJIWaypointMissionStateExecutionPaused:
            [_uvaState_lb setText:@"任务暂停"];
            break;
            
        default:
            break;
    }
    
}


//update 下方的标签
- (void) updateDibuLabels{
    NSMutableDictionary *usernamepasswordKVPairs1 = (NSMutableDictionary *)[ZZCKeychain load:KEY_RTECHGO];
    NSString * zzdateunix = [usernamepasswordKVPairs1 objectForKey:KEY_ZZDATE];
    NSString * zzdate = [ZZCJIami unix_timeback:[zzdateunix intValue]];

    [_userName_lb setText:[NSString stringWithFormat:@"用户名:%@",_zzcUser.userName]];
    [_company_lb setText:[NSString stringWithFormat:@"单位:%@",_zzcUser.company]];
    [_zzDate_lb setText: [NSString stringWithFormat:@"试用期:%@",zzdate]];
    
    
    if (self.product) {
        [_uvaType_lb setText:[NSString stringWithFormat:@"机型:%@",self.product.model]];
        [self updateStateLabels];
    }else{
        
        [_uvaType_lb setText:[NSString stringWithFormat:@"机型:未知"]];
        [_uvaState_lb setText:[NSString stringWithFormat:@"状态:未连接"]];
    }
    

    
    
    switch (_mode) {
        case ZZCRouteMode_qinxie:
            [_flightMode_lab setText:@"模式:倾斜飞"];
            break;
        case ZZCRouteMode_quanjin:
            [_flightMode_lab setText:@"模式:全景飞"];
            break;
        case ZZCRouteMode_tiaodai:
            [_flightMode_lab setText:@"模式:条带飞"];
            break;
        case ZZCRouteMode_huanxing:
            [_flightMode_lab setText:@"模式:环绕飞"];
            break;
            
        default:
            break;
    }
    
    
}

//生产tile
-(MKTileOverlay *) mapTileOverlay{
    
    
    
    MKTileOverlay * tile = [[MKTileOverlay alloc] initWithURLTemplate:@"http://mt0.google.cn/maps/vt?lyrs=s@773&gl=cn&x={x}&y={y}&z={z}"];
    
    tile.minimumZ = 3;
    tile.maximumZ = 30;
    tile.canReplaceMapContent = YES;
    //tile.boundingMapRect = MAMapRectWorld;
    

    
    return tile;
    
}

///这里写一个断点续费关于beginindex重新计算的问题
-(int) newBeginIndex:(sqliteRoute*) route pointNum:(int)pointNum{
    
    if (route.currentIndex == -1 ) {
        return route.beginIndex;
    }
    
    if (route.currentIndex < (pointNum - route.beginIndex)) {
        return route.beginIndex;
    }else if(route.currentIndex == (pointNum - route.beginIndex)){
        
        return (route.beginIndex - 1);
    }else{
        
        return (pointNum - route.currentIndex -1);
    }
    
}

///这里写一个关于断点续费 出发点的函数
/// 0不代表新点
- (int) isOldPoint:(sqliteRoute*) route index : (int) index pointNum:(int)pointNum{
    
    
    //这是一条还没有飞过的航线
    if (route.currentIndex == -1) {
        return -1;
    }
    
    
    //这里计算几个有用的数据
    int assPointsNum = pointNum - route.beginIndex - 1;//从beginIndex往后还有几个点
    
    if (route.currentIndex > assPointsNum) {
        int mouthpointsNum = route.currentIndex - assPointsNum;//从beginindex往前飞过了几个点
        if (index <= (route.beginIndex - mouthpointsNum)) {
            return 1;
        }else{
            
            return 0;
        }
    }else{
        
        if (index >= (route.beginIndex + route.currentIndex)) {
            return 2;
        }else if(index < route.beginIndex){
            
            return 1;
        }else{
            
            return 0;
        }
    }
    
    
    
}

///这里包一个删除线的方法
- (void) deleteLines{

    if (_yunDPolyLine1 != nil) {
        [_mapView removeOverlay:_yunDPolyLine1];
        [_dync_Points1 removeAllObjects];
    }
    
    if (_q_yunDPolyLine1 != nil) {
        [_mapView removeOverlay:_q_yunDPolyLine1];
        [_q_dync_Points1 removeAllObjects];
    }
    if (_q_yunDPolyLine2 != nil) {
        [_mapView removeOverlay:_q_yunDPolyLine2];
        [_q_dync_Points2 removeAllObjects];
    }
    if (_q_yunDPolyLine3 != nil) {
        [_mapView removeOverlay:_q_yunDPolyLine3];
        [_q_dync_Points3 removeAllObjects];
    }
    if (_q_yunDPolyLine4 != nil) {
        [_mapView removeOverlay:_q_yunDPolyLine4];
        [_q_dync_Points4 removeAllObjects];
    }
    
    
}

//这里实现判断一个针对单航线动态绘制的方法
- (int) dyncPolyLine:(int) beginIndex nextIndex:(int) nextIndex pointCount:(int)pointCount{

    //第一段需要划线的
    if (nextIndex >= (pointCount - beginIndex)) {
        return 2;
    }else if (nextIndex >= 0 && nextIndex < (pointCount - beginIndex)){
    //第二段航线需要绘制的
        return 1;
    
    }else{
    //别绘制了
        return 0;
        
    }

}

//这里实现判断一个针对多航线动态绘制的方法
- (int) q_dyncPolyLine:(int) beginIndex nextIndex:(int) nextIndex pointCount:(int)pointCount{
    
    int q_pointCount = pointCount/4;
    int q_beginIndex = beginIndex % q_pointCount;
    
    int q_session = beginIndex/q_pointCount;
    
    switch (q_session) {
        case 0:
            {
                //第一段需要划线的
                if (nextIndex >= (pointCount - beginIndex) && (pointCount - beginIndex + q_beginIndex) > nextIndex) {
                    return -1;
                }else if (nextIndex >= 0 && nextIndex < (q_pointCount - q_beginIndex)){
                    //第二段航线需要绘制的
                    return 1;
                    
                }else if ((q_pointCount - q_beginIndex) <= nextIndex && nextIndex < (2*q_pointCount - q_beginIndex)){
                    return 2;
                }else if ((2*q_pointCount - q_beginIndex) <= nextIndex && nextIndex < (3*q_pointCount - q_beginIndex)){
                    return 3;
                }else if ((3*q_pointCount - q_beginIndex) <= nextIndex && nextIndex < (4*q_pointCount - q_beginIndex)){
                    return 4;
                }else{
                    //别绘制了
                    return 0;
                    
                }
            }
            break;
        case 1:
            {
                //第一段需要划线的
                if (nextIndex >= (pointCount - beginIndex) && (pointCount - beginIndex + q_beginIndex) > nextIndex) {
                    return -1;
                }else if (nextIndex >= 0 && nextIndex < (q_pointCount - q_beginIndex)){
                    //第二段航线需要绘制的
                    return 1;
                    
                }else if ((q_pointCount - q_beginIndex) <= nextIndex && nextIndex < (2*q_pointCount - q_beginIndex)){
                    return 2;
                }else if ((2*q_pointCount - q_beginIndex) <= nextIndex && nextIndex < (3*q_pointCount - q_beginIndex)){
                    return 3;
                }else if ((pointCount - beginIndex + q_beginIndex) <= nextIndex && nextIndex < (pointCount - beginIndex + q_beginIndex + q_pointCount)){
                    return 4;
                }else{
                    //别绘制了
                    return 0;
                    
                }
            }
            break;
        case 2:
            {
                //第一段需要划线的
                if (nextIndex >= (pointCount - beginIndex) && (pointCount - beginIndex + q_beginIndex) > nextIndex) {
                    return -1;
                }else if (nextIndex >= 0 && nextIndex < (q_pointCount - q_beginIndex)){
                    //第二段航线需要绘制的
                    return 1;
                    
                }else if ((q_pointCount - q_beginIndex) <= nextIndex && nextIndex < (2*q_pointCount - q_beginIndex)){
                    return 2;
                }else if ((pointCount - beginIndex + q_beginIndex) <= nextIndex && nextIndex < (pointCount - beginIndex + q_beginIndex + q_pointCount)){
                    return 3;
                }else if ((pointCount - beginIndex + q_beginIndex + q_pointCount) <= nextIndex && nextIndex < (pointCount - beginIndex + q_beginIndex + 2*q_pointCount)){
                    return 4;
                }else{
                    //别绘制了
                    return 0;
                    
                }
            }
            break;
        case 3:
        { //第一段需要划线的
            if (nextIndex >= (pointCount - beginIndex) && (pointCount - beginIndex + q_beginIndex) > nextIndex) {
                return -1;
            }else if (nextIndex >= 0 && nextIndex < (q_pointCount - q_beginIndex)){
                //第二段航线需要绘制的
                return 1;
                
            }else if ((pointCount - beginIndex + q_beginIndex) <= nextIndex && nextIndex < (pointCount - beginIndex + q_beginIndex + q_pointCount)){
                return 2;
            }else if ((pointCount - beginIndex + q_beginIndex + q_pointCount) <= nextIndex && nextIndex < (pointCount - beginIndex + q_beginIndex + 2*q_pointCount)){
                return 3;
            }else if ((pointCount - beginIndex + q_beginIndex + 2*q_pointCount) <= nextIndex && nextIndex < (pointCount - beginIndex + q_beginIndex + 3*q_pointCount)){
                return 4;
            }else{
                //别绘制了
                return 0;
                
            }
            
        }
            break;
            
        default:
            return 0;
            break;
    }
    
    
    
   
    
}


- (void) lowBetterySync{

    [self showAlertViewWithTitle:@"状态弹窗！" withMessage: @"低电量同步按钮已点击！"];
    
    //这个地方需要检测一下上一次的任务执行完了没有-loadedmission
    //由于程序切换也会导致重新连接 那么这里需要进行飞行器状态的判断
    if (_lowBettery == YES) {
        //先移除所有的这个航点
        [_waypointMission removeAllWaypoints];
        
        [self showAlertViewWithTitle:@"状态弹窗！" withMessage: @"确实没电了，原任务点已经全部删除！"];
        
        
        
        for (int i = 0; i < _loadpointMission.waypointCount; i++) {
            
            DJIWaypoint* waypoint = [_loadpointMission.allWaypoints objectAtIndex:i];
            [_waypointMission addWaypoint:waypoint];
            
        }
        
        if (_waypointMission.waypointCount>0) {
            //原地复活又是一条好汉！
            [[self missionOperator] loadMission:_waypointMission];
            
            
            [[self missionOperator] uploadMissionWithCompletion:^(NSError * _Nullable error) {
                if (error){
                    NSString* uploadError = [NSString stringWithFormat:@"上传上次任务失败！:%@", error.description];
                    ShowMessage(@"", uploadError, nil, @"OK");
                }else {
                    ShowMessage(@"", @"监测到上次任务，继续请点击开始任务！", nil, @"OK");
                }
            }];
        }
        
        
        
    }

}


-(int) angleChange:(int)angle{

    if (angle>=0&&angle<=180) {
        angle = angle;
    }else{
    
        angle = angle - 360;
    
    }
    
    return angle;


}



- (DJICamera*) fetchCamera {
    
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).camera;
    }else if ([[DJISDKManager product] isKindOfClass:[DJIHandheld class]]){
        return ((DJIHandheld *)[DJISDKManager product]).camera;
    }
    
    return nil;
}

- (void)showAlertViewWithTitle:(NSString *)title withMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSMutableArray *)sort_route:(NSMutableArray *)mission_array begin_index:(int)begin_index{

    NSMutableArray * result_array = [[NSMutableArray alloc] init];
    for (int i = begin_index; i < mission_array.count; i++) {
        DJIWaypoint * waypoint = [mission_array objectAtIndex:i];
        [result_array addObject:waypoint];
    }
    
    for (int i = begin_index - 1; i >=0; i--) {
        DJIWaypoint * waypoint = [mission_array objectAtIndex:i];
        [result_array addObject:waypoint];
    }


    return result_array;
}


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


//创建表格
- (void)createTable {
    //1.准备sqlite语句
    NSString *sqlite3 = [NSString stringWithFormat:@"create table if not exists 'map_table' ('id' integer primary key autoincrement not null,'name' text,'time' text,'statuscode' integer,'url' text,'coor1' double,'coor2' double)"];
    
    //1.准备sqlite语句
    NSString *sqlite2 = [NSString stringWithFormat:@"create table if not exists 'user_table' ('id' integer primary key autoincrement not null,'company' text,'phonebNum' text,'password' text,'userName' text)"];
    
    //1.准备sqlite语句
    NSString *sqlite = [NSString stringWithFormat:@"create table if not exists 'tiaodai_route' ('id' integer primary key autoincrement not null,'user_id' integer,'time' text,'inittime' text,'type' integer,'currentIndex' integer,'height' double,'l_height' double,'beginIndex' integer,'hxChongdie' float,'pxChongdie' float,'angle' int,'pointCount' int,'deleteOrnot' int,'route_name' text,'qinxieAngle' int,FOREIGN KEY(user_id) REFERENCES user_table(id) )"];
    
    //1.准备sqlite语句
    NSString *sqlite1 = [NSString stringWithFormat:@"create table if not exists 'final_points' ('id' integer primary key autoincrement not null,'route_id' integer,'point_index' integer,'point_x' double,'point_y' double,FOREIGN KEY(route_id) REFERENCES tiaodai_route(id) )"];
    //2.执行sqlite语句
    char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    char *error1 = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    char *error2 = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    char *error3 = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result3 = sqlite3_exec(_routeDB, [sqlite3 UTF8String], nil, nil, &error3);
    int result2 = sqlite3_exec(_routeDB, [sqlite2 UTF8String], nil, nil, &error2);
    int result = sqlite3_exec(_routeDB, [sqlite UTF8String], nil, nil, &error);
    int result1 = sqlite3_exec(_routeDB, [sqlite1 UTF8String], nil, nil, &error1);
    
    //3.sqlite语句是否执行成功
    
    if (result3 == SQLITE_OK) {
        NSLog(@"创建地图表成功");
    } else {
        NSLog(@"创建地图表失败");
    }
    
    if (result2 == SQLITE_OK) {
        NSLog(@"创建用户表成功");
    } else {
        NSLog(@"创建用户表失败");
    }
    
    if (result == SQLITE_OK) {
        NSLog(@"创建航线表表成功");
    } else {
        NSLog(@"创建航线表失败");
    }
    
    if (result1 == SQLITE_OK) {
        NSLog(@"创建航点表成功");
    } else {
        NSLog(@"创建航点表失败");
    }
}
//添加一个新地图应该怎么加
- (void)addLocalMap:(LocalMap *)localmap{
    NSString * sqlite = [NSString stringWithFormat:@"insert into map_table(id,name,time,url,statuscode,coor1,coor2) values (NULL,'%@','%@','%@','%d','%f','%f')",localmap.name,localmap.time,localmap.url,localmap.statuscode,localmap.coor.latitude,localmap.coor.longitude];
    //2.执行sqlite语句
    char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result = sqlite3_exec(_routeDB, [sqlite UTF8String], nil, nil, &error);
    if (result == SQLITE_OK) {
        NSLog(@"添加数据至离线地图表成功");
    } else {
        NSLog(@"添加数据至离线地图表失败");
    }
    
    _map_Array = [self selectLocalMap];
    [_mapTableView reloadData];
    
}

//删除一个新地图应该怎么删
- (void)deleteLocalMap:(LocalMap *)localmap{
    //1.准备sqlite语句
    NSString *sqlite = [NSString stringWithFormat:@"delete from map_table where id = '%d'",localmap.Id];
    //2.执行sqlite语句
    char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result = sqlite3_exec(_routeDB, [sqlite UTF8String], nil, nil, &error);
    if (result == SQLITE_OK) {
        NSLog(@"删除离线地图数据成功");
    } else {
        NSLog(@"删除离线地图数据失败%s",error);
    }
    
    _map_Array = [self selectLocalMap];
    [_mapTableView reloadData];
    
}

- (NSMutableArray *)selectLocalMap{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    //1.准备sqlite语句
    NSString *sqlite ;
    
    sqlite = [NSString stringWithFormat:@"select * from map_table"];
    //2.伴随指针
    sqlite3_stmt *stmt = NULL;
    //3.预执行sqlite语句
    int result = sqlite3_prepare(_routeDB, sqlite.UTF8String, -1, &stmt, NULL);//第4个参数是一次性返回所有的参数,就用-1
    if (result == SQLITE_OK) {
        
        //4.执行n次
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            NSLog(@"离线地图查询成功");
            LocalMap *map = [[LocalMap alloc] init];
            //从伴随指针获取数据,第0列
            map.Id = sqlite3_column_int(stmt, 0);
            //从伴随指针获取数据,第1列
            map.name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)] ;
            //从伴随指针获取数据,第2列
            map.time = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)] ;
            //从伴随指针获取数据,第3列
            map.statuscode = sqlite3_column_int(stmt, 3);
            //从伴随指针获取数据,第4列
            map.url = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)] ;
            //从伴随指针获取数据,第5列
            double coor1 = sqlite3_column_double(stmt, 5);
            //从伴随指针获取数据,第6列
            double coor2 = sqlite3_column_double(stmt, 6);
            map.coor = CLLocationCoordinate2DMake(coor1, coor2);
            [array addObject:map];
        }
    } else {
        NSLog(@"查询失败");
    }
    
    return array;
}

//更新一个新地图应该怎么更新
- (void) updateLocalMap:(LocalMap *)localMap{
    
    //1.sqlite语句
    NSString *sqlite1 = [NSString stringWithFormat:@"update map_table set id = '%d',statuscode = '%d',time = '%@',name = '%@',url = '%@',coor1 = '%f',coor2 = '%f' where id = '%d'",localMap.Id,localMap.statuscode,[DJIRootViewController getCurrentTimes],localMap.name,localMap.url,localMap.coor.latitude,localMap.coor.longitude,localMap.Id];
    
    
    //2.执行sqlite语句
    char *error1 = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result1 = sqlite3_exec(_routeDB, [sqlite1 UTF8String], nil, nil, &error1);
    if (result1 == SQLITE_OK) {
        NSLog(@"修改离线地图数据成功");
    } else {
        NSLog(@"修改离线地图数据失败%s",error1);
    }
    
    
    _map_Array = [self selectLocalMap];
    [_mapTableView reloadData];
    
}



//添加本地数据
- (void)addLocalRoute:(NSMutableArray *)route_points Id:(int)Id reviseTime:(NSString *)reviseTime route_name:(NSString *)route_name initTime:(NSString *)initTime{
    
    //??????????????//这里ID == -1001时候代表没有网络 后台请求失败  不想新写一个函数体 偷懒

    
    
    if ([reviseTime isEqualToString:@""]) {
        route_name = @"无名称";
        initTime = [DJIRootViewController getCurrentTimes];
        reviseTime = [DJIRootViewController getCurrentTimes];
    }
    
    if (route_name == nil) {
        route_name = @"无名称";
    }
    
    /**************************************
     **************本地数据同步开始**************
     **************************************/
    
    //记录最后插入的一条数据的id
    int newid = 0;
    
    NSString * sqlite;
    switch (_mode) {
        case ZZCRouteMode_tiaodai:
            if (Id == -1001) {
                sqlite = [NSString stringWithFormat:@"insert into tiaodai_route(id,user_id,time,inittime,type,currentIndex,height,l_height,beginIndex,hxChongdie,pxChongdie,angle,pointCount,deleteOrnot,route_name,qinxieAngle) values (NULL,'%d','%@','%@','%d','%d','%f','%f','%d','%f','%f','%d','%d','%d','%@','%d')",_zzcUser.Id,reviseTime,initTime,0,-1,110.0,0.0,0,0.8,0.6,60,0,0,route_name,90];
            }else{
            //1.准备sqlite语句 缺省currentIndex为0 最低高度为0 最大高度为110
            sqlite = [NSString stringWithFormat:@"insert into tiaodai_route(id,user_id,time,inittime,type,currentIndex,height,l_height,beginIndex,hxChongdie,pxChongdie,angle,pointCount,deleteOrnot,route_name,qinxieAngle) values ('%d','%d','%@','%@','%d','%d','%f','%f','%d','%f','%f','%d','%d','%d','%@','%d')",Id,_zzcUser.Id,reviseTime,initTime,0,-1,110.0,0.0,0,0.8,0.6,60,0,0,route_name,90];
            }
            break;
        case ZZCRouteMode_huanxing:
            
            if (Id == -1001) {
                sqlite = [NSString stringWithFormat:@"insert into tiaodai_route(id,user_id,time,inittime,type,currentIndex,height,l_height,beginIndex,hxChongdie,pxChongdie,angle,pointCount,deleteOrnot,route_name,qinxieAngle) values (NULL,'%d','%@','%@','%d','%d','%f','%f','%d','%f','%f','%d','%d','%d','%@','%d')",_zzcUser.Id,reviseTime,initTime,1,-1,100.0,10.0,0,0.8,0.6,60,0,0,route_name,0];
            }else{
            //1.准备sqlite语句
            sqlite = [NSString stringWithFormat:@"insert into tiaodai_route(id,user_id,time,inittime,type,currentIndex,height,l_height,beginIndex,hxChongdie,pxChongdie,angle,pointCount,deleteOrnot,route_name,qinxieAngle) values ('%d','%d','%@','%@','%d','%d','%f','%f','%d','%f','%f','%d','%d','%d','%@','%d')",Id,_zzcUser.Id,reviseTime,initTime,1,-1,100.0,10.0,0,0.8,0.6,60,0,0,route_name,0];
            }
            break;
        case ZZCRouteMode_qinxie:
            if (Id == -1001) {
                //1.准备sqlite语句
                sqlite = [NSString stringWithFormat:@"insert into tiaodai_route(id,user_id,time,inittime,type,currentIndex,height,l_height,beginIndex,hxChongdie,pxChongdie,angle,pointCount,deleteOrnot,route_name,qinxieAngle) values (NULL,'%d','%@','%@','%d','%d','%f','%f','%d','%f','%f','%d','%d','%d','%@','%d')",_zzcUser.Id,reviseTime,initTime,2,-1,110.0,0.0,0,0.8,0.6,60,0,0,route_name,45];
            }else{
            //1.准备sqlite语句
            sqlite = [NSString stringWithFormat:@"insert into tiaodai_route(id,user_id,time,inittime,type,currentIndex,height,l_height,beginIndex,hxChongdie,pxChongdie,angle,pointCount,deleteOrnot,route_name,qinxieAngle) values ('%d','%d','%@','%@','%d','%d','%f','%f','%d','%f','%f','%d','%d','%d','%@','%d')",Id,_zzcUser.Id,reviseTime,initTime,2,-1,110.0,0.0,0,0.8,0.6,60,0,0,route_name,45];
            }
            break;
        case ZZCRouteMode_quanjin:
            if (Id == -1001) {
                //1.准备sqlite语句
                sqlite = [NSString stringWithFormat:@"insert into tiaodai_route(id,user_id,time,inittime,type,currentIndex,height,l_height,beginIndex,hxChongdie,pxChongdie,angle,pointCount,deleteOrnot,route_name,qinxieAngle) values (NULL,'%d','%@','%@','%d','%d','%f','%f','%d','%f','%f','%d','%d','%d','%@','%d')",_zzcUser.Id,reviseTime,initTime,3,-1,50.0,0.0,0,0.8,0.6,60,0,0,route_name,0];
            }else{
            //1.准备sqlite语句
            sqlite = [NSString stringWithFormat:@"insert into tiaodai_route(id,user_id,time,inittime,type,currentIndex,height,l_height,beginIndex,hxChongdie,pxChongdie,angle,pointCount,deleteOrnot,route_name,qinxieAngle) values ('%d','%d','%@','%@','%d','%d','%f','%f','%d','%f','%f','%d','%d','%d','%@','%d')",Id,_zzcUser.Id,reviseTime,initTime,3,-1,50.0,0.0,0,0.8,0.6,60,0,0,route_name,0];
            }
            break;
            
        default:
            break;
    }
    
    //2.执行sqlite语句
    char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result = sqlite3_exec(_routeDB, [sqlite UTF8String], nil, nil, &error);
    if (result == SQLITE_OK) {
        NSLog(@"添加数据至航线表成功");
        newid = (int)sqlite3_last_insert_rowid(_routeDB);
        NSLog(@"newid:%d",newid);
    } else {
        NSLog(@"添加数据至航线表失败");
    }
    
    for (int i = 0; i < route_points.count; i++) {
        CLLocation * location = [route_points objectAtIndex:i];
        NSString *sqlite1 = [NSString stringWithFormat:@"insert into final_points(id,route_id,point_index,point_x,point_y) values (NULL,'%d','%d','%f','%f')",newid,i,location.coordinate.latitude,location.coordinate.longitude];
        char *error1 = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
        int result = sqlite3_exec(_routeDB, [sqlite1 UTF8String], nil, nil, &error1);
        if (result == SQLITE_OK) {
            NSLog(@"添加数据至航点表成功");
        } else {
            NSLog(@"添加数据至航点表失败%s",error1);
        }
    }
    _route_Array = [self selectWithRtu];
    [_taskTableView reloadData];
    
    /**************************************
     **************本地数据同步结束**************
     **************************************/
    
}

//添加网络数据
- (void)addRoute:(NSMutableArray *)route_points {

    /**************************************
     **************网络数据同步**************
     **************************************/
    
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置不做处理
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //2.封装参数
    NSString * timeNow = [DJIRootViewController getCurrentTimes];
    NSString * uri = @"http://120.55.62.229:38008/maven_test/KmlShpInfo/add";
    NSDictionary *register_dict = @{
                                    @"kmlName":@"无名称",
                                    @"kmlShpXy":[self pointxy2str:route_points],
                                    @"kmlShpZ":@"110",
                                    @"kmlTime":timeNow,
                                    @"statusCode":@"0",
                                    @"userId":_zzcUser.phoneNum,
                                    @"reviseTime":timeNow,
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
            
            NSDictionary * resultDic = [zzcAFN dictionaryWithJsonString:encodeStr];
            NSString * statusCode = [resultDic objectForKey:@"status"];
            if ([statusCode  isEqual: @"404"]) {
                NSLog(@"后台添加航线失败");
            }else{
                
                NSLog(@"后台添加航线成功");
                NSString * Id = [resultDic objectForKey:@"id"];
                
                [self addLocalRoute:route_points Id:[Id intValue] reviseTime:timeNow route_name:@"无名称" initTime:timeNow];
                _route_Array = [self selectWithRtu];
                
                sqliteRoute* route = [_route_Array objectAtIndex:_route_Array.count - 1];
                
                _mapController.route = route;

                
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            ShowResult(@"网络请求失败！");
            NSLog(@"failure--%@",error);
        }];

    
    
    
    
}

//删除本地数据
- (void)deleteLocalRtu:(sqliteRoute *)rtu{
    
    //1.准备sqlite语句
    NSString *sqlite = [NSString stringWithFormat:@"delete from tiaodai_route where id = '%d'",rtu.Id];
    //2.执行sqlite语句
    char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result = sqlite3_exec(_routeDB, [sqlite UTF8String], nil, nil, &error);
    if (result == SQLITE_OK) {
        NSLog(@"删除航线数据成功");
    } else {
        NSLog(@"删除航线数据失败%s",error);
    }
    
    NSString *sqlite1 = [NSString stringWithFormat:@"delete from final_points where route_id = '%d'",rtu.Id];
    char *error1 = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result1 = sqlite3_exec(_routeDB, [sqlite1 UTF8String], nil, nil, &error1);
    if (result1 == SQLITE_OK) {
        NSLog(@"删除航点数据成功");
    } else {
        NSLog(@"删除航点数据失败%s",error1);
    }
    
    _route_Array = [self selectWithRtu];
    [_taskTableView reloadData];
    
}

//假删除本地数据
- (void)ZJLdeleteLocalRtu:(sqliteRoute *)rtu{
    
    //1.sqlite语句
    NSString *sqlite1 = [NSString stringWithFormat:@"update tiaodai_route set deleteOrnot = '%d' where id = '%d'",1,rtu.Id];
    //2.执行sqlite语句
    char *error1 = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result1 = sqlite3_exec(_routeDB, [sqlite1 UTF8String], nil, nil, &error1);
    if (result1 == SQLITE_OK) {
        NSLog(@"ZJL删除航线数据成功");
    } else {
        NSLog(@"ZJL删除航线数据失败");
    }

    
    [_mapController cleanAllPointsWithMapView:_mapView];
    [_routePlan cleanAllPointsWithMapView:_mapView];
    [self deleteLines];
    
    _route_Array = [self selectWithRtu];
    [_taskTableView reloadData];
    _mapController.route = nil;
    
    
    
}

//查询网络数据更新时间并删除本地已经删除的航线 返回所有存在的航线数据（ID revisetime）
- (void)compareRtu{
    
    //先把本地元已经删除的这些航线的id数组查询出来 然后再来进行网络查询删除已删除 求取所有集合
    NSMutableArray *array = [[NSMutableArray alloc] init];
    //1.准备sqlite语句
    NSString *sqlite ;
    
    switch (_mode) {
        case ZZCRouteMode_tiaodai:
            sqlite = [NSString stringWithFormat:@"select * from tiaodai_route where type = %d and user_id = %d and deleteOrnot = %d",0,_zzcUser.Id,1];
            break;
        case ZZCRouteMode_huanxing:
            sqlite = [NSString stringWithFormat:@"select * from tiaodai_route where type = %d  and user_id = %d and deleteOrnot = %d",1,_zzcUser.Id,1];
            break;
        case ZZCRouteMode_qinxie:
            sqlite = [NSString stringWithFormat:@"select * from tiaodai_route where type = %d and user_id = %d and deleteOrnot = %d",2,_zzcUser.Id,1];
            break;
        case ZZCRouteMode_quanjin:
            sqlite = [NSString stringWithFormat:@"select * from tiaodai_route where type = %d and user_id = %d and deleteOrnot = %d",3,_zzcUser.Id,1];
            break;
            
        default:
            break;
    }
    //2.伴随指针
    sqlite3_stmt *stmt = NULL;
    //3.预执行sqlite语句
    int result = sqlite3_prepare(_routeDB, sqlite.UTF8String, -1, &stmt, NULL);//第4个参数是一次性返回所有的参数,就用-1
    if (result == SQLITE_OK) {
        //4.执行n次
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            NSLog(@"ZJL航线查询成功");
            //从伴随指针获取数据,第0列
            sqliteRoute * rtu = [[sqliteRoute alloc] init];
           rtu.Id = sqlite3_column_int(stmt, 0);
            [array addObject:rtu];
        }
    }else{
        
        NSLog(@"查询失败！");
    }
    

    
    /**************************************
     **************网络数据同步**************
     **************************************/
    
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置不做处理
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //2.封装参数
    NSSet *Arrayset = [self arrayStr:array];
    NSString * uri = @"http://120.55.62.229:38008/maven_test/KmlShpInfo/getIdAndReviseTime";
    NSDictionary *register_dict = @{
                                    @"ids":Arrayset,
                                    @"userId":_zzcUser.phoneNum,
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
        
        NSDictionary * resultDic = [zzcAFN dictionaryWithJsonString:encodeStr];
        if (resultDic == nil) {
            NSLog(@"Compare查询失败");
        }else{
            
            NSLog(@"Compare查询成功");
            //吧假删除的航线也删除
            for (int i  =0 ; i < array.count; i++) {
                sqliteRoute * rtu = [array objectAtIndex:i];
                [self deleteLocalRtu:rtu];
            }
            //把后台偷偷删除的数据也在本地删了
            [self loc_sync_delete:resultDic route_Array:_route_Array];
            /****************************************
             查询id成功了之后就把这些对应的坐标也获取出来
             ****************************************/
            
            
            //1.创建会话管理者
            AFHTTPSessionManager *manager1 = [AFHTTPSessionManager manager];
            //设置不做处理
            //manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
            NSSet * select_str = [self dicToStr:resultDic];
            NSString * uri1 = @"http://120.55.62.229:38008/maven_test/KmlShpInfo/getServiceData";
            NSDictionary *select_dict = @{
                                            @"ids":select_str,
                                            @"userId":_zzcUser.phoneNum,
                                            @"type":@"JSON"
                                            };
            
            [manager1 GET:uri1 parameters:select_dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject1) {
                NSLog(@"success--%@--%@",[responseObject1 class],responseObject1);
                
                NSDictionary * zesultDic = responseObject1;
                if (zesultDic != nil) {
                    NSLog(@"获取后台数据成功");
                    NSMutableArray * zlistArray = [zesultDic objectForKey:@"list"];
                    for (int i = 0; i < zlistArray.count; i++) {
                        NSDictionary * dic = [zlistArray objectAtIndex:i];
                        if ([self syncSqlite:dic]==0) {
                            NSString * kmlShpXy = [dic objectForKey:@"kmlShpXy"];
                            NSMutableArray * locations = [self str2pointxy:kmlShpXy];
                            NSString* reviseTime = [dic objectForKey:@"reviseTime"];
                            NSString* route_name = [dic objectForKey:@"kmlName"];
                            NSString* initTime = [dic objectForKey:@"kmlTime"];
                            [self addLocalRoute:locations Id:[[dic objectForKey:@"id"] intValue] reviseTime:reviseTime route_name:route_name initTime:initTime];
                        }else if([self syncSqlite:dic]==1){
                            sqliteRoute * rtu =  [self selectWithId:[[dic objectForKey:@"id"] intValue]];
                            NSString * kmlShpXy = [dic objectForKey:@"kmlShpXy"];
                            NSMutableArray * locations = [self str2pointxy:kmlShpXy];
                            [self deleteLocalRtu:rtu];
                            NSString* reviseTime = [dic objectForKey:@"reviseTime"];
                            NSString* route_name = [dic objectForKey:@"kmlName"];
                            NSString* initTime = [dic objectForKey:@"kmlTime"];
                            [self addLocalRoute:locations Id:[[dic objectForKey:@"id"] intValue] reviseTime:reviseTime route_name:route_name initTime:initTime];
                            
                        }else{
                            sqliteRoute * rtu  = [self selectWithId:[[dic objectForKey:@"id"] intValue]];
                            //需要更新到后台
                            [self updateAFNroute:rtu];
                        }
                    }
                    
                    //试图更新
                    [_mapController cleanAllPointsWithMapView:_mapView];
                    [_routePlan cleanAllPointsWithMapView:_mapView];
                    [self deleteLines];
                    _mapController.route = nil;
                    ShowResult(@"数据同步成功!");
                    
                }else{
                    
                    NSLog(@"获取后台数据失败！");
                }
                
                
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                ShowResult(@"网络请求失败！");
                NSLog(@"failure--%@",error);
            }];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        ShowResult(@"网络请求失败！");
        NSLog(@"failure--%@",error);
    }];
}


//修改后台网络数据
- (void) updateAFNroute:(sqliteRoute *)rtu{
    
    
    /**************************************
     **************网络数据同步**************
     **************************************/
    
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置不做处理
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //2.封装参数
    
    //rtu.time = [DJIRootViewController getCurrentTimes];
    NSString * uri = @"http://120.55.62.229:38008/maven_test/KmlShpInfo/update";
    NSDictionary *register_dict = @{
                                    @"id":[NSString stringWithFormat:@"%d",rtu.Id],
                                    @"kmlName":rtu.route_name,
                                    @"kmlShpXy":[self sqlpointxy2str:rtu.point_array],
                                    @"kmlShpZ":[NSString stringWithFormat:@"%f",rtu.height],
                                    @"kmlTime":rtu.inittime,
                                    @"statusCode":@"0",
                                    @"userId":_zzcUser.phoneNum,
                                    @"reviseTime":rtu.time,
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
        
        NSDictionary * resultDic = [zzcAFN dictionaryWithJsonString:encodeStr];
        NSString * statusCode = [resultDic objectForKey:@"status"];
        if ([statusCode  isEqual: @"404"]) {
            NSLog(@"后台修改航线失败");
        }else{
            
            NSLog(@"后台修改航线成功");

            //本地数据库做相应的修改
            //[self updateWithRoute:rtu];
            //[self updataWithStu:rtu];
            
            _route_Array = [self selectWithRtu];
            [_taskTableView reloadData];

        }
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        ShowResult(@"网络请求失败！");
        NSLog(@"failure--%@",error);
    }];
    
    
}

//修改航线表数据
- (void)updateWithRoute:(sqliteRoute *)rtu{
    //1.sqlite语句
    NSString *sqlite1 = [NSString stringWithFormat:@"update tiaodai_route set id = '%d',user_id = '%d',type = '%d',currentIndex = '%d',time = '%@',height = '%f',l_height = '%f',beginIndex = '%d',hxChongdie = '%f',pxChongdie = '%f',angle = '%d',pointCount = '%d',route_name = '%@',qinxieAngle = '%d' where id = '%d'",rtu.Id,_zzcUser.Id,rtu.type,rtu.currentIndex,rtu.time,rtu.height,rtu.l_height,rtu.beginIndex,rtu.hxChongdie,rtu.pxChongdie,rtu.angle,rtu.pointCount,rtu.route_name,rtu.qinxieAngle,rtu.Id];
    
    
    //2.执行sqlite语句
    char *error1 = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
    int result1 = sqlite3_exec(_routeDB, [sqlite1 UTF8String], nil, nil, &error1);
    if (result1 == SQLITE_OK) {
        NSLog(@"修改航线数据成功");
    } else {
        NSLog(@"修改航线数据失败%s",error1);
    }
    
    
    /**************************************
     **************网络数据同步**************
     **************************************/
}

//修改航点表数据
- (void)updataWithStu:(sqliteRoute *)rtu {

    
    for (int i = 0; i < rtu.point_array.count; i++) {
        
        sqlitePoint* point = [[sqlitePoint alloc] init];
        point = [rtu.point_array objectAtIndex:i];
        //1.sqlite语句
        NSString *sqlite1 = [NSString stringWithFormat:@"update final_points set route_id = '%d',point_index = '%d',point_x = '%f',point_y = '%f' where id = '%d'",point.route_Id,point.index,point.point_x,point.point_y,point.Id];
        //2.执行sqlite语句
        char *error1 = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
        int result1 = sqlite3_exec(_routeDB, [sqlite1 UTF8String], nil, nil, &error1);
        if (result1 == SQLITE_OK) {
            NSLog(@"修改航点数据成功");
        } else {
            NSLog(@"修改航点数据失败");
        }
    }
    
    
    /**************************************
     **************网络数据同步**************
     **************************************/
    
   
    
}


//🆔条件查询

- (sqliteRoute *)selectWithId:(int)Id{
    //1.准备sqlite语句
    NSString *sqlite ;
    
    switch (_mode) {
        case ZZCRouteMode_tiaodai:
            sqlite = [NSString stringWithFormat:@"select * from tiaodai_route where type = %d and id = %d",0,Id];
            break;
        case ZZCRouteMode_huanxing:
            sqlite = [NSString stringWithFormat:@"select * from tiaodai_route where type = %d and id = %d",1,Id];
            break;
        case ZZCRouteMode_qinxie:
            sqlite = [NSString stringWithFormat:@"select * from tiaodai_route where type = %d and id = %d",2,Id];
            break;
        case ZZCRouteMode_quanjin:
            sqlite = [NSString stringWithFormat:@"select * from tiaodai_route where type = %d and id = %d",3,Id];
            break;
            
        default:
            break;
    }
    //2.伴随指针
    sqlite3_stmt *stmt = NULL;
    //3.预执行sqlite语句
    int result = sqlite3_prepare(_routeDB, sqlite.UTF8String, -1, &stmt, NULL);//第4个参数是一次性返回所有的参数,就用-1
    sqliteRoute *route = [[sqliteRoute alloc] init];
    if (result == SQLITE_OK) {
        
        //4.执行n次
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            NSLog(@"航线查询成功");
            
            //从伴随指针获取数据,第0列
            route.Id = sqlite3_column_int(stmt, 0);
            //从伴随指针获取数据,第1列
            route.user_Id = sqlite3_column_int(stmt, 1);
            //从伴随指针获取数据,第2列
            route.time = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)] ;
            //从伴随指针获取数据,第3列
            route.inittime = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
            //从伴随指针获取数据,第4列
            route.type = sqlite3_column_int(stmt, 4);
            //从伴随指针获取数据,第5列
            route.currentIndex = sqlite3_column_int(stmt, 5);
            //从伴随指针获取数据,第6列
            route.height = sqlite3_column_double(stmt, 6);
            //从伴随指针获取数据,第7列
            route.l_height = sqlite3_column_double(stmt, 7);
            //从伴随指针获取数据,第8列
            route.beginIndex = sqlite3_column_int(stmt, 8);
            //从伴随指针获取数据,第9列
            route.hxChongdie = sqlite3_column_double(stmt, 9);
            //从伴随指针获取数据,第10列
            route.pxChongdie = sqlite3_column_double(stmt, 10);
            //从伴随指针获取数据,第11列
            route.angle = sqlite3_column_int(stmt, 11);
            //从伴随指针获取数据,第12列
            route.pointCount = sqlite3_column_int(stmt, 12);
            //从伴随指针获取数据,第13列
            int deleteOrnot = sqlite3_column_int(stmt, 13);
            if (deleteOrnot == 0) {
                route.deleteOrnot = NO;//ZJL NO
            }else{
                route.deleteOrnot = YES;//ZJL
            }
            //从伴随指针获取数据,第14列
            route.route_name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 14)] ;
            //从伴随指针获取数据,第15列
            route.qinxieAngle = sqlite3_column_int(stmt, 15);
            
            NSString *sqlite1 = [NSString stringWithFormat:@"select * from final_points where route_id = %d",route.Id];
            sqlite3_stmt *stmt1 = NULL;
            int result1 = sqlite3_prepare(_routeDB, sqlite1.UTF8String, -1, &stmt1, NULL);
            
            if (result1 == SQLITE_OK) {
                
                
                NSMutableArray *temp_points = [[NSMutableArray alloc] init];//暂时存储顺序不规则的点
                
                while (sqlite3_step(stmt1) == SQLITE_ROW){
                    NSLog(@"航点查询成功");
                    
                    sqlitePoint * point = [[sqlitePoint alloc] init];
                    
                    point.Id = sqlite3_column_int(stmt1, 0);
                    point.route_Id = sqlite3_column_int(stmt1, 1);
                    point.index = sqlite3_column_int(stmt1, 2);
                    point.point_x = sqlite3_column_double(stmt1, 3);
                    point.point_y = sqlite3_column_double(stmt1, 4);
                    
                    [temp_points addObject:point];
                    
                }
                
                
                sqlitePoint * temp = [[sqlitePoint alloc] init];
                
                for (int i = 0; i < temp_points.count; i++) {
                    for (int j = 0; j < temp_points.count - 1 - i; j++) {
                        
                        sqlitePoint * point = [temp_points objectAtIndex:j];
                        sqlitePoint * point1 = [temp_points objectAtIndex:j+1];
                        
                        if (point.index < point1.index) {
                            temp = point;
                            [temp_points setObject:point1 atIndexedSubscript:j];
                            [temp_points setObject:temp atIndexedSubscript:j+1];
                        }
                        
                    }
                    
                    [route.point_array addObject:[temp_points objectAtIndex:(temp_points.count - 1 - i)]];
                }
                
            }
    
}
        return route;
    }else {
        NSLog(@"查询失败");
        return nil;
    }
    
    
    
}


//查询所有数据
- (NSMutableArray*)selectWithRtu {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    //1.准备sqlite语句
    NSString *sqlite ;
    
    switch (_mode) {
        case ZZCRouteMode_tiaodai:
            sqlite = [NSString stringWithFormat:@"select * from tiaodai_route where type = %d and user_id = %d and deleteOrnot = %d",0,_zzcUser.Id,0];
            break;
        case ZZCRouteMode_huanxing:
            sqlite = [NSString stringWithFormat:@"select * from tiaodai_route where type = %d  and user_id = %d and deleteOrnot = %d",1,_zzcUser.Id,0];
            break;
        case ZZCRouteMode_qinxie:
            sqlite = [NSString stringWithFormat:@"select * from tiaodai_route where type = %d and user_id = %d and deleteOrnot = %d",2,_zzcUser.Id,0];
            break;
        case ZZCRouteMode_quanjin:
            sqlite = [NSString stringWithFormat:@"select * from tiaodai_route where type = %d and user_id = %d and deleteOrnot = %d",3,_zzcUser.Id,0];
            break;
            
        default:
            break;
    }
    //2.伴随指针
    sqlite3_stmt *stmt = NULL;
    //3.预执行sqlite语句
    int result = sqlite3_prepare(_routeDB, sqlite.UTF8String, -1, &stmt, NULL);//第4个参数是一次性返回所有的参数,就用-1
    if (result == SQLITE_OK) {
        
        //4.执行n次
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            NSLog(@"航线查询成功");
            sqliteRoute *route = [[sqliteRoute alloc] init];
            //从伴随指针获取数据,第0列
            route.Id = sqlite3_column_int(stmt, 0);
            //从伴随指针获取数据,第1列
            route.user_Id = sqlite3_column_int(stmt, 1);
            //从伴随指针获取数据,第2列
            route.time = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)] ;
            //从伴随指针获取数据,第3列
            route.inittime = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
            //从伴随指针获取数据,第4列
            route.type = sqlite3_column_int(stmt, 4);
            //从伴随指针获取数据,第5列
            route.currentIndex = sqlite3_column_int(stmt, 5);
            //从伴随指针获取数据,第6列
            route.height = sqlite3_column_double(stmt, 6);
            //从伴随指针获取数据,第7列
            route.l_height = sqlite3_column_double(stmt, 7);
            //从伴随指针获取数据,第8列
            route.beginIndex = sqlite3_column_int(stmt, 8);
            //从伴随指针获取数据,第9列
            route.hxChongdie = sqlite3_column_double(stmt, 9);
            //从伴随指针获取数据,第10列
            route.pxChongdie = sqlite3_column_double(stmt, 10);
            //从伴随指针获取数据,第11列
            route.angle = sqlite3_column_int(stmt, 11);
            //从伴随指针获取数据,第12列
            route.pointCount = sqlite3_column_int(stmt, 12);
            //从伴随指针获取数据,第13列
           int deleteOrnot = sqlite3_column_int(stmt, 13);
            if (deleteOrnot == 0) {
                route.deleteOrnot = NO;//ZJL NO
            }else{
                route.deleteOrnot = YES;//ZJL
            }
            //从伴随指针获取数据,第14列
            route.route_name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 14)];;
            //从伴随指针获取数据,第15列
            route.qinxieAngle = sqlite3_column_int(stmt, 15);
            
            NSString *sqlite1 = [NSString stringWithFormat:@"select * from final_points where route_id = %d",route.Id];
            sqlite3_stmt *stmt1 = NULL;
            int result1 = sqlite3_prepare(_routeDB, sqlite1.UTF8String, -1, &stmt1, NULL);
            
            if (result1 == SQLITE_OK) {
                
                
                NSMutableArray *temp_points = [[NSMutableArray alloc] init];//暂时存储顺序不规则的点
                
                while (sqlite3_step(stmt1) == SQLITE_ROW){
                    NSLog(@"航点查询成功");
                
                    sqlitePoint * point = [[sqlitePoint alloc] init];
                    
                    point.Id = sqlite3_column_int(stmt1, 0);
                    point.route_Id = sqlite3_column_int(stmt1, 1);
                    point.index = sqlite3_column_int(stmt1, 2);
                    point.point_x = sqlite3_column_double(stmt1, 3);
                    point.point_y = sqlite3_column_double(stmt1, 4);
                    
                    [temp_points addObject:point];
                
                }
                
                
                sqlitePoint * temp = [[sqlitePoint alloc] init];
                
                for (int i = 0; i < temp_points.count; i++) {
                    for (int j = 0; j < temp_points.count - 1 - i; j++) {
                        
                         sqlitePoint * point = [temp_points objectAtIndex:j];
                         sqlitePoint * point1 = [temp_points objectAtIndex:j+1];
                        
                        if (point.index < point1.index) {
                            temp = point;
                            [temp_points setObject:point1 atIndexedSubscript:j];
                            [temp_points setObject:temp atIndexedSubscript:j+1];
                        }
                        
                    }
                    
                    [route.point_array addObject:[temp_points objectAtIndex:(temp_points.count - 1 - i)]];
                }
                
            }
            
            [array addObject:route];
            
            //这个先别加了 后面怕出事
            
//            if (array.count > 0) {
//                array = [self addWithTime:array rtu:route];
//            }else{
//             [array addObject:route];
//            }
            
            
        }
    } else {
        NSLog(@"查询失败");
    }
    
    return array;
}

#pragma mark - IBAction Methods

- (IBAction)mapHide_btn_clicked:(id)sender {
    
    //地图列表回缩
    //反弹按钮显示
    
    _mapHideView.transform = CGAffineTransformMakeTranslation(-_mapHideView.frame.size.width,0);
    [_mapShow_btn setHidden:NO];
    
    
}


- (IBAction)mapShow_btn_clicked:(id)sender {
    
    _mapHideView.transform = CGAffineTransformMakeTranslation(0,0);
    [_mapShow_btn setHidden:YES];
    
    //地图列表显示
    //反弹按钮隐藏
}



- (IBAction)uploadroute:(id)sender {
    
    //钟智超修改于2022/04/18
    /*if ([[zzcAFN internetStauts] isEqualToString:@"NONE"]) {
        //没网
        ShowResult(@"网络状况异常，无法同步");
        return;
    }*/
    
    [self compareRtu];
    [SZKCustomAlter showAlter:@"正在同步..." alertTime:0.5];
    
}
//114.356918    30.52729

- (IBAction)wapian_Btn_cliked:(id)sender {
    if ([sender tag] == 0) {
        [sender setTitle:@"完成新建" forState:UIControlStateNormal];
        [sender setTag:1];
        _wapianBool = YES;
        ShowResult(@"请按顺序点选边界点！");
        NSLog(@"点击了拉区");
        
        
    }else{
        [sender setTitle:@"新建地图" forState:UIControlStateNormal];
        [sender setTag:0];
        _wapianBool = NO;
        

        if (_wapian_Array.count < 3) {
            ShowResult(@"新建地图区域失败！");
            [_mapView removeAnnotations:_wapian_Array];
            [_mapView removeOverlay:_wapianPolygon];
            [_wapian_Array removeAllObjects];
            return;
        }
        
        
        [_mapView removeAnnotations:_wapian_Array];
        [_mapView removeOverlay:_wapianPolygon];
        

        
        
        NSString * url = [self array2str:[self wapianUrl:_wapian_Array]];
        LocalMap * newmap = [[LocalMap alloc] init];
        newmap.name = @"无名称";
        newmap.time = [DJIRootViewController getCurrentTimes];
        newmap.statuscode = 0;//未下载
        newmap.url = url;
        newmap.coor = [self fetchCenter:_wapian_Array];
        [self addLocalMap:newmap];
        [_wapian_Array removeAllObjects];
        NSLog(@"点击了完成");
    }
}
- (IBAction)giveup_Btn_cliked:(id)sender {
    
    [_mapView removeAnnotations:_wapian_Array];
    [_mapView removeOverlay:_wapianPolygon];
    [_wapian_Array removeAllObjects];
    
}


- (IBAction)changeMode_cliked:(id)sender {
    
     [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)changeUser_cliked:(id)sender {
    
    UIStoryboard * vb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UserLoginViewController * rootVC = [vb instantiateViewControllerWithIdentifier:@"userLoginView"];
    [self.navigationController pushViewController:rootVC animated:YES];
}

- (IBAction)saveChanges_cliked:(id)sender {
    //保存对航线的修改
    if (_mapController.editPoints.count > 0) {
        _mapController.route.time = [DJIRootViewController getCurrentTimes];
        [self updataWithStu:_mapController.route];
        [self updateWithRoute:_mapController.route];
        
//        //这里需要更新一下
//        _route_Array = [self selectWithRtu];
//        [_taskTableView reloadData];
    
        ShowResult(@"已将修改保存到本地");
    }
}




/**
 *
 这个方法用来响应冲刺安装电池后的上传任务
 *
 **/
- (IBAction)lowBetterrySYNC:(id)sender {
    
    [self lowBetterySync];
}



/**
 *
这个方法用来响应缩放至用户位置的点击事件
 *
 **/
- (IBAction)userfocusAction:(id)sender {
    
    if (CLLocationCoordinate2DIsValid(self.userLocation)) {
        MKCoordinateRegion region = {0};
        region.center = self.userLocation;
        region.span.latitudeDelta = 0.001;
        region.span.longitudeDelta = 0.001;
        
        NSLog(@"用户位置：%f  %f",_userLocation.latitude,_userLocation.longitude);
        [self.mapView setRegion:region animated:YES];
}
}

//选择倾斜飞的方向  由于需求变化 这个方法作废
//由于全景飞这个方法变废为宝
- (IBAction)qinxieSegmentAction:(id)sender {
    switch (self.qinxieSegment.selectedSegmentIndex) {
        case 0:
            _quanjing_Bool = YES;
            break;
        case 1:
            _quanjing_Bool = NO;
            break;
        default:
            break;
    }
}

- (IBAction)hideBtnAction:(id)sender {
    
     _taskView.transform = CGAffineTransformMakeTranslation(_taskView.frame.size.width,0);
    [_tasksBtn setHidden:NO];
    
}

- (IBAction)tasksBtnAction:(id)sender {
    
    [_taskTableView setHidden:NO];
    NSLog(@"请显示任务列表吧");
    
    _taskView.transform = CGAffineTransformMakeTranslation(0,0);
    [sender setHidden:YES];
    
}

//新建任务
- (IBAction)actionBtnAction:(id)sender {

    
    /*if ([[zzcAFN internetStauts] isEqualToString:@"NONE"]) {
        //没网
        ShowResult(@"网络状况异常，无法添加");
        return;
    }*/
    
    [self initRoute];

     //这里没网怎么办  先不直接后台操作 先本地新建 -1001代表本地

    [self addLocalRoute:_mapController.editPoints Id:-1001 reviseTime:[DJIRootViewController getCurrentTimes] route_name:@"无名称" initTime:[DJIRootViewController getCurrentTimes]];
    
    
    
    //钟智超修改2022/04/18
    //[self addRoute:_mapController.editPoints];



}

#pragma mark LJKSlideViewDelegate Methods
/*
 滑动起飞View delegate 实现
 */

- (void) slideNeedDoSometing{
    //do something
    
    [[self missionOperator] startMissionWithCompletion:^(NSError * _Nullable error) {
        if (error){
            ShowMessage(@"开始任务失败！", error.description, nil, @"OK");
        }else
        {
            //任务已经开始不要编辑地图了
            _isEditingPoints = NO;
            [self setEditMode:_isEditingPoints];
            if (_lowBettery != YES) {
                //假如上传任务成功就需要剪去一条航线
                _routeNum = _routeNum - 1;
            }
            //无论是从装电池还是第一次飞行都默认高电量
            _lowBettery = NO;
            
            //这个地方我要开始坚挺任务处理的过程所以。。。
            /**
             *  Adds listener to receive the event related to execution.
             *
             *  @param listener Listener that is interested on execution event.
             *  @param queue The dispatch queue that `block` will be called on.
             *  @param block Block will be called when there is event updated related to execution.
             */
            
            WeakRef(target);
            
            
            
            [[self missionOperator] addListenerToExecutionEvent:self withQueue:dispatch_get_main_queue()  andBlock:^(DJIWaypointMissionExecutionEvent * _Nonnull event) {
                WeakReturn(target);
                
                switch ([[target missionOperator] currentState]) {
                    case DJIWaypointMissionStateDisconnected:
                        //无人机 移动设备 遥控起三者之间的连接链路断开了
                        target.modeLabel.text = @"连接中断";
                        //记录断开的时候是多少index
                        _pointIndexLastone = (_saticRouteNum - _routeNum - 1) * 99 + (int)[self.missionOperator.latestExecutionProgress targetWaypointIndex];
                        //ShowResult(@"%d",_pointIndexNow);
                        break;
                    case DJIWaypointMissionStateRecovering:
                        //无人机 移动设备 遥控起三者之间的连接链路正在恢复
                        
                        target.modeLabel.text = @"连接正在恢复";
                        break;
                    case DJIWaypointMissionStateExecuting:
                        //无人机正在正常处理任务
                    {
                        //这里设置一个进度跟随 数据库更新
                        //希望能洗一个异常集合 集成所有异常情况进行集中编辑
                        
                        if (_pointIndexNow != (_saticRouteNum - _routeNum - 1) * 99 + (int)[self.missionOperator.latestExecutionProgress targetWaypointIndex]) {
                            _pointIndexNow = (_saticRouteNum - _routeNum - 1) * 99 + (int)[self.missionOperator.latestExecutionProgress targetWaypointIndex];
                            
                            _mapController.route.currentIndex  = _oldPointsNum + _pointIndexNow ;
                            
                            [self updateWithRoute:_mapController.route];
                            //
                            //                              ShowResult(@"%d",_mapController.route.currentIndex);
                            
                            
                            //这里进行监听航线渲染
                            switch (_mode) {
                                case ZZCRouteMode_qinxie:
                                {
                                    
                                    int realIndex = (_saticRouteNum - _routeNum - 1) * 99 + (int)[self.missionOperator.latestExecutionProgress targetWaypointIndex];
                                    ZZCWaypoint * zzcWP = [_index_Array objectAtIndex:realIndex];
                                    //self.gpsLabel.text =[NSString stringWithFormat:@"%d",zzcWP.index];
                                    if (zzcWP.index >= _mapController.route.beginIndex) {
                                        realIndex = zzcWP.index - _mapController.route.beginIndex;
                                    }else{
                                        realIndex = _mapController.route.pointCount - zzcWP.index - 1;
                                        
                                    }
                                    
                                    
                                    [self qinxie_LineView:_mapController.route.beginIndex realIndex:realIndex - 1 pointCount:_mapController.route.pointCount];
                                }
                                    break;
                                case ZZCRouteMode_quanjin:
                                    //[self tiaodai_LineView];
                                    break;
                                case ZZCRouteMode_tiaodai:
                                    [self tiaodai_LineView:_beginIndex realIndex:(_saticRouteNum - _routeNum - 1) * 99 + (int)[self.missionOperator.latestExecutionProgress targetWaypointIndex] - 1 pointCount:(int)_mission_Array.count];
                                    break;
                                case ZZCRouteMode_huanxing:
                                    [self tiaodai_LineView:_beginIndex realIndex:(_saticRouteNum - _routeNum - 1) * 99 + (int)[self.missionOperator.latestExecutionProgress targetWaypointIndex] - 1 pointCount:(int)_mission_Array.count];
                                    break;
                                    
                                default:
                                    break;
                            }
                            
                            
                            
                        }
                        
                        
                    }
                        
                    default:
                        break;
                }
                
            }];
            
            
            ShowMessage(@"", @"任务开始！", nil, @"OK");
            [_slide setHidden:YES];
            [_tfview setHidden:YES];
            
            
        }
    }];

    

    
}

#pragma mark DJISDKManagerDelegate Methods

/**
 *
无人机注册
 *
 **/
- (void)appRegisteredWithError:(NSError *)error
{
    
    
    if (error){
        NSString *registerResult = [NSString stringWithFormat:@"Registration Error:%@", error.description];
        ShowMessage(@"Registration Result", registerResult, nil, @"OK");
        
    }
    else{
#if ENTER_DEBUG_MODE
        [DJISDKManager enableBridgeModeWithBridgeAppIP:@"Please Enter Your Debug ID"];
#else
        [DJISDKManager startConnectionToProduct];
        DJIFlightController* flightController = [DemoUtility fetchFlightController];
        if (flightController) {
            flightController.delegate = self;
        }
        
        DJIBattery* battery = [DemoUtility fetchBattery];
        if (battery) {
            battery.delegate = self;
        }
#endif
    }
}


/**
 *
无人机连接
 *
 **/
- (void)productConnected:(DJIBaseProduct *)product
{
    
    
    ShowResult(@"无人机连接成功！");
    
    
    if (product){
        
        self.product = product;
        [self updateDibuLabels];
        
        DJIFlightController* flightController = [DemoUtility fetchFlightController];
        if (flightController) {
            flightController.delegate = self;
        }
        
        DJIBattery* battery = [DemoUtility fetchBattery];
        if (battery) {
            battery.delegate = self;
        
        }
    }else{
        
    }
    
    //If this demo is used in China, it's required to login to your DJI account to activate the application. Also you need to use DJI Go app to bind the aircraft to your DJI account. For more details, please check this demo's tutorial.
    [[DJISDKManager userAccountManager] logIntoDJIUserAccountWithAuthorizationRequired:NO withCompletion:^(DJIUserAccountState state, NSError * _Nullable error) {
        if (error) {
            NSLog(@"账号登录失败！: %@", error.description);
        }
    }];
    
}

/**
 *
 无人机断开连接
 *
 **/

- (void)productDisconnected
{
    
    self.product = nil;
    [self updateDibuLabels];
    ShowMessage(@"糟糕！产品连接断开啦！", nil, nil, @"OK");
    
}


#pragma UIgesture action Methods

/**
 *
拖拽视图的拖拽手势
 *
 **/
- (void)contentViewHandlePan:(UIPanGestureRecognizer *)pan
{
    NSLog(@"--------------MKOverlayView拖动事件");
    if (pan.state == UIGestureRecognizerStateBegan) {
        NSLog(@"--------------MKOverlayView开始拖动");
        CGPoint point = [pan locationInView:_mapView];
        //_contentView.center = point;
        [pan setTranslation:CGPointZero inView:pan.view];
        CLLocationCoordinate2D point_coor = [_mapView convertPoint:point toCoordinateFromView:_mapView];
        _panLocation = [_locationChange MarsGS2WorldGS:point_coor];
        CLLocation * oldLocation = [_mapController.editPoints objectAtIndex:0];
        _start_panLocation = oldLocation.coordinate;
        
        //为了界面整洁 开始拖动需要删除原先的点标记
        
        
        NSArray* annos = [NSArray arrayWithArray:_mapView.annotations];
        for (int i = 0; i < annos.count; i++) {
            id<MKAnnotation> ann = [annos objectAtIndex:i];
            
            if ([ann isKindOfClass:[ZZCMiddleAnnotaion class]] || [ann isKindOfClass:[DJIRouteAnnotion class]] || [ann isKindOfClass:[MKPointAnnotation class]]||[ann isKindOfClass:[DJIBeginPointAnnotation class]]) { //Add it to check if the annotation is the aircraft's and prevent it from removing
                [_mapView removeAnnotation:ann];
            }
            
        }
        
        
        //为了界面整洁我把这个折线也删了
        [_mapView removeOverlay:_routePlan.polyline];
        if (_routePlan.N_polyline) {
            [_mapView removeOverlay:_routePlan.N_polyline];
            [_mapView removeOverlay:_routePlan.E_polyline];
            [_mapView removeOverlay:_routePlan.S_polyline];
            [_mapView removeOverlay:_routePlan.W_polyline];
        }
        
    }
    if (pan.state == UIGestureRecognizerStateChanged) {
        
        NSLog(@"--------------MKOverlayView正在拖动");
         CGPoint point = [pan locationInView:_mapView];
        //_contentView.center = point;
        CLLocationCoordinate2D point_coor = [_mapView convertPoint:point toCoordinateFromView:_mapView];
        CLLocationCoordinate2D new_panlocation = [_locationChange MarsGS2WorldGS:point_coor];
        double latChanged = new_panlocation.latitude - _panLocation.latitude;
        double lonChanged = new_panlocation.longitude - _panLocation.longitude;
        
        _panLocation.latitude = new_panlocation.latitude;
        _panLocation.longitude  = new_panlocation.longitude;
        
        
        for (int i = 0; i < _mapController.editPoints.count; i++) {
            
            if (_mode == ZZCRouteMode_qinxie) {
                
                CLLocation * location1 = [_routePlan.westLocations objectAtIndex:i];
                CLLocation * location2 = [_routePlan.eastLocations objectAtIndex:i];
                CLLocation * location3 = [_routePlan.northLocations objectAtIndex:i];
                CLLocation * location4 = [_routePlan.southLocations objectAtIndex:i];
    
                CLLocation * newLoc1 = [[CLLocation alloc] initWithLatitude:location1.coordinate.latitude + latChanged longitude:location1.coordinate.longitude + lonChanged];
                CLLocation * newLoc2 = [[CLLocation alloc] initWithLatitude:location2.coordinate.latitude + latChanged longitude:location2.coordinate.longitude + lonChanged];
                CLLocation * newLoc3 = [[CLLocation alloc] initWithLatitude:location3.coordinate.latitude + latChanged longitude:location3.coordinate.longitude + lonChanged];
                CLLocation * newLoc4 = [[CLLocation alloc] initWithLatitude:location4.coordinate.latitude + latChanged longitude:location4.coordinate.longitude + lonChanged];
                
                _routePlan.westLocations[i] = newLoc1;
                _routePlan.eastLocations[i] = newLoc2;
                _routePlan.northLocations[i] = newLoc3;
                _routePlan.southLocations[i] = newLoc4;
            }
            
            
            CLLocation * location = [_mapController.editPoints objectAtIndex:i];
            CLLocationCoordinate2D new_coor = CLLocationCoordinate2DMake(location.coordinate.latitude + latChanged, location.coordinate.longitude + lonChanged);
            CLLocation * newLoc = [[CLLocation alloc] initWithLatitude:new_coor.latitude longitude:new_coor.longitude];
            
            _mapController.editPoints[i] = newLoc;
            sqlitePoint * oldpoint = [_mapController.route.point_array objectAtIndex:i];
            sqlitePoint * point1 = [[sqlitePoint alloc] init];
            point1.point_x = newLoc.coordinate.latitude;
            point1.point_y = newLoc.coordinate.longitude;
            point1.Id = oldpoint.Id;
            point1.index = oldpoint.index;
            point1.route_Id = oldpoint.route_Id;
            
            [_mapController.route.point_array setObject:point1 atIndexedSubscript:i];
        }
        
        _centerCoor = [_mapController setPolygonView : _mapController.editPoints withMapView:_mapView withCenterView:_contentView withCenterCoor:_centerCoor];
        
        if (_mode == ZZCRouteMode_qinxie) {
            
            [_mapController setqinxiePolygonView:_routePlan.westLocations northPoints:_routePlan.northLocations eastPoints:_routePlan.eastLocations southPoints:_routePlan.southLocations withMapView:_mapView];
        }
        
        
        

    }
    if (pan.state == UIGestureRecognizerStateEnded) {
        NSLog(@"--------------MKOverlayView结束拖动");
        CGPoint point = [pan locationInView:_mapView];
        _centerCoor = [_mapView convertPoint:point toCoordinateFromView:_mapView];
        
        
        CLLocation* newLocation = [_mapController.editPoints objectAtIndex:0];
        CLLocationCoordinate2D newCoor = newLocation.coordinate;
        
        NSLog(@"newCoor.latitude %f",newCoor.latitude);
        NSLog(@"_start_panLocation.latitude %f",_start_panLocation.latitude);
        
        [_mapController setPointView:_mapController.editPoints withMapView:_mapView];
        if (_mode == ZZCRouteMode_tiaodai || _mode == ZZCRouteMode_qinxie) {
            [_mapController setMiddlePoint:_mapController.editPoints withMapView:_mapView];
        }
        
        //删除已上传的任务
        [_waypointMission removeAllWaypoints];
        //按照正常逻辑决定删除这一段 每次拖动结束后都需要重新计算航点而不是直接显示位移后的行航点
       // [_routePlan updateRouteViewForTT:changed_x changed_y:changed_y withMapView:_mapView];
        [self newRouteLine];
        
    }

}

#pragma mark action Methods

-(DJIWaypointMissionOperator *)missionOperator {
    return [DJISDKManager missionControl].waypointMissionOperator;
}

-(DJIPanoramaMissionOperator *)p_missionOperator {
    return [DJISDKManager missionControl].panoramaMissionOperator;
}


/**
 *
定位到无人机
 *
 **/
- (void)focusMap
{
    if (CLLocationCoordinate2DIsValid(self.droneLocation)) {
        MKCoordinateRegion region = {0};
        region.center = self.droneLocation;
        region.span.latitudeDelta = 0.001;
        region.span.longitudeDelta = 0.001;
        
        [self.mapView setRegion:region animated:YES];
    }
    
    /*if (CLLocationCoordinate2DIsValid(self.userLocation)) {
        MKCoordinateRegion region = {0};
        region.center = self.userLocation;
        region.span.latitudeDelta = 0.001;
        region.span.longitudeDelta = 0.001;
        
        [self.mapView setRegion:region animated:YES];
    }*/
}

#pragma mark CLLocation Methods
/**
 *
开始定位监听
 *
 **/
-(void) startUpdateLocation
{
    if ([CLLocationManager locationServicesEnabled]) {
        if (self.locationManager == nil) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.distanceFilter = 0.1;
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
            }
            [self.locationManager startUpdatingLocation];
        }
    }else
    {
        ShowMessage(@"Location Service is not available", @"", nil, @"OK");
    }
}

#pragma mark UITapGestureRecognizer Methods
/**
 *
 点击地图mapview 添加点标记
 *
 **/
- (void)addWaypoints1:(UITapGestureRecognizer *)tapGesture
{
    if (_wapianBool == YES) {
        CGPoint point = [tapGesture locationInView:self.mapView];
        
        if(tapGesture.state == UIGestureRecognizerStateEnded){
            
            CLLocationCoordinate2D coordinate = [_mapView convertPoint:point toCoordinateFromView:_mapView];
             //CLLocationCoordinate2D coordinateM = [_locationChange WorldGS2MarsGS:coordinate ];
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            //CLLocation *locationM = [[CLLocation alloc] initWithLatitude:coordinateM.latitude longitude:coordinateM.longitude];
            
            
            WapianAnnotation * annotation = [[WapianAnnotation alloc] initWithCoordiante:location.coordinate];
            [_mapView addAnnotation:annotation];
            
            //WapianAnnotation * annotationM = [[WapianAnnotation alloc] initWithCoordiante:locationM.coordinate];
            [annotation setIndex:(int)_wapian_Array.count];
            [_wapian_Array addObject:annotation];
            
            if (_wapian_Array.count >= 3) {
                
                [_mapView removeOverlay:_wapianPolygon];
                //绘制面
                [self polygonInmapview:_mapView points:_wapian_Array];
            }
    }
    
        
    }
    
    
}


/**
 *
 点击地图mapview 添加点标记
 *
 **/
- (void)addWaypoints:(UITapGestureRecognizer *)tapGesture
{
    CGPoint point = [tapGesture locationInView:self.mapView];
    
    if(tapGesture.state == UIGestureRecognizerStateEnded){
        if (self.isEditingPoints&&_mode == ZZCRouteMode_quanjin&&_quanjing_Bool == YES){
            [self.mapController addPoint:point withMapView:self.mapView];
        
        
        CLLocationCoordinate2D coordinate = [_mapView convertPoint:point toCoordinateFromView:_mapView];
        CLLocationCoordinate2D changedcoordinate = [self.locationChange MarsGS2WorldGS:coordinate];
        CLLocation *wordLoc = [[CLLocation alloc] initWithLatitude:changedcoordinate.latitude longitude:changedcoordinate.longitude];
        
        sqlitePoint * point1 = [[sqlitePoint alloc] init];
        sqlitePoint * temp = [_mapController.route.point_array objectAtIndex:0];
        point1.point_x = wordLoc.coordinate.latitude;
        point1.point_y = wordLoc.coordinate.longitude;
        point1.route_Id = temp.route_Id;
        [_mapController.route.point_array addObject:point1];
        
        
        
        for (int i = 0; i < _mapController.route.point_array.count; i++) {
            sqlitePoint * point = [_mapController.route.point_array objectAtIndex:i];
            point.index = i;
        }
        
        sqlitePoint* insert_point = [_mapController.route.point_array objectAtIndex:_mapController.route.point_array.count - 1];
        NSString *sqlite1 = [NSString stringWithFormat:@"insert into final_points(id,route_id,point_index,point_x,point_y) values (NULL,'%d','%d','%f','%f')",insert_point.route_Id,insert_point.index,insert_point.point_x,insert_point.point_y];
        char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
        int result = sqlite3_exec(_routeDB, [sqlite1 UTF8String], nil, nil, &error);
        if (result == SQLITE_OK) {
            NSLog(@"添加数据至航点表成功");
            insert_point.Id = (int)sqlite3_last_insert_rowid(_routeDB);
            [self updataWithStu:_mapController.route];
        } else {
            NSLog(@"添加数据至航点表失败");
        }
        
        
             NSLog(@"CLiked");
    }
    }
}

#pragma mark - DJIHRWaypointConfigViewControllerDelegate Methods
/**
 *
环绕飞取消按钮点击委托
 *
 **/
- (void)cancelBtnActionInDJIHRWaypointConfigViewController:(DJIHRWaypointConfigViewController *)waypointConfigVC
{
    
    WeakRef(weakSelf);
    
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        weakSelf.HR_waypointConfigVC.view.alpha = 0;
    }];
}

/**
 *
环绕飞配置结束按钮点击委托
 *
 **/
- (void)finishBtnActionInDJIHRWaypointConfigViewController:(DJIHRWaypointConfigViewController *)waypointConfigVC
{
    
    
    
    
    //有则删除无则加勉
    if (self.waypointMission){
        [self.waypointMission removeAllWaypoints];
    }
    else{
        self.waypointMission = [[DJIMutableWaypointMission alloc] init];
    }
    
    
    
    if (_mission_Array.count > 0) {
        [_mission_Array removeAllObjects];
        [_index_Array removeAllObjects];
    }
    
    _routePlan.huanrao_Hmin = [[[_HR_waypointConfigVC low_altitudeTextField] text] floatValue];
    _routePlan.huanrao_Hmax = [[[_HR_waypointConfigVC high_altitudeTextField] text] floatValue];
    _routePlan.hxChongdie = [[[_HR_waypointConfigVC hxChongdieTextField] text] floatValue];
    _routePlan.pxChongdie = [[[_HR_waypointConfigVC pxChongdieTextField] text] floatValue];
    
    
    
    
    //任何参数的变动都会干扰断点续费
    if ([[[_HR_waypointConfigVC low_altitudeTextField] text] intValue] != _mapController.route.l_height ||[[[_HR_waypointConfigVC high_altitudeTextField] text] intValue] != _mapController.route.height || [[[_HR_waypointConfigVC hxChongdieTextField] text] floatValue] != _mapController.route.hxChongdie || [[[_HR_waypointConfigVC pxChongdieTextField] text] floatValue] != _mapController.route.pxChongdie ) {
        
        //相当于新航线
        _mapController.route.beginIndex = 0;
        _mapController.route.currentIndex = -1;
        _mapController.route.pointCount = 0;
        _oldPointsNum = 0;
        
        
    }
    
    
    _mapController.route.l_height = [[[_HR_waypointConfigVC low_altitudeTextField] text] floatValue];
    _mapController.route.height = [[[_HR_waypointConfigVC high_altitudeTextField] text] floatValue];
    _mapController.route.hxChongdie = [[[_HR_waypointConfigVC hxChongdieTextField] text] floatValue];
    _mapController.route.pxChongdie = [[[_HR_waypointConfigVC pxChongdieTextField] text] floatValue];
    
    
    //这里拉取一下出发点
    _routePlan.begin_index = _mapController.route.beginIndex;
    
    [_routePlan updateRouteView:_mapController.editPoints withMapView:_mapView];
    
    
   
    
   
    
    
   
    NSArray * wayPoints;
    wayPoints = [_routePlan getRoutePoints];
    _mapController.route.pointCount = (int)wayPoints.count;
    //这里进行配置结束后的数据库数据更新
    [self updateWithRoute:_mapController.route];
    if (wayPoints == nil || wayPoints.count < 2) { //DJIWaypointMissionMinimumWaypointCount is 2.
        ShowMessage(@"航点数量不足！", @"", nil, @"OK");
        return;
    }
    
    //重新查询
    _route_Array =  [self selectWithRtu];
    sqliteRoute * SQLroute = [_route_Array objectAtIndex:self.taskTableView.indexPathForSelectedRow.row];
    _mapController.route = SQLroute;
    
    
    //把这个点先存到自定义的数组里面 不妨到mission 里面了
    for (int i = 0; i < wayPoints.count; i++) {
        CLLocation* location = [wayPoints objectAtIndex:i];
        if (CLLocationCoordinate2DIsValid(location.coordinate)) {
            DJIWaypoint* waypoint = [[DJIWaypoint alloc] initWithCoordinate:location.coordinate];
            
            
            ZZCPoint* point = [_routePlan.routePoints objectAtIndex:i];
            
            waypoint.altitude = point.height;
            _waypointMission.rotateGimbalPitch = YES;
            waypoint.gimbalPitch = 0;
            //_waypointMission.headingMode = DJIWaypointMissionHeadingUsingWaypointHeading;
            waypoint.heading = point.heading;
            waypoint.turnMode = DJIWaypointTurnClockwise;
            
            
            
            
            if ([self isOldPoint:_mapController.route index:i pointNum:(int)wayPoints.count] != 0) {
                //waypoint.old_index = i;
                ZZCWaypoint * zzcWP = [[ZZCWaypoint alloc] initWithPoint:waypoint index:i];
                [self.index_Array addObject:zzcWP];
                [self.mission_Array addObject:waypoint];
                
            }else{
                //把这些飞过一次的点全部存到一起便于绘制
                CLLocationCoordinate2D worldWaypoint2D = CLLocationCoordinate2DMake(waypoint.coordinate.latitude, waypoint.coordinate.longitude);
                CLLocationCoordinate2D marsWaypoint2D = [_locationChange WorldGS2MarsGS:worldWaypoint2D];
                CLLocation * marsWaypointLoc = [[CLLocation alloc] initWithLatitude:marsWaypoint2D.latitude longitude:marsWaypoint2D.longitude];
                [_dync_Points1 addObject:marsWaypointLoc];
            }
            
            
            
        }
    }
    
    //区分完老点和新点之后需要进行点的排序保证绘制的时候不会出错
    _beginIndex = [self newBeginIndex:_mapController.route pointNum:(int)_routePlan.routeLocations.count];
    if (_mapController.route.currentIndex != -1) {
        _mission_Array = [self sort_route:_mission_Array begin_index:_beginIndex];
        _index_Array = [self sort_route:_index_Array begin_index:_beginIndex];
    }
    
   
    
    
    /********************************************
     //这里先绘制一下环绕飞的老点
     //在这里声明一个数组专门存这些点的2d坐标用来绘制路线
     ************************************************/
    [self tiaodai_huizhi];
    
    //int num = (int)_mission_Array.count;
    //NSString *string1 = [[NSString alloc] initWithFormat:@"数量:%d", num];
    
    //[self showAlertViewWithTitle:@"剩余航点数量" withMessage:string1];
//    ShowResult(@"数据库：%d\n实际：%d\n航点书：%d\ncurrentIndex:%d\npointCount:%d",_mapController.route.beginIndex,_beginIndex,_mission_Array.count,_mapController.route.currentIndex,_mapController.route.pointCount);
    ShowResult(@"实际航点数为：%d",_mission_Array.count);
    
    
    if (_mission_Array == nil || _mission_Array.count < 2) { //DJIWaypointMissionMinimumWaypointCount is 2.
        ShowMessage(@"航点数量不足！", @"", nil, @"OK");
        return;
    }
    
    //这一步的目的是为了求出有几条航带
    if (_mission_Array.count%99 != 0) {
        _routeNum = (int)_mission_Array.count/99 + 1;
        _saticRouteNum = _routeNum;
    }else{
        
        _routeNum = (int)_mission_Array.count/99;
        _saticRouteNum = _routeNum;
        
    }
    
    
    WeakRef(weakSelf);
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        weakSelf.HR_waypointConfigVC.view.alpha = 0;
    }];
    
}

#pragma mark - DJIWaypointConfigViewControllerDelegate Methods
/**
 *
条带飞取消按钮点击委托
 *
 **/
- (void)cancelBtnActionInDJIWaypointConfigViewController:(DJIWaypointConfigViewController *)waypointConfigVC
{
    WeakRef(weakSelf);
    
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        weakSelf.waypointConfigVC.view.alpha = 0;
    }];
    
}





/**
 *
 条带飞配置界面结束按钮点击委托
 *
 **/
- (void)finishBtnActionInDJIWaypointConfigViewController:(DJIWaypointConfigViewController *)waypointConfigVC
{
    
    //判断是否原先有点，有则删除无则加勉
    if (self.waypointMission){
        [self.waypointMission removeAllWaypoints];
    }
    else{
        self.waypointMission = [[DJIMutableWaypointMission alloc] init];
    }
    
    if (_mission_Array.count > 0) {
        [_mission_Array removeAllObjects];
        [_index_Array removeAllObjects];
    }
    
    
    
    
    
    _routePlan.tiaodai_H = [[[_waypointConfigVC altitudeTextField] text] floatValue];
    _routePlan.hxChongdie = [[[_waypointConfigVC hxChongdieTextField] text] floatValue];
    _routePlan.pxChongdie = [[[_waypointConfigVC pxChongdieTextField] text] floatValue];
    _routePlan.angle = [[[_waypointConfigVC angleTextField] text] intValue];
    _routePlan.xiangji_angle = [[[_waypointConfigVC qinxieAngleField] text] intValue];

    
    
    //任何参数的变动都会干扰断点续费
    if ([[[_waypointConfigVC altitudeTextField] text] intValue] != _mapController.route.height || [[[_waypointConfigVC hxChongdieTextField] text] floatValue] != _mapController.route.hxChongdie || [[[_waypointConfigVC pxChongdieTextField] text] floatValue] != _mapController.route.pxChongdie || _mapController.route.angle != [[[_waypointConfigVC angleTextField] text] intValue] || _mapController.route.qinxieAngle != [[[_waypointConfigVC qinxieAngleField] text] intValue]) {
        //相当于新航线
        _mapController.route.beginIndex = 0;
        _mapController.route.currentIndex = -1;
        _oldPointsNum = 0;
        _mapController.route.pointCount = 0;
        //ShowResult(@"新航线了！");
        
    }
    
    
    _mapController.route.height = [[[_waypointConfigVC altitudeTextField] text] floatValue];
    _mapController.route.hxChongdie = [[[_waypointConfigVC hxChongdieTextField] text] floatValue];
    _mapController.route.pxChongdie = [[[_waypointConfigVC pxChongdieTextField] text] floatValue];
    _mapController.route.angle = [[[_waypointConfigVC angleTextField] text] intValue];
    _mapController.route.qinxieAngle = [[[_waypointConfigVC qinxieAngleField] text] intValue];
    
    
    
    NSArray * wayPoints;
    
    switch (_mode) {
        case ZZCRouteMode_qinxie:
            [_routePlan fetchAllqinxieRound:_mapController.editPoints];
            NSLog(@"边界点的数量：%lu",(unsigned long)_routePlan.westLocations.count);
            [_mapController setqinxiePolygonView:_routePlan.westLocations northPoints:_routePlan.northLocations eastPoints:_routePlan.eastLocations southPoints:_routePlan.southLocations withMapView:_mapView];
            
            //这里拉取一下出发点
            _routePlan.begin_index = _mapController.route.beginIndex;
            
            [_routePlan updateqinxieRouteView:_routePlan.westLocations northPoints:_routePlan.northLocations eastPoints:_routePlan.eastLocations southPoints:_routePlan.southLocations withMapView:_mapView];
            wayPoints = self.routePlan.getRoutePoints;
            _mapController.route.pointCount = (int)wayPoints.count;
            if (wayPoints == nil || wayPoints.count < 2) { //DJIWaypointMissionMinimumWaypointCount is 2.
                ShowMessage(@"没有足够的航点！", @"", nil, @"OK");
                return;
            }
            break;
        case ZZCRouteMode_tiaodai:
            
            //这里拉取一下出发点
            _routePlan.begin_index = _mapController.route.beginIndex;
            
             [_routePlan updateRouteView:_mapController.editPoints withMapView:_mapView];
            
            wayPoints = self.routePlan.getRoutePoints;
            _mapController.route.pointCount = (int)wayPoints.count;
            if (wayPoints == nil || wayPoints.count < 2) { //DJIWaypointMissionMinimumWaypointCount is 2.
                ShowMessage(@"没有足够的航点！", @"", nil, @"OK");
                return;
            }
            break;
        case ZZCRouteMode_quanjin:
            //在这里完成“简单的”全景飞的航线算法
            wayPoints = _mapController.editPoints;
            _mapController.route.pointCount = (int)wayPoints.count;
            NSLog(@"wayPoints:%lu",wayPoints.count);
            break;
            
        default:
            break;
    }
    
    
    //这里进行配置结束后的数据库数据更新
    [self updateWithRoute:_mapController.route];
    //重新查询
    _route_Array =  [self selectWithRtu];
    sqliteRoute * SQLroute = [_route_Array objectAtIndex:self.taskTableView.indexPathForSelectedRow.row];
    _mapController.route = SQLroute;
    
    
    
   
    
    
    
    
    
    //把这个点先存到自定义的数组里面 不妨到mission 里面了
    for (int i = 0; i < wayPoints.count; i++) {
        CLLocation* location = [wayPoints objectAtIndex:i];
        if (CLLocationCoordinate2DIsValid(location.coordinate)) {
            DJIWaypoint* waypoint = [[DJIWaypoint alloc] initWithCoordinate:location.coordinate];
            
            
            switch (_mode) {
                case ZZCRouteMode_qinxie:
                    _waypointMission.rotateGimbalPitch = YES;
                    waypoint.gimbalPitch = -_routePlan.xiangji_angle;
                    
                    //_waypointMission.headingMode = DJIWaypointMissionHeadingUsingWaypointHeading;
                    //由于所有航点都存在一起了 所以需要判断那个点属于那一部分
                    if (i<_routePlan.westCount) {
                        waypoint.heading = 90 - _routePlan.angle;
                    }else if (i>=_routePlan.westCount&&i<_routePlan.westCount+_routePlan.northCount){
                        
                        waypoint.heading = 180 - _routePlan.angle;
                        
                    }else if(i>=_routePlan.westCount+_routePlan.northCount&&i<_routePlan.westCount+_routePlan.northCount+_routePlan.eastCount){
                        
                        waypoint.heading = -90 - _routePlan.angle;
                        
                    }else{
                        
                        waypoint.heading = 0 - _routePlan.angle;
                        
                    }
                    waypoint.turnMode = DJIWaypointTurnClockwise;
                    
                    break;
                case ZZCRouteMode_tiaodai:
                    
                    _waypointMission.rotateGimbalPitch = YES;
                    waypoint.gimbalPitch = -90;
                    //_waypointMission.headingMode = DJIWaypointMissionHeadingUsingWaypointHeading;
                    //waypoint.heading = 0;
                    waypoint.turnMode = DJIWaypointTurnClockwise;
                    break;
                case ZZCRouteMode_quanjin:
                {
                    /*每个航点最多动作15次 那么该如何解决呢？*/
                    /*这里完成全景飞行的初始配置*/
                    _waypointMission.rotateGimbalPitch = YES;
                    waypoint.gimbalPitch = -30;
                    //_waypointMission.headingMode = DJIWaypointMissionHeadingUsingWaypointHeading;
                    waypoint.heading = 0;
                    waypoint.turnMode = DJIWaypointTurnClockwise;
                    
                }
                    break;
                    
                default:
                    break;
            }
            //飞过的点就不要飞了
            if ([self isOldPoint:_mapController.route index:i pointNum:(int)wayPoints.count] != 0) {
                //这里记录一下原本数组里买呢下表
                //waypoint.old_index = i;
                ZZCWaypoint * zzcWP = [[ZZCWaypoint alloc] initWithPoint:waypoint index:i];
                [self.index_Array addObject:zzcWP];
                [self.mission_Array addObject:waypoint];
            }else{
                //对于条带飞和亲些飞有不同的处理
                if (_mode == ZZCRouteMode_tiaodai) {
                    //把这些飞过一次的点全部存到一起便于绘制
                    CLLocationCoordinate2D worldWaypoint2D = CLLocationCoordinate2DMake(waypoint.coordinate.latitude, waypoint.coordinate.longitude);
                    CLLocationCoordinate2D marsWaypoint2D = [_locationChange WorldGS2MarsGS:worldWaypoint2D];
                    CLLocation * marsWaypointLoc = [[CLLocation alloc] initWithLatitude:marsWaypoint2D.latitude longitude:marsWaypoint2D.longitude];
                    [_dync_Points1 addObject:marsWaypointLoc];
                }else{
                    
                    CLLocationCoordinate2D worldWaypoint2D = CLLocationCoordinate2DMake(waypoint.coordinate.latitude, waypoint.coordinate.longitude);
                    CLLocationCoordinate2D marsWaypoint2D = [_locationChange WorldGS2MarsGS:worldWaypoint2D];
                    CLLocation * marsWaypointLoc = [[CLLocation alloc] initWithLatitude:marsWaypoint2D.latitude longitude:marsWaypoint2D.longitude];
                    
                    int realIndex;
                    if (i >= _mapController.route.beginIndex) {
                        realIndex = i - _mapController.route.beginIndex;
                    }else{
                        realIndex = _mapController.route.pointCount - i - 1;
                        
                    }
                    
                    switch ([self q_dyncPolyLine:_mapController.route.beginIndex nextIndex:realIndex pointCount:_mapController.route.pointCount]) {
                        case 1:
                            [_q_dync_Points1 addObject:marsWaypointLoc];
                            break;
                        case -1:{
                            int index = - _mapController.route.beginIndex + i + _mapController.route.beginIndex%(_mapController.route.pointCount/4);
                            NSLog(@"INDEX:%d",index);
                            [_q_dync_Points1 insertObject:marsWaypointLoc atIndex:index];
                        }
                            break;
                        case 2:
                            [_q_dync_Points2 addObject:marsWaypointLoc];
                            break;
                        case 3:
                            [_q_dync_Points3 addObject:marsWaypointLoc];
                            break;
                        case 4:
                            [_q_dync_Points4 addObject:marsWaypointLoc];
                            break;
                            
                        default:
                            break;
                    }
                    
                }
                
            }
        }
    }
    
    
    //区分完老点和新点之后需要进行点的排序保证绘制的时候不会出错
    _beginIndex = [self newBeginIndex:_mapController.route pointNum:(int)_routePlan.routeLocations.count];
    if (_mapController.route.currentIndex != -1) {
        _mission_Array = [self sort_route:_mission_Array begin_index:_beginIndex];
        _index_Array = [self sort_route:_index_Array begin_index:_beginIndex];
    }
    
    
    
    
    /********************************************
    //这里先绘制一下条带飞的老点
    //在这里声明一个数组专门存这些点的2d坐标用来绘制路线
    ************************************************/
    if (_mode == ZZCRouteMode_tiaodai) {
        [self tiaodai_huizhi];
    }
    
    
    /********************************************
     //这里先绘制一下亲些飞的老点
     //在这里声明一个数组专门存这些点的2d坐标用来绘制路线
     ************************************************/
    if (_mode == ZZCRouteMode_qinxie) {
         [self qinxie_huizhi];
    }
   
    
    
    if (_mission_Array == nil || _mission_Array.count < 2) { //DJIWaypointMissionMinimumWaypointCount is 2.
        ShowMessage(@"没有足够的航点！", @"", nil, @"OK");
        return;
    }
    
    //这一步的目的是为了求出有几条航带
    if (_mission_Array.count%99 != 0) {
        _routeNum = (int)_mission_Array.count/99 + 1;
        _saticRouteNum = _routeNum;
    }else{
        
        _routeNum = (int)_mission_Array.count/99;
        _saticRouteNum = _routeNum;
    }
    
    
    
    
    int num = (int)_mission_Array.count;
    //NSString *string1 = [[NSString alloc] initWithFormat:@"数量:%d", num];
    
    //[self showAlertViewWithTitle:@"剩余航点数量" withMessage:string1];
//    ShowResult(@"数据库：%d\n实际：%d\n航点书：%d\ncurrentIndex:%d\npointCount:%d",_mapController.route.beginIndex,_beginIndex,_mission_Array.count,_mapController.route.currentIndex,_mapController.route.pointCount);
    ShowResult(@"实际航点数为：%d",_mission_Array.count);
    
    WeakRef(weakSelf);
    
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        weakSelf.waypointConfigVC.view.alpha = 0;
    }];
}


#pragma mark - DJIGSButtonViewController Delegate Methods

/**
 *
 视图平移进出实现
 *
 **/

-(void) viewChangeBtnActionInGSButtonVC:(UIButton *)button inGSButtonVC:(DJIGSButtonViewController *)GSBtnVC{
    
    if (button.tag == 1) {
        
        [button setBackgroundImage:[UIImage imageNamed:@"右箭头"] forState:UIControlStateNormal];
        
        GSBtnVC.view.transform = CGAffineTransformMakeTranslation(-241,0);
        
        button.tag = -button.tag;
    }else{
        GSBtnVC.view.transform = CGAffineTransformMakeTranslation(0,0);
        
        button.tag = -button.tag;
        
        [button setBackgroundImage:[UIImage imageNamed:@"左箭头"] forState:UIControlStateNormal];
    }


}



/**
 *
停止任务按钮委托
 *
 **/
- (void)stopBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    [[self missionOperator] stopMissionWithCompletion:^(NSError * _Nullable error) {
        if (error){
            NSString* failedMessage = [NSString stringWithFormat:@"结束任务失败！: %@", error.description];
            ShowMessage(@"", failedMessage, nil, @"OK");
        }else
        {
            _isEditingPoints = YES;
            ShowMessage(@"", @"结束任务成功！", nil, @"OK");
        }

    }];
    

    
//    if (_mode == ZZCRouteMode_quanjin) {
//        [[self p_missionOperator] stopMissionWithCompletion:^(NSError * _Nullable error) {
//            if (error){
//                NSString* failedMessage = [NSString stringWithFormat:@"结束全景任务失败！: %@", error.description];
//                ShowMessage(@"", failedMessage, nil, @"OK");
//            }else
//            {
//                ShowMessage(@"", @"结束全景任务成功！", nil, @"OK");
//            }
//
//        }];
//    }
    
  
    
}


/**
 *
清除按钮点击委托
 *
 **/
- (void)clearBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    [self.routePlan cleanAllPointsWithMapView:self.mapView];
    [self.mapController cleanAllPointsWithMapView:self.mapView];
    [self deleteLines];
    [_contentView setHidden:YES];
}


/**
 *
飞机定位按钮委托
 *
 **/
- (void)focusMapBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    [self focusMap];
}


/**
 *
配置按钮点击委托
 *
 **/
- (void)configBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    
    //配置之前应该吧所有的航线变动保存下来
    NSString* message = [NSString stringWithFormat:@"配置之前请确认航线改动已经保存！ "];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"去保存" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *backAction;
    
    UIAlertController* alertViewController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    
    WeakRef(weakSelf);
    
        switch (self.mode) {
            case ZZCRouteMode_quanjin:
            {
                [_waypointConfigVC setModeUI:_mode height:_mapController.route.height angle:_mapController.route.angle px_CD:_mapController.route.pxChongdie hx_CD:_mapController.route.hxChongdie qinxieAngle:_mapController.route.qinxieAngle];
                
                backAction = [UIAlertAction actionWithTitle:@"已保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [UIView animateWithDuration:0.25 animations:^{
                        WeakReturn(weakSelf);
                        weakSelf.waypointConfigVC.view.alpha = 1.0;
                    }];
                }];
                
                
                //这里就先不显示出来了
            }
                break;
            case ZZCRouteMode_huanxing:
            {

                [_HR_waypointConfigVC setModeUI:_mapController.route.l_height height:_mapController.route.height px_CD:_mapController.route.pxChongdie hx_CD:_mapController.route.hxChongdie];
                
                backAction = [UIAlertAction actionWithTitle:@"已保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [UIView animateWithDuration:0.25 animations:^{
                        WeakReturn(weakSelf);
                        weakSelf.HR_waypointConfigVC.view.alpha = 1.0;
                    }];
                }];
                
                
            }
                break;
            case ZZCRouteMode_tiaodai:
            {
                [_waypointConfigVC setModeUI:_mode height:_mapController.route.height angle:_mapController.route.angle px_CD:_mapController.route.pxChongdie hx_CD:_mapController.route.hxChongdie qinxieAngle:_mapController.route.qinxieAngle];
                
                backAction = [UIAlertAction actionWithTitle:@"已保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [UIView animateWithDuration:0.25 animations:^{
                        WeakReturn(weakSelf);
                        weakSelf.waypointConfigVC.view.alpha = 1.0;
                    }];
                }];
                
                
                
            }
                break;
            case ZZCRouteMode_qinxie:
            {
                [_waypointConfigVC setModeUI:_mode height:_mapController.route.height angle:_mapController.route.angle px_CD:_mapController.route.pxChongdie hx_CD:_mapController.route.hxChongdie qinxieAngle:_mapController.route.qinxieAngle];
                
                backAction = [UIAlertAction actionWithTitle:@"已保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [UIView animateWithDuration:0.25 animations:^{
                        WeakReturn(weakSelf);
                        weakSelf.waypointConfigVC.view.alpha = 1.0;
                    }];
                }];
                
                
                
            }
                break;
            default:
                [self showAlertViewWithTitle:@"飞行模式错误" withMessage:@"未选择飞行模式"];
                break;
        }

    
    [alertViewController addAction:cancelAction];
    [alertViewController addAction:backAction];
    [self.navigationController presentViewController:alertViewController animated:YES completion: nil];
    
    
}


/**
 *
开始任务点击委托
 *
 **/
- (void)startBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC btn:(UIButton *)button
{
    
    
    if ([[self missionOperator] currentState] != DJIWaypointMissionStateReadyToExecute) {
         ShowMessage(@"开始任务失败！", @"指令正在上传请稍侯！", nil, @"OK");
//        [_slide setHidden:NO];
//        [_tfview setRoute:_mapController.route];
//        [_tfview setHidden:NO];
    }else{
        //这里应该做一个确认的工作 确认起飞吗？
        //show ask you atwice
        
        [_slide setHidden:NO];
        [_tfview setRoute:_mapController.route];
        [_tfview setHidden:NO];
        
        
        //任务开始把这些都隐藏起来
        GSBtnVC.view.transform = CGAffineTransformMakeTranslation(-241,0);
        [button setBackgroundImage:[UIImage imageNamed:@"右箭头"] forState:UIControlStateNormal];
        _taskView.transform = CGAffineTransformMakeTranslation(_taskView.frame.size.width,0);
        [_tasksBtn setHidden:NO];
        
        _mapHideView.transform = CGAffineTransformMakeTranslation(-_mapHideView.frame.size.width,0);
        [_mapShow_btn setHidden:NO];
        
    }
    
    
    
    
    
    }



/**
 *
该方法作废
 *
 **/
- (void)switchToMode:(DJIGSViewMode)mode inGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    if (mode == DJIGSViewMode_EditMode) {
        [self focusMap];
    }
    
}


/**
 *
 该方法暂时没什么实质性作用
 *
 **/
- (void)connectBtnActionInGSButtonVC:(UIButton *)button label:(UILabel *)label inGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    if (CLLocationCoordinate2DIsValid(self.userLocation)) {
        MKCoordinateRegion region = {0};
        region.center = self.userLocation;
        region.span.latitudeDelta = 0.001;
        region.span.longitudeDelta = 0.001;
        
        NSLog(@"用户位置：%f  %f",_userLocation.latitude,_userLocation.longitude);
        [self.mapView setRegion:region animated:YES];
    }

   
}


/**
 *
删除按钮点击委托
 *
 **/
-(void)deleteBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    

//    [self ZJLdeleteLocalRtu:_mapController.route];
    
    [[self missionOperator] pauseMissionWithCompletion:^(NSError * _Nullable error) {
        if (error){
            NSString* failedMessage = [NSString stringWithFormat:@"暂停任务失败！: %@", error.description];
            ShowMessage(@"", failedMessage, nil, @"OK");
        }else
        {
            _isEditingPoints = YES;
            ShowMessage(@"", @"暂停任务成功！", nil, @"OK");
        }
        
    }];


}


/**
 *
固定视图按钮点击委托
 *
 **/
-(void)fixedBtnActionInGSButtonVC:(UILabel *)label inGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{

    NSLog(@"固定按钮cliked");
    if(self.mapView.scrollEnabled == YES){
    
        self.mapView.scrollEnabled = NO;
        [label setText:@"已固定"];
    }else{
    
        self.mapView.scrollEnabled = YES;
        [label setText:@"固定"];
    }
}


/**
 *
地图类型按钮点击委托
 *
 **/
-(void)mapchangBtnActionInGSButtonVC:(UILabel *)label inGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{

    NSLog(@"地图转化按钮cliked");
    if([label.text  isEqual: @"线化地图"]){
        
        //把自定义瓦片删除
        NSArray* annos = [NSArray arrayWithArray:_mapView.overlays];
        for (int i = 0; i < annos.count; i++) {
            id<MKOverlay> ann = [annos objectAtIndex:i];
            if ([ann isKindOfClass:[ZKTileOverlay class]]) { //Add it to check if the annotation is the aircraft's and prevent it from removing
                [_mapView removeOverlay:ann];
            }
            
        }
    
        [label setText:@"卫星地图"];
        //self.mapView.mapType = MKMapTypeSatellite;
        //加涂层
        _mkTileOverlay = [self mapTileOverlay];
        //[self.mapView addOverlay:_mkTileOverlay level:MKOverlayLevelAboveRoads];
        [_mapView insertOverlay:_mkTileOverlay atIndex:0 level:MKOverlayLevelAboveRoads];
        
    }else{
        
        //把自定义瓦片删除
        NSArray* annos = [NSArray arrayWithArray:_mapView.overlays];
        for (int i = 0; i < annos.count; i++) {
            id<MKOverlay> ann = [annos objectAtIndex:i];
            if ([ann isKindOfClass:[ZKTileOverlay class]]) { //Add it to check if the annotation is the aircraft's and prevent it from removing
                [_mapView removeOverlay:ann];
            }
            
        }
    
        [label setText:@"线化地图"];
        [self.mapView removeOverlay:_mkTileOverlay];
        self.mapView.mapType = MKMapTypeStandard;
    }
  
}




    
    
    
/**
 *
上传任务点击委托
 *
 **/
-(void)uploadBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    if (_mission_Array.count>0) {
        NSLog(@"上传按钮cliked");
        
        //由于第一次可能会有多次选择起飞点  所以吧数组的排序放这儿来
        if (_mapController.route.currentIndex == -1) {
             _mission_Array = [self sort_route:_mission_Array begin_index:_beginIndex];
            _index_Array = [self sort_route:_index_Array begin_index:_beginIndex];
        }
       
        
        for (int i = 0; i < self.mission_Array.count; i++) {
            DJIWaypoint* waypoint = [self.mission_Array objectAtIndex:i];
            
            if (self.mode == ZZCRouteMode_huanxing) {
                waypoint.turnMode = DJIWaypointTurnClockwise;
                DJIWaypointAction *action = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeShootPhoto param:0];
                [waypoint addAction:action];
            }else if(self.mode == ZZCRouteMode_tiaodai){
                waypoint.altitude = [self.waypointConfigVC.altitudeTextField.text floatValue];
               //DJIWaypointAction *action1 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeRotateAircraft param:0];
                DJIWaypointAction *action = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeShootPhoto param:0];
                //[waypoint addAction:action1];
                [waypoint addAction:action];
            }else if(self.mode == ZZCRouteMode_qinxie){
                waypoint.altitude = [self.waypointConfigVC.altitudeTextField.text floatValue];
                DJIWaypointAction *action = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeShootPhoto param:0];
                [waypoint addAction:action];
                
            }else{
                //这里完成全景飞的工作好吗
                
                /*[[self p_missionOperator] setupWithMode:DJIPanoramaModeFullCircle withCompletion:^(NSError * _Nullable error) {
                 
                 if (error) {
                 NSString* uploadError = [NSString stringWithFormat:@"上传全景任务失败！:%@", error.description];
                 ShowMessage(@"", uploadError, nil, @"OK");
                 }else{
                 
                 ShowMessage(@"", @"上传全景任务成功！", nil, @"OK");
                 
                 }
                 
                 }];*/
                
                    waypoint.altitude = [self.waypointConfigVC.altitudeTextField.text floatValue];
                    //拍照-》转头-〉拍照
                    DJIWaypointAction *action1 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeShootPhoto param:0];
                    DJIWaypointAction *action2 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeRotateAircraft param:120];
                    DJIWaypointAction *action3 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeShootPhoto param:0];
                    DJIWaypointAction *action4 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeRotateAircraft param:-120];
                    DJIWaypointAction *action5 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeShootPhoto param:0];
                    DJIWaypointAction *action6 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeRotateGimbalPitch param:-60];
                    DJIWaypointAction *action7 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeShootPhoto param:0];
                    DJIWaypointAction *action8 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeRotateAircraft param:0];
                    DJIWaypointAction *action9 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeShootPhoto param:0];
                    DJIWaypointAction *action10 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeRotateAircraft param:120];
                    DJIWaypointAction *action11 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeShootPhoto param:0];
                    DJIWaypointAction *action12 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeRotateGimbalPitch param:-90];
                    DJIWaypointAction *action13 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeShootPhoto param:0];
                    DJIWaypointAction *action14 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeRotateAircraft param:-120];
                    DJIWaypointAction *action15 = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeShootPhoto param:0];
                    
                    
                    [waypoint addAction:action1];
                    [waypoint addAction:action2];
                    [waypoint addAction:action3];
                    [waypoint addAction:action4];
                    [waypoint addAction:action5];
                    [waypoint addAction:action6];
                    [waypoint addAction:action7];
                    [waypoint addAction:action8];
                    [waypoint addAction:action9];
                    [waypoint addAction:action10];
                    [waypoint addAction:action11];
                    [waypoint addAction:action12];
                    [waypoint addAction:action13];
                    [waypoint addAction:action14];
                    [waypoint addAction:action15];
                    
                
                            }
            
            
        }
        
        int weiba = _mission_Array.count%99;//剩下的99整除之外的尾巴
        int indez = (int)_mission_Array.count - (_routeNum - 1)*99 - weiba;//存入mission点开始的index
        int leftNum = (_routeNum - 1)*99 + weiba;//总共还剩下的点
        
        //这一句是为判断刚好是99的整数倍的时候怎么算
        if (weiba == 0) {
            weiba = 99;
        }else{
            
            weiba = weiba;
        }
        
        if (_routeNum > 1) {
            leftNum = 99;//航线不止一条就循环99个点
        }else{
            leftNum = weiba;//航线就只有一条
            
        }
        
        //循环添加点进入到waypointmission
        for (int i = indez; i < (indez + leftNum); i++) {
            DJIWaypoint * point = [_mission_Array objectAtIndex:i];
            [_waypointMission addWaypoint:point];
        }
        
        self.waypointMission.maxFlightSpeed = [self.waypointConfigVC.maxFlightSpeedTextField.text floatValue];
        self.waypointMission.autoFlightSpeed = [self.waypointConfigVC.autoFlightSpeedTextField.text floatValue];
        self.waypointMission.headingMode = (DJIWaypointMissionHeadingMode)self.waypointConfigVC.headingSegmentedControl.selectedSegmentIndex;
        if (_routeNum > 1) {
            //如果还有航线就先误动作等待下一步指令
            [self.waypointMission setFinishedAction:DJIWaypointMissionFinishedNoAction];
        }else{
            [self.waypointMission setFinishedAction:(DJIWaypointMissionFinishedAction)self.waypointConfigVC.actionSegmentedControl.selectedSegmentIndex];
        }
        
        
        //航线操作者来加载航线
        [[self missionOperator] loadMission:self.waypointMission];
        
        WeakRef(target);
        
        [[self missionOperator] addListenerToFinished:self withQueue:dispatch_get_main_queue() andBlock:^(NSError * _Nullable error) {
            
            WeakReturn(target);
            
            if (error) {
                //飞行结束了可以编辑了
                target.isEditingPoints = YES;
                [target setEditMode:_isEditingPoints];
                //异常情况数据库保持为-1进度
                _mapController.route.currentIndex = -1;
                [self updateWithRoute:_mapController.route];
                //飞行任务结束 清空动态航线的数据
                [_dync_Points1 removeAllObjects];
                [_q_dync_Points1 removeAllObjects];
                [_q_dync_Points2 removeAllObjects];
                [_q_dync_Points3 removeAllObjects];
                [_q_dync_Points4 removeAllObjects];
                
                [target showAlertViewWithTitle:@"任务结束失败！" withMessage:[NSString stringWithFormat:@"%@", error.description]];
            }
            else if(!error){
                
                switch (_mode) {
                    case ZZCRouteMode_qinxie:
                    {
                        int realIndex = 0;
                        ZZCWaypoint * zzcWP = [_index_Array objectAtIndex:_pointIndexNow];
                        
                        if (zzcWP.index >= _mapController.route.beginIndex) {
                            realIndex = zzcWP.index - _mapController.route.beginIndex;
                        }else{
                            realIndex = _mapController.route.pointCount - zzcWP.index - 1;
                            
                        }
                        
                        
                        [self qinxie_LineView:_mapController.route.beginIndex realIndex:realIndex pointCount:_mapController.route.pointCount];
                    }
                        break;
                    case ZZCRouteMode_tiaodai:
                        [self tiaodai_LineView:_beginIndex realIndex:_pointIndexNow pointCount:(int)_mission_Array.count];
                        break;
                    case ZZCRouteMode_huanxing:
                        [self tiaodai_LineView:_beginIndex realIndex:_pointIndexNow pointCount:(int)_mission_Array.count];
                        break;
                    case ZZCRouteMode_quanjin:
                        
                        break;
                        
                    default:
                        break;
                }
                
                if (_routeNum == 0) {
                    
                    //飞行结束了可以编辑了
                    target.isEditingPoints = YES;
                    [target setEditMode:_isEditingPoints];
                    //飞行结束了进行进度匹配
                    [self updateWithRoute:_mapController.route];
                    //飞行任务结束 清空动态航线的数据
                    [_dync_Points1 removeAllObjects];
                    [_q_dync_Points1 removeAllObjects];
                    [_q_dync_Points2 removeAllObjects];
                    [_q_dync_Points3 removeAllObjects];
                    [_q_dync_Points4 removeAllObjects];
                    
                    [target showAlertViewWithTitle:@"任务执行完成！" withMessage:nil];
                    
                }else{
                    
                    
                    //首先要移除上一次的航点
                    [target.waypointMission removeAllWaypoints];
                    
                    //这里进来的话就说明还有航线没处理完所以接着处理
                    int weiba = _mission_Array.count%99;//剩下的99整除之外的尾巴
                    int indez = (int)_mission_Array.count - (_routeNum - 1)*99 - weiba;//存入mission点开始的index
                    int leftNum = (_routeNum - 1)*99 + weiba;//总共还剩下的点
                    
                    //这一句是为判断刚好是99的整数倍的时候怎么算
                    if (weiba == 0) {
                        weiba = 99;
                    }else{
                        
                        weiba = weiba;
                    }
                    
                    if (_routeNum > 1) {
                        leftNum = 99;//航线不止一条就循环99个点
                    }else{
                        leftNum = weiba;//航线就只有一条
                        
                    }
                    
                    //循环添加点进入到waypointmission
                    for (int i = indez; i < (indez + leftNum); i++) {
                        DJIWaypoint * point = [target.mission_Array objectAtIndex:i];
                        [target.waypointMission addWaypoint:point];
                    }
                    
                    target.waypointMission.maxFlightSpeed = [target.waypointConfigVC.maxFlightSpeedTextField.text floatValue];
                    target.waypointMission.autoFlightSpeed = [target.waypointConfigVC.autoFlightSpeedTextField.text floatValue];
                    target.waypointMission.headingMode = (DJIWaypointMissionHeadingMode)target.waypointConfigVC.headingSegmentedControl.selectedSegmentIndex;
                    if (target.routeNum > 1) {
                        //如果还有没费玩的就先不回来
                        [target.waypointMission setFinishedAction:DJIWaypointMissionFinishedNoAction];
                    }else{
                        [target.waypointMission setFinishedAction:(DJIWaypointMissionFinishedAction)target.waypointConfigVC.actionSegmentedControl.selectedSegmentIndex];
                    }
                    //航线操作者来加载航线
                    [[target missionOperator] loadMission:target.waypointMission];
                    //航线操作者来上传任务
                    [[target missionOperator] uploadMissionWithCompletion:^(NSError * _Nullable error) {
                        if (error){
                            NSString* uploadError = [NSString stringWithFormat:@"上传下一阶段任务失败！:%@", error.description];
                            ShowMessage(@"", uploadError, nil, @"OK");
                        }else {
                            
                            ShowMessage(@"", @"前一阶段完成，上传下一阶段任务成功！", nil, @"OK");
                        }
                    }];
                    
                    //任务操作者开始任务
                    [target startMission];
                }
                
                
            }
        }];
        
        
        
        
        
        [[self missionOperator] uploadMissionWithCompletion:^(NSError * _Nullable error) {
            if (error){
                NSString* uploadError = [NSString stringWithFormat:@"上传任务失败！:%@", error.description];
                ShowMessage(@"", uploadError, nil, @"OK");
            }else {
                
                //假如上传任务成功就需要剪去一条航线 这句话放在这里又是偏颇 如果有人手贱点了好几下不是GG
                //_routeNum = _routeNum - 1;
                
                ShowMessage(@"", @"任务正在上传，请稍侯！", nil, @"OK");
                
                
            }
        }];
    }else{
    
        ShowMessage(@"", @"没有航点，先配置一下！", nil, @"OK");
    }
    


}


//由于开始任务存在一定几率失败 所以加一个控制迭代

- (void) startMission{

    
    
    //任务操作者开始任务
    [[self missionOperator] startMissionWithCompletion:^(NSError * _Nullable error) {
        if (error){
            
            NSString* message = [NSString stringWithFormat:@"开始任务失败了，咋办啊？ "];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"算了" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *backAction = [UIAlertAction actionWithTitle:@"再试试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self startMission];
                
            }];
            
            UIAlertController* alertViewController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
            [alertViewController addAction:cancelAction];
            [alertViewController addAction:backAction];
            [self presentViewController:alertViewController animated:YES completion:nil];
        }else
        {
            //假如开始任务成功就需要剪去一条航线
            _routeNum = _routeNum - 1;
            ShowMessage(@"", @"下一阶段任务开始！", nil, @"OK");
            
            return ;
        }
    }];

}

/**
视频按钮点击委托
 *
 **/
-(void)videoBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    NSLog(@"视频按钮cliked");
    UIStoryboard * vb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DefaultLayoutViewController* videoVC = [vb instantiateViewControllerWithIdentifier:@"videoVC"];
    [self.navigationController pushViewController:videoVC animated:YES];
    
//    zzcFPVViewController* fpvVC = [vb instantiateViewControllerWithIdentifier:@"FPVvc"];
//    [self.navigationController pushViewController:fpvVC animated:YES];

}



/**
 *
该方法作废 暂时没用
 *
 **/
-(void)syncBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    NSLog(@"同步按钮cliked");
    
    
    [[self missionOperator] resumeMissionWithCompletion:^(NSError * _Nullable error) {
        if (error){
            NSString* failedMessage = [NSString stringWithFormat:@"继续任务失败！: %@", error.description];
            ShowMessage(@"", failedMessage, nil, @"OK");
        }else
        {
            _isEditingPoints = YES;
            ShowMessage(@"", @"继续任务成功！", nil, @"OK");
        }
        
    }];
    
    
    
    

}

#pragma mark getCurentTime
//获取当前的时间

+(NSString*)getCurrentTimes{
    NSDate *date = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSString *DateTime = [formatter stringFromDate:date];
    
    return DateTime;
    
}


#pragma mark - UItableViewDelegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([tableView isEqual:_mapTableView]) {
        NSLog(@"地图数量：%lu",(unsigned long)_map_Array.count);
        return _map_Array.count;
    }
    
    if ([tableView isEqual:_taskTableView]) {
        NSLog(@"航线数量：%lu",(unsigned long)_route_Array.count);
         return _route_Array.count;
    }
    
    
   
    return 0;

}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if([tableView isEqual:_mapTableView]){
        
        static NSString *CellIdentifier = @"mapIdentify";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        
        //[cell setBackgroundColor:[[UIColor alloc]initWithRed:12 green:13 blue:15 alpha:1]];
        [cell setBackgroundColor:UIColor.blackColor];
        
        
        
        
        
        LocalMap * map = [_map_Array objectAtIndex:indexPath.row];
        cell.textLabel.text = map.name;
        if (map.statuscode == 0) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ 未下载",map.time];
        }
        if (map.statuscode == 1) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ 已下载",map.time];
        }
        if (map.statuscode == -1) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ 下载中",map.time];
        }
        
        
        [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
        cell.textLabel.textColor =  [UIColor whiteColor];
        
        [cell.detailTextLabel setAdjustsFontSizeToFitWidth:YES];
        cell.detailTextLabel.textColor =  [UIColor whiteColor];
        
        return cell;
    }
    
    
    if ([tableView isEqual:_taskTableView]) {
        static NSString *CellIdentifier = @"taskIdentify";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        
        //[cell setBackgroundColor:[[UIColor alloc]initWithRed:12 green:13 blue:15 alpha:1]];
        [cell setBackgroundColor:UIColor.blackColor];
        
        
        
        
        
        sqliteRoute * route = [_route_Array objectAtIndex:indexPath.row];
        cell.textLabel.text = route.route_name;
        cell.detailTextLabel.text = route.time;
        
        [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
        cell.textLabel.textColor =  [UIColor whiteColor];
        
        [cell.detailTextLabel setAdjustsFontSizeToFitWidth:YES];
        cell.detailTextLabel.textColor =  [UIColor whiteColor];
        
        return cell;
    }
    
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZC"];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    
    if ([tableView isEqual:_taskTableView]) {
        if ([[self missionOperator] currentState] != DJIWaypointMissionStateExecuting) {
            NSLog(@"点击了第%ld行",(long)indexPath.row);
            _route_Array = [self selectWithRtu];
            
            
            
            [_mapController cleanAllPointsWithMapView:_mapView];
            [_routePlan cleanAllPointsWithMapView:_mapView];
            [self deleteLines];
            
            _mapController.route = [_route_Array objectAtIndex:indexPath.row];
            
            
            
            
            if (_mapController.route.point_array.count > 0) {
                
                for (int i = 0 ; i < _mapController.route.point_array.count; i++) {
                    sqlitePoint * point = [_mapController.route.point_array objectAtIndex:i];
                    CLLocation * location = [[CLLocation alloc] initWithLatitude:point.point_x longitude:point.point_y];
                    [_mapController.editPoints addObject:location];
                }
                
                switch (_mode) {
                    case ZZCRouteMode_quanjin:{
                        
                        
                        [_mapController setPointView:_mapController.editPoints withMapView:_mapView];
                        CLLocation * location = [_mapController.editPoints objectAtIndex:0];
                        if (CLLocationCoordinate2DIsValid([self.locationChange WorldGS2MarsGS:location.coordinate])) {
                            MKCoordinateRegion region = {0};
                            region.center = [self.locationChange WorldGS2MarsGS:location.coordinate];
                            region.span.latitudeDelta = 0.001;
                            region.span.longitudeDelta = 0.001;
                            
                            [self.mapView setRegion:region animated:YES];
                        }
                    }
                        break;
                    case ZZCRouteMode_tiaodai:
                        [_mapController setPointView:_mapController.editPoints withMapView:_mapView];
                        [_mapController setMiddlePoint:_mapController.editPoints withMapView:_mapView];
                        _centerCoor =  [_mapController setPolygonView1:_mapController.editPoints withMapView:_mapView withCenterView:_contentView withCenterCoor:_centerCoor];
                        break;
                    case ZZCRouteMode_qinxie:
                        [_mapController setPointView:_mapController.editPoints withMapView:_mapView];
                        [_mapController setMiddlePoint:_mapController.editPoints withMapView:_mapView];
                        _centerCoor =  [_mapController setPolygonView1:_mapController.editPoints withMapView:_mapView withCenterView:_contentView withCenterCoor:_centerCoor];
                        [_routePlan fetchAllqinxieRound:_mapController.editPoints];
                        [_mapController setqinxiePolygonView:_routePlan.westLocations northPoints:_routePlan.northLocations eastPoints:_routePlan.eastLocations southPoints:_routePlan.southLocations withMapView:_mapView];
                        break;
                    case ZZCRouteMode_huanxing:
                        [_mapController setPointView:_mapController.editPoints withMapView:_mapView];
                        _centerCoor =  [_mapController setPolygonView1:_mapController.editPoints withMapView:_mapView withCenterView:_contentView withCenterCoor:_centerCoor];
                        break;
                        
                    default:
                        break;
                }
                
                
                //如果这条航线是个老油子
                if (_mapController.route.currentIndex != -1) {
                    if (_mapController.route.currentIndex < _mapController.route.pointCount - 1) {
                        _oldPointsNum = _mapController.route.currentIndex + 1;
                        //ShowMessage(@"检测该航线有历史数据，若要继续该航线请点击配置！", nil, nil, @"OK");
                        ShowResult(@"检测该航线有历史数据，若要继续该航线请点击配置！\ncurrentIndex:%d",_mapController.route.currentIndex);
                    }else{
                        
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"这条航线已经飞完了哦！再来一次请再次点选任务" preferredStyle:UIAlertControllerStyleAlert];
                        
                        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            
                            NSLog(@"点击取消");
                            
                        }]];
                        [alertController addAction:[UIAlertAction actionWithTitle:@"再来一次" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            
                            _mapController.route.beginIndex = 0;
                            _mapController.route.currentIndex = -1;
                            [self updateWithRoute:_mapController.route];
                            _oldPointsNum = 0;
                            
                            
                        }]];
                        
                        [self.navigationController presentViewController:alertController animated:YES completion:nil];
                    }
                    
                    
                }else{
                    _oldPointsNum = 0;
                    ShowMessage(@"这条航线还没有飞过哦！！", nil, nil, @"OK");
                    
                }
            }
        }
    }else{
        
        NSLog(@"点击了第%ld行",(long)indexPath.row);
        LocalMap * map = [_map_Array objectAtIndex:indexPath.row];
        if (map.statuscode == 1) {
            
            //删除原来的overlay
            NSArray* annos = [NSArray arrayWithArray:_mapView.overlays];
            for (int i = 0; i < annos.count; i++) {
                id<MKOverlay> ann = [annos objectAtIndex:i];
                if ([ann isKindOfClass:[ZKTileOverlay class]]) { //Add it to check if the annotation is the aircraft's and prevent it from removing
                    [_mapView removeOverlay:ann];
                }
                
            }
            
            //已下载 进行地图显示
                    ZKTileOverlay * tile = [[ZKTileOverlay alloc] initWithArray:[self str2array:map.url]];
            
            //MKTileOverlay * test_Tiile = [[MKTileOverlay alloc] ]
            
            //MKTileOverlay * tile = [[MKTileOverlay alloc] initWithURLTemplate:@"http://mt0.google.cn/maps/vt?lyrs=s@773&gl=cn&x=84056&y=203240&z=19"];
//            NSLog(@"URL是什么：%@",tile.URLTemplate);
                    [_mapView addOverlay:tile];
            MKCoordinateRegion region = {0};
            if (CLLocationCoordinate2DIsValid(map.coor)) {
                region.center = map.coor;
                region.span.latitudeDelta = 0.001;
                region.span.longitudeDelta = 0.001;
                [_mapView setRegion:region animated:YES];
            }
            
            
        }
        if (map.statuscode == 0) {
            //未下载
            ShowResult(@"瓦片地图还没有下载哦！");
        }
        if (map.statuscode == -1) {
            //下载中
            ShowResult(@"瓦片地图正在下载中哦！");
        }
    }
    
    
}

//tableView自带的左滑删除

//tableView自带的左滑删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {



    if (indexPath.section == 0) {

        return YES;

    }

    return NO;
}
// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    return UITableViewCellEditingStyleDelete;
}
// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete && [tableView isEqual:_taskTableView]) {

        
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:_taskTableView]) {
        
        //添加一个删除按钮
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:(UITableViewRowActionStyleDestructive) title:@"编辑" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            
            ZQAlterField *alertView = [ZQAlterField alertView];
            
            alertView.placeholder = @"请输入新名称";
            
            alertView.title = @"修改航线名称";
            
            [alertView ensureClickBlock:^(NSString *inputString) {
                
                sqliteRoute * rtu = [_route_Array objectAtIndex:indexPath.row];
                rtu.time = [DJIRootViewController getCurrentTimes];
                rtu.route_name = inputString;
                UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
                [cell.textLabel setText:inputString];
                [cell.detailTextLabel setText:rtu.time];
                [self updataWithStu:rtu];
                [self updateWithRoute:rtu];
                NSLog(@"输入内容为%@",inputString);
                
                
            }];
            
            [alertView show];
            
            NSLog(@"ZCZC大帅哥！");
            
        }];
        //删除按钮颜色
        deleteAction.backgroundColor = [UIColor cyanColor];
        //添加一个置顶按钮
        UITableViewRowAction *topRowAction =[UITableViewRowAction rowActionWithStyle:(UITableViewRowActionStyleDestructive) title:@"删除"handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            
            sqliteRoute * rtu = [_route_Array objectAtIndex:indexPath.row];
            [self ZJLdeleteLocalRtu:rtu];
            
            
        }];
        //置顶按钮颜色
        topRowAction.backgroundColor = [UIColor magentaColor];
        
        //将设置好的按钮方到数组中返回
        return @[deleteAction,topRowAction];
    }else{
        
        
        //添加一个删除按钮
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:(UITableViewRowActionStyleDestructive) title:@"编辑" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            
            ZQAlterField *alertView = [ZQAlterField alertView];
            
            alertView.placeholder = @"请输入新名称";
            
            alertView.title = @"修改地图名称";
            
            [alertView ensureClickBlock:^(NSString *inputString) {
                
                LocalMap * map = [_map_Array objectAtIndex:indexPath.row];
                map.time = [DJIRootViewController getCurrentTimes];
                map.name = inputString;
                UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
                [cell.textLabel setText:inputString];
                [cell.detailTextLabel setText:map.time];
                [self updateLocalMap:map];
                NSLog(@"输入内容为%@",inputString);
                
                
            }];
            
            [alertView show];
            
            NSLog(@"ZCZC大帅哥！");
            
        }];
        //删除按钮颜色
        deleteAction.backgroundColor = [UIColor cyanColor];
        //添加一个置顶按钮
        UITableViewRowAction *topRowAction =[UITableViewRowAction rowActionWithStyle:(UITableViewRowActionStyleDestructive) title:@"删除"handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            
            LocalMap * map1 = [_map_Array objectAtIndex:indexPath.row];
            [self deleteLocalMap:map1];
            NSArray* annos = [NSArray arrayWithArray:_mapView.overlays];
            for (int i = 0; i < annos.count; i++) {
                id<MKOverlay> ann = [annos objectAtIndex:i];
                if ([ann isKindOfClass:[ZKTileOverlay class]]) { //Add it to check if the annotation is the aircraft's and prevent it from removing
                    [_mapView removeOverlay:ann];
                }
                
            }
            
            
        }];
        //置顶按钮颜色
        topRowAction.backgroundColor = [UIColor magentaColor];
        
        //添加一个置顶按钮
        UITableViewRowAction *downloadRowAction =[UITableViewRowAction rowActionWithStyle:(UITableViewRowActionStyleDestructive) title:@"下载"handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            
///
            //这里需要写一个下载瓦片的方法
            LocalMap * map = [_map_Array objectAtIndex:indexPath.row];
            map.statuscode = -1;
            [self updateLocalMap:map];
            
            NSMutableArray * urls = [self str2array:map.url];
            NSMutableArray * localUrls = [[NSMutableArray alloc] init];
            if ([[zzcAFN internetStauts] isEqualToString:@"NONE"] ) {
                //无网络还下载个屁啊
                ShowResult(@"网络请求失败");
                 map.statuscode = 0;
                [self updateLocalMap:map];
                
            }else{
                
                [self AFNdownloadWapian:urls localUrls:localUrls map:map];
                
            }
            
            // AFNdownloadWapian 这里需要做一些视图上的表示
            
            //2019 3.26改
//            map.url = [self array2str:localUrls];
//            [self updateLocalMap:map];

            
        }];
        //置顶按钮颜色
        downloadRowAction.backgroundColor = [UIColor orangeColor];
        
        LocalMap * map4 = [_map_Array objectAtIndex:indexPath.row];
        if (map4.statuscode == 1) {
            //将设置好的按钮方到数组中返回
            return @[deleteAction,topRowAction];
        }else if(map4.statuscode == 0){
            //未下载
            return @[deleteAction,topRowAction,downloadRowAction];
        }else{
            
            //下载中
            return nil;
        }
        
        
    }
    
    


}

//// 修改编辑按钮文字
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
//
////    if ([tableView isEqual:_taskTableView]) {
////        return @"编辑";
////    }else{
////
////        return @"";
////    }
//
//}



#pragma mark - CLLocationManagerDelegate

/**
 *
定位管理委托方法方法——位置更新
 *
 **/
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    //NSLog(@"OLD_lat:%f OLD_lon%f",location.coordinate.latitude,location.coordinate.longitude);
    self.userLocation = [self.locationChange WorldGS2MarsGS:location.coordinate];
    //NSLog(@"NEW_lat:%f NEW_lon%f",self.userLocation.latitude,self.userLocation.longitude);
    [self.mapController updateUserLocation:self.userLocation withMapView:self.mapView];
}

/**
 *
 定位管理委托方法方法——用户朝向与显示
 *
 **/
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    
    UIDeviceOrientation duration = [[UIDevice currentDevice] orientation];
    // 将设备的方向角度换算成弧度
    double headings = 1.0f * M_PI * newHeading.trueHeading / 180.0f;
    [self.mapController updateUserHeading:headings];
    
    
    switch (duration) {
        case UIDeviceOrientationLandscapeLeft:
            [self.mapController updateUserHeading:headings];
            break;
        case UIDeviceOrientationLandscapeRight:
            [self.mapController updateUserHeading:headings];
            break;
        case UIDeviceOrientationPortrait:
            [self.mapController updateUserHeading:headings];
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            [self.mapController updateUserHeading:headings];
            break;
            
        default:
            break;
    }
    
    

}



#pragma mark MKMapViewDelegate Method

-(void) mapViewDidFinishLoadingMap:(MKMapView *)mapView{

    /*if (_loadOrNot) {
        [self initRoute];
    }*/
    
}


/**
 *
 mapview标注样式设定
 *
 **/
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        MKPinAnnotationView* pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin_Annotation"];
        pinView.pinTintColor = [UIColor purpleColor];
        pinView.draggable = YES;
        pinView.canShowCallout = YES;
        
        
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        rightButton.backgroundColor = [UIColor grayColor];
        [rightButton setTitle:@"删除" forState:UIControlStateNormal];
        pinView.rightCalloutAccessoryView = rightButton;
        
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        leftButton.backgroundColor = [UIColor grayColor];
        [leftButton setTitle:@"取消" forState:UIControlStateNormal];
        pinView.leftCalloutAccessoryView = leftButton;
        
        return pinView;
        
    }else if ([annotation isKindOfClass:[DJIAircraftAnnotation class]])
    {
        DJIAircraftAnnotationView* annoView = [[DJIAircraftAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Aircraft_Annotation"];
        ((DJIAircraftAnnotation*)annotation).annotationView = annoView;
        return annoView;
    }else if ([annotation isKindOfClass:[DJIUserAnnotation class]])
    {
        DJIUserAnnotationView* annoView = [[DJIUserAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"User_Annotation"];
        ((DJIUserAnnotation*)annotation).annotationView = annoView;
        return annoView;
    }else if ([annotation isKindOfClass:[DJIRouteAnnotion class]])
    {
        DJIRouteAnnotionView* annoView = [[DJIRouteAnnotionView alloc] initWithAnnotation:annotation reuseIdentifier:@"Route_Annotation"];
        ((DJIRouteAnnotion*)annotation).annotationView = annoView;
        return annoView;
    }
    else if ([annotation isKindOfClass:[ZZCMiddleAnnotaion class]])
    {
        MKAnnotationView * annoView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Middle_Annotation"];
        annoView.image = [UIImage imageNamed:@"jiahao"];
        annoView.draggable = NO;
        return annoView;
    }else if ([annotation isKindOfClass:[DJIBeginPointAnnotation class]])
    {
        DJIBeginPointAnnotationView* annoView = [[DJIBeginPointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Begin_Annotation"];
        ((DJIBeginPointAnnotation*)annotation).annotationView = annoView;
        return annoView;
    }else if ([annotation isKindOfClass:[WapianAnnotation class]])
    {

        WapianAnnotationView* annoView = [[WapianAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Wapian_Annotation"];
        ((WapianAnnotation*)annotation).annotationView = annoView;
        
        return annoView;
    }
    
    return nil;
}



/**
 *
mapview Annotation探出气泡点击事件
 *
 **/
- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{

    if ([view isKindOfClass:[MKPinAnnotationView class]]) {
        if (control == view.rightCalloutAccessoryView && _isEditingPoints==YES) {
            NSLog(@"气泡右按钮cliked");
            
            
            //如果航点已经被渲染了那么首先要删除这些原先的渲染
            
            [_routePlan cleanAllPointsWithMapView:_mapView];
            
            
            if (_mapController.editPoints.count <= 3&&_mode != ZZCRouteMode_quanjin) {
                [self showAlertViewWithTitle:@"提示" withMessage:@"就三个点了别删了，直接点清除吧！"];
            }else{
                
                //先确定是那个annotion被点击了 确定其在数组editPoints中的下标
                double res;
                CLLocationCoordinate2D destCoordinate=view.annotation.coordinate;
                CLLocationCoordinate2D changedcoordinate = [self.locationChange MarsGS2WorldGS:destCoordinate];
                CLLocation *location = [[CLLocation alloc] initWithLatitude:changedcoordinate.latitude longitude:changedcoordinate.longitude];
                NSLog(@"location_lat:%f",location.coordinate.latitude);
                CLLocation * oldlocation1 = [self.mapController.editPoints objectAtIndex:0];
                res = fabs(oldlocation1.coordinate.latitude - location.coordinate.latitude) + fabs(oldlocation1.coordinate.longitude - location.coordinate.longitude);
                for (int i = 0; self.mapController.editPoints != nil&&i < self.mapController.editPoints.count; i++) {
                    CLLocation * oldlocation = [self.mapController.editPoints objectAtIndex:i];
                    NSLog(@"i=%d oldlocation_lat = %f",i,oldlocation.coordinate.latitude);
                    double temp = fabs(location.coordinate.latitude - oldlocation.coordinate.latitude) + fabs(location.coordinate.longitude - oldlocation.coordinate.longitude);
                    _DragPointIndex = res >= temp?i:_DragPointIndex;
                    res = res >= temp?temp:res;
                }
                NSLog(@"index:%d",_DragPointIndex);
                
                
                sqlitePoint * point = [_mapController.route.point_array objectAtIndex:_DragPointIndex];
                
                NSString *sqlite1 = [NSString stringWithFormat:@"delete from final_points where id = '%d'",point.Id];
                char *error1 = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
                int result1 = sqlite3_exec(_routeDB, [sqlite1 UTF8String], nil, nil, &error1);
                if (result1 == SQLITE_OK) {
                    NSLog(@"删除航点数据成功");
                } else {
                    NSLog(@"删除航点数据失败%s",error1);
                }
                
                _route_Array = [self selectWithRtu];
                
                //删除地图上的ANN
                [self.mapView removeAnnotation:view.annotation];
                [self.mapController.editPoints removeObjectAtIndex:_DragPointIndex];
                [_mapController.route.point_array removeObjectAtIndex:_DragPointIndex];
                
                
                switch (_mode) {
                    case ZZCRouteMode_tiaodai:
                        _centerCoor = [self.mapController setPolygonView:self.mapController.editPoints withMapView:self.mapView withCenterView:_contentView withCenterCoor:_centerCoor];
                        [self.mapController setMiddlePoint:self.mapController.editPoints withMapView:self.mapView];
                        //[self.routePlan updateRouteView:self.mapController.editPoints withMapView:self.mapView];
                        break;
                    case ZZCRouteMode_huanxing:
                        _centerCoor = [self.mapController setPolygonView:self.mapController.editPoints withMapView:self.mapView withCenterView:_contentView withCenterCoor:_centerCoor];
                        
                        break;
                    case ZZCRouteMode_qinxie:
                        [self.mapController setMiddlePoint:self.mapController.editPoints withMapView:self.mapView];
                        [_routePlan.westLocations removeObjectAtIndex:_DragPointIndex];
                        [_routePlan.eastLocations removeObjectAtIndex:_DragPointIndex];
                        [_routePlan.northLocations removeObjectAtIndex:_DragPointIndex];
                        [_routePlan.southLocations removeObjectAtIndex:_DragPointIndex];
                        
                        [_mapController setqinxiePolygonView:_routePlan.westLocations northPoints:_routePlan.northLocations eastPoints:_routePlan.eastLocations southPoints:_routePlan.southLocations withMapView:_mapView];
                        break;
                        
                    default:
                        break;
                }
                
                
                [self newRouteLine];
                
            }
        }
        if (control == view.leftCalloutAccessoryView) {
            NSLog(@"气泡左按钮cliked");
            
        }
    }
}

/**
 *
annotation点击事件
 *
 **/
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{


    if ([view.reuseIdentifier  isEqual: @"Middle_Annotation"] && _isEditingPoints==YES) {
        
        ZZCMiddleAnnotaion * midAnn = view.annotation;
        CLLocationCoordinate2D wordMid = [self.locationChange MarsGS2WorldGS:view.annotation.coordinate];
        CLLocation* wordLoc = [[CLLocation alloc] initWithLatitude:wordMid.latitude longitude:wordMid.longitude];
        
        if (_mode == ZZCRouteMode_qinxie) {
            CLLocation * westLoc1 = [_routePlan.westLocations objectAtIndex:midAnn.index - 1];
            CLLocation * westLoc2 = [_routePlan.westLocations objectAtIndex:midAnn.index];
            CLLocation * westLoc = [[CLLocation alloc] initWithLatitude:(westLoc1.coordinate.latitude + westLoc2.coordinate.latitude)/2 longitude:(westLoc1.coordinate.longitude + westLoc2.coordinate.longitude)/2];
            [_routePlan.westLocations insertObject:westLoc atIndex:midAnn.index];
            
            CLLocation * eastLoc1 = [_routePlan.eastLocations objectAtIndex:midAnn.index - 1];
            CLLocation * eastLoc2 = [_routePlan.eastLocations objectAtIndex:midAnn.index];
            CLLocation * eastLoc = [[CLLocation alloc] initWithLatitude:(eastLoc1.coordinate.latitude + eastLoc2.coordinate.latitude)/2 longitude:(eastLoc1.coordinate.longitude + eastLoc2.coordinate.longitude)/2];
            [_routePlan.eastLocations insertObject:eastLoc atIndex:midAnn.index];
            
            CLLocation * northLoc1 = [_routePlan.northLocations objectAtIndex:midAnn.index - 1];
            CLLocation * northLoc2 = [_routePlan.northLocations objectAtIndex:midAnn.index];
            CLLocation * northLoc = [[CLLocation alloc] initWithLatitude:(northLoc1.coordinate.latitude + northLoc2.coordinate.latitude)/2 longitude:(northLoc1.coordinate.longitude +  northLoc2.coordinate.longitude)/2];
            [_routePlan.northLocations insertObject:northLoc atIndex:midAnn.index];
            
            CLLocation * southLoc1 = [_routePlan.southLocations objectAtIndex:midAnn.index - 1];
            CLLocation * southLoc2 = [_routePlan.southLocations objectAtIndex:midAnn.index];
            CLLocation * southLoc = [[CLLocation alloc] initWithLatitude:(southLoc1.coordinate.latitude + southLoc2.coordinate.latitude)/2 longitude:(southLoc1.coordinate.longitude + southLoc2.coordinate.longitude)/2];
            [_routePlan.southLocations insertObject:southLoc atIndex:midAnn.index];
        }
        
        
        [self.mapController.editPoints insertObject:wordLoc atIndex:midAnn.index];
        sqlitePoint * point1 = [[sqlitePoint alloc] init];
        sqlitePoint * temp = [_mapController.route.point_array objectAtIndex:0];
        point1.point_x = wordLoc.coordinate.latitude;
        point1.point_y = wordLoc.coordinate.longitude;
        point1.route_Id = temp.route_Id;
        [_mapController.route.point_array insertObject:point1 atIndex:midAnn.index];
        
        
        
        for (int i = 0; i < _mapController.route.point_array.count; i++) {
            sqlitePoint * point = [_mapController.route.point_array objectAtIndex:i];
            point.index = i;
        }
        
        sqlitePoint* insert_point = [_mapController.route.point_array objectAtIndex:midAnn.index];
        NSString *sqlite1 = [NSString stringWithFormat:@"insert into final_points(id,route_id,point_index,point_x,point_y) values (NULL,'%d','%d','%f','%f')",insert_point.route_Id,insert_point.index,insert_point.point_x,insert_point.point_y];
        char *error = NULL;//执行sqlite语句失败的时候,会把失败的原因存储到里面
        int result = sqlite3_exec(_routeDB, [sqlite1 UTF8String], nil, nil, &error);
        if (result == SQLITE_OK) {
            NSLog(@"添加数据至航点表成功");
            insert_point.Id = (int)sqlite3_last_insert_rowid(_routeDB);
           [self updataWithStu:_mapController.route];
            _mapController.route.xiugaimei = YES;
        } else {
            NSLog(@"添加数据至航点表失败");
        }
        
        
        MKPointAnnotation* annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = midAnn.coordinate;
        NSString *string1 = [[NSString alloc] initWithFormat:@"纬度:%f", annotation.coordinate.latitude];
        NSString *string2 = [[NSString alloc] initWithFormat:@"经度:%f", annotation.coordinate.longitude];
        [annotation setTitle:string1];
        [annotation setSubtitle:string2];
        [mapView addAnnotation:annotation];
        [self.mapController setMiddlePoint:self.mapController.editPoints withMapView:self.mapView];
        
        [self newRouteLine];
        
    }else if ([view.reuseIdentifier  isEqual: @"Route_Annotation"]){
    
       
        
        
        DJIRouteAnnotion * routeAnn = view.annotation;
        
        
        
        
        if (_mapController.route.currentIndex != -1) {
            ShowResult(@"二次航线无法选择起飞点！");
        }else{
            
            //在这里需要完成航点重新排序和出发点渲染
            NSArray* annos = [NSArray arrayWithArray:mapView.annotations];
            for (int i = 0; i < annos.count; i++) {
                id<MKAnnotation> ann = [annos objectAtIndex:i];
                if ([ann isKindOfClass: [DJIBeginPointAnnotation class]]) {
                    [mapView removeAnnotation:ann];
                }
                
            }
            
            //在这里加入渲染后的出发点
            CLLocation *location = [_routePlan.routeLocations objectAtIndex:routeAnn.index];
            CLLocationCoordinate2D coordinate = location.coordinate;
            CLLocationCoordinate2D coordinateChange = [self.locationChange WorldGS2MarsGS:coordinate];
            DJIBeginPointAnnotation *beginAnnotation = [[DJIBeginPointAnnotation alloc] initWithCoordiante:coordinateChange];
            [mapView addAnnotation:beginAnnotation];
            
            //_mission_Array = [self sort_route:_mission_Array begin_index:routeAnn.index];
            _beginIndex = routeAnn.index;
            _mapController.route.beginIndex = routeAnn.index;
            [self updateWithRoute:_mapController.route];
        }
        
  
    
        
    }


}

/**
 *
MKpointAnnotation 拖拽事件委托
 *
 **/
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState{
    //起飞后的时候不能有响应
    if (_isEditingPoints == YES && [view isKindOfClass:[MKPinAnnotationView class]]) {
        double res;
        
        switch (newState) {
            case MKAnnotationViewDragStateStarting: {
                NSLog(@"拿起");
                CLLocationCoordinate2D destCoordinate=view.annotation.coordinate;
                CLLocationCoordinate2D changedcoordinate = [self.locationChange MarsGS2WorldGS:destCoordinate];
                CLLocation *location = [[CLLocation alloc] initWithLatitude:changedcoordinate.latitude longitude:changedcoordinate.longitude];
                NSLog(@"location_lat:%f",location.coordinate.latitude);
                CLLocation * oldlocation1 = [self.mapController.editPoints objectAtIndex:0];
                res = fabs(oldlocation1.coordinate.latitude - location.coordinate.latitude) + fabs(oldlocation1.coordinate.longitude - location.coordinate.longitude);
                for (int i = 0; self.mapController.editPoints != nil&&i < self.mapController.editPoints.count; i++) {
                    CLLocation * oldlocation = [self.mapController.editPoints objectAtIndex:i];
                    NSLog(@"i=%d oldlocation_lat = %f",i,oldlocation.coordinate.latitude);
                    double temp = fabs(location.coordinate.latitude - oldlocation.coordinate.latitude) + fabs(location.coordinate.longitude - oldlocation.coordinate.longitude);
                    _DragPointIndex = res >= temp?i:_DragPointIndex;
                    res = res >= temp?temp:res;
                }
                NSLog(@"index:%d",_DragPointIndex);
                return;
            }
            case MKAnnotationViewDragStateDragging: {
                
                [_routePlan cleanAllPointsWithMapView:_mapView];
                
                NSLog(@"渣渣");
                return;
            }
            case MKAnnotationViewDragStateEnding: {
                NSLog(@"放下,并将大头针");
                
                switch (self.mode) {
                    case ZZCRouteMode_tiaodai:
                    {
                        CLLocationCoordinate2D destCoordinate=view.annotation.coordinate;
                        CLLocation *location = [[CLLocation alloc] initWithLatitude:destCoordinate.latitude longitude:destCoordinate.longitude];
                        [self.mapController updateEditingPoints:location withindex:_DragPointIndex];
                        _centerCoor = [self.mapController setPolygonView:self.mapController.editPoints withMapView:mapView withCenterView:_contentView withCenterCoor:_centerCoor];
                        [self.mapController setMiddlePoint:self.mapController.editPoints withMapView:mapView];
                        [_mapController setPointView:_mapController.editPoints withMapView:_mapView];
                        //[self.routePlan updateRouteView:self.mapController.editPoints withMapView:self.mapView ];
                    }
                        break;
                    case ZZCRouteMode_huanxing:
                    {
                        CLLocationCoordinate2D destCoordinate=view.annotation.coordinate;
                        CLLocation *location = [[CLLocation alloc] initWithLatitude:destCoordinate.latitude longitude:destCoordinate.longitude];
                        [_mapController updateHuanraoPoints:location];
                        _centerCoor = [self.mapController setPolygonView:self.mapController.editPoints withMapView:mapView withCenterView:_contentView withCenterCoor:_centerCoor];
                        [_mapController setPointView:_mapController.editPoints withMapView:_mapView];
                        //[self.routePlan updateRouteView:self.mapController.editPoints withMapView:self.mapView ];
                        
                    }
                        
                        break;
                    case ZZCRouteMode_qinxie:
                    {
                        CLLocationCoordinate2D destCoordinate=view.annotation.coordinate;
                        CLLocation *location = [[CLLocation alloc] initWithLatitude:destCoordinate.latitude longitude:destCoordinate.longitude];
                        [self.mapController updateEditingPoints:location withindex:_DragPointIndex];
                        _centerCoor = [self.mapController setPolygonView:self.mapController.editPoints withMapView:mapView withCenterView:_contentView withCenterCoor:_centerCoor];
                        [self.mapController setMiddlePoint:self.mapController.editPoints withMapView:mapView];
                        [_mapController setPointView:_mapController.editPoints withMapView:_mapView];
                        
                        [_routePlan.millonPoints removeAllObjects];
                        [_routePlan.allRoutePoints removeAllObjects];
                        [_routePlan.routePoints removeAllObjects];
                        [_routePlan.routeLocations removeAllObjects];
                        
                        [_routePlan fetchAllqinxieRound:_mapController.editPoints];
                        
                        [_mapController setqinxiePolygonView:_routePlan.westLocations northPoints:_routePlan.northLocations eastPoints:_routePlan.eastLocations southPoints:_routePlan.southLocations withMapView:_mapView];
                        
                    }
                        
                        break;
                    case ZZCRouteMode_quanjin:
                    {CLLocationCoordinate2D destCoordinate=view.annotation.coordinate;
                        CLLocation *location = [[CLLocation alloc] initWithLatitude:destCoordinate.latitude longitude:destCoordinate.longitude];
                        [self.mapController updateEditingPoints:location withindex:_DragPointIndex];}
                        break;
                        
                    default:
                        break;
                }
                
                [self newRouteLine];
                
                return;
            }
            default:
                return;
        }
    }else if([view isKindOfClass:[WapianAnnotationView class]]){
        
        switch (newState) {
            case MKAnnotationViewDragStateStarting:
                NSLog(@"拿起");
                break;
            case MKAnnotationViewDragStateDragging:
                NSLog(@"正在拖拽");
                break;
            case MKAnnotationViewDragStateEnding:
                NSLog(@"结束拖拽");
                [self polygonInmapview:_mapView points:_wapian_Array];
                break;
                
            default:
                break;
        }
        
    }
}



- (MKOverlayRenderer*) mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    
    
    if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        MKTileOverlayRenderer *render = [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
        return render;
    }
    
    if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygonRenderer *render = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
        render.fillColor = [[UIColor cyanColor]colorWithAlphaComponent:0.2];
        render.strokeColor = [[UIColor blueColor]colorWithAlphaComponent:0.7];
        render.lineWidth = 3;
        return render;
    }
    
    
    if ([overlay isKindOfClass:[routeLine class]]) {
        routePolyline * polylineview = [[routePolyline alloc] initWithPolyline:overlay];
        return polylineview;
        
    }
    
    if ([overlay isKindOfClass:[westPolyLine class]]) {
        routePolyline * polylineview = [[routePolyline alloc] initWithPolyline:overlay];
        return polylineview;
        
    }
    
    if ([overlay isKindOfClass:[northPolyLine class]]) {
        routePolyline * polylineview = [[routePolyline alloc] initWithPolyline:overlay];
        return polylineview;
        
    }
    
    if ([overlay isKindOfClass:[eastPolyLine class]]) {
        routePolyline * polylineview = [[routePolyline alloc] initWithPolyline:overlay];
        return polylineview;
        
    }
    
    if ([overlay isKindOfClass:[southPolyLine class]]) {
        routePolyline * polylineview = [[routePolyline alloc] initWithPolyline:overlay];
        return polylineview;
        
    }
    
    if ([overlay isKindOfClass:[yundongPolyLine class]]) {
        redPolyLineView * polylineview = [[redPolyLineView  alloc] initWithPolyline:overlay];
        return polylineview;
        
    }
    
    return nil;
}

//overlays 样式委托
- (MKOverlayView*) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{

    if([overlay isKindOfClass:[MKPolygon class]])
        
    {
        
        MKPolygonView*polygonview = [[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay];
        
        polygonview.fillColor= [[UIColor cyanColor]colorWithAlphaComponent:0.2];
        
        polygonview.strokeColor= [[UIColor blueColor]colorWithAlphaComponent:0.7];
        
        polygonview.lineWidth=3;
        
        
        return polygonview;
        
    }

    
    if ([overlay isKindOfClass:[routeLine class]]) {
        routePolyline * polylineview = [[routePolyline alloc] initWithPolyline:overlay];
        return polylineview;
        
    }
    
    if ([overlay isKindOfClass:[westPolyLine class]]) {
        routePolyline * polylineview = [[routePolyline alloc] initWithPolyline:overlay];
        return polylineview;
        
    }
    
    if ([overlay isKindOfClass:[northPolyLine class]]) {
        routePolyline * polylineview = [[routePolyline alloc] initWithPolyline:overlay];
        return polylineview;
        
    }
    
    if ([overlay isKindOfClass:[eastPolyLine class]]) {
        routePolyline * polylineview = [[routePolyline alloc] initWithPolyline:overlay];
        return polylineview;
        
    }
    
    if ([overlay isKindOfClass:[southPolyLine class]]) {
        routePolyline * polylineview = [[routePolyline alloc] initWithPolyline:overlay];
        return polylineview;
        
    }
    
    if ([overlay isKindOfClass:[yundongPolyLine class]]) {
        redPolyLineView * polylineview = [[redPolyLineView  alloc] initWithPolyline:overlay];
        return polylineview;
        
    }
    
    
    
    return nil;
}


//当拖拽，放大，缩小，双击手势开始时调用
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    
    
    
}

//当拖拽，放大，缩小，双击手势结束时调用
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (_mapController.editPoints.count !=0) {
        CGPoint point = [_mapView convertCoordinate:_centerCoor toPointToView:_mapView];
        _contentView.center = point;
    }
}

#pragma mark DJIFlightControllerDelegate
/**
 *
 无人机实时信息获取与更新
 *
 **/
- (void)flightController:(DJIFlightController *)fc didUpdateState:(DJIFlightControllerState *)state
{
    if (state.homeLocation == nil) {
        [fc setHomeLocationUsingAircraftCurrentLocationWithCompletion:nil];
    }
    
    //flightcontroller 一秒十次监听
    
    //这里做一个任务状态监测
    [self updateStateLabels];
    
    self.droneLocation =  [self.locationChange WorldGS2MarsGS:state.aircraftLocation.coordinate];
    self.modeLabel.text = state.flightModeString;
    self.gpsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)state.satelliteCount];
    self.vsLabel.text = [NSString stringWithFormat:@"%0.1f M/S",state.velocityZ];
    self.hsLabel.text = [NSString stringWithFormat:@"%0.1f M/S",(sqrtf(state.velocityX*state.velocityX + state.velocityY*state.velocityY))];
    self.altitudeLabel.text = [NSString stringWithFormat:@"%0.1f M",state.altitude];
    
    [self.mapController updateAircraftLocation:self.droneLocation withMapView:self.mapView];
    double radianYaw = RADIAN(state.attitude.yaw);
    [self.mapController updateAircraftHeading:radianYaw];
    
    
    
}

#pragma mark DJIBatteryDelegate
- (void) battery:(DJIBattery *)battery didUpdateState:(DJIBatteryState *)state{

    
    
    self.batryLabel.text = [NSString stringWithFormat:@"%lu %%",(unsigned long)state.chargeRemainingInPercent];
    
   

}


#pragma mark - DJICameraDelegate

-(void) camera:(DJICamera*)camera didUpdateSystemState:(DJICameraSystemState*)systemState
{
    
    
}



@end
