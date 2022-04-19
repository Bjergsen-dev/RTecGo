//
//  ZZCRoutePlan.m
//  MediaManagerDemo
//
//  Created by Apple on 2018/7/18.
//  Copyright © 2018年 DJI. All rights reserved.
//

#import "ZZCRoutePlan.h"


@implementation ZZCRoutePlan


- (instancetype)init
{
    if (self = [super init]) {
        /**
         *
         在这里初始化变量
         *
         **/
        self.westLocations = [[NSMutableArray alloc] init];
        self.eastLocations = [[NSMutableArray alloc] init];
        self.northLocations = [[NSMutableArray alloc] init];
        self.southLocations = [[NSMutableArray alloc] init];
        self.allRoutePoints =  [[NSMutableArray alloc] init];
        self.millonPoints = [[NSMutableArray alloc] init];
        self.routePoints = [[NSMutableArray alloc] init];
        self.routeLocations = [[NSMutableArray alloc] init];
        self.zzcLocationChange = [[ZZCLocationChange alloc] init];
        self.intMillonPoint = [[ZZCPoint alloc] init];
        self.kuochongPoints = [[NSMutableArray alloc] init];
        //self.mode = ZZCRouteMode_zidingyi;
        self.qinxie_mode = ZZCQinxieMode_west;
        _tiaodai_H = 110;
        _huanrao_Hmin = 10;
        _huanrao_Hmax = 100;
        _hxChongdie = 0.8;
        _pxChongdie = 0.6;
        _begin_index = 0;//默认第一个点是出发点
        _angle = 60;
        _qinxie_angle = 60;
        _xiangji_angle = 45;
    }
    
    return self;
}


//获取边界点的最小外接矩形的横纵坐标
- (void)outerRect:(NSMutableArray*)millonPoints{
    ZZCPoint* point = [millonPoints objectAtIndex:0];
    double min_X = point.point_x;
    double min_Y = point.point_y;
    double max_X = point.point_x;
    double max_Y = point.point_y;
    for (int i = 0; i < millonPoints.count; i++) {
        ZZCPoint* point = [millonPoints objectAtIndex:i];
        if(point.point_x < min_X) min_X = point.point_x;
        if(point.point_x > max_X) max_X = point.point_x;
        if(point.point_y < min_Y) min_Y = point.point_y;
        if(point.point_y > max_Y) max_Y = point.point_y;
    }
    if (_mode == ZZCRouteMode_huanxing) {
        self.min_X = min_X;
        self.min_Y = min_Y;
        self.max_X = max_X;
        self.max_Y = max_Y;
    }else{
    self.min_X = min_X - _tiaodai_H;
    self.min_Y = min_Y - _tiaodai_H;
    self.max_X = max_X + _tiaodai_H;
    self.max_Y = max_Y + _tiaodai_H;
    NSLog(@"min_x:%f  min_y:%f max_x:%f max_y:%f",min_X,min_Y,max_X,max_Y);
    }
}



//新来一个经纬度转换距离的算法
- (CLLocationCoordinate2D) coorToDistance:(CLLocationCoordinate2D)coor dis:(double)distance ang:(double)angle{
    
    double Ea = 6378137;
    double Eb = 6356725;
//    public const double Ea = 6378137;     //   赤道半径
//
//    public const double Eb = 6356725;     //   极半径
//    double dx = distance * 1000 * Math.Sin(angle * Math.PI / 180.0);
//
//    double dy = distance * 1000 * Math.Cos(angle * Math.PI / 180.0);
    
    double dx = distance * 1000 * sin(angle * M_PI / 180.0);
    double dy = distance * 1000 * cos(angle * M_PI / 180.0);
    
    
    
    
    //double ec = 6356725 + 21412 * (90.0 - GLAT) / 90.0;
    
    // 21412 是赤道半径与极半径的差
    
    double ec = Eb + (Ea-Eb) * (90.0 - coor.latitude) / 90.0;
    
    
    
    double ed = ec * cos(coor.latitude * M_PI / 180);
    
    double BJD = (dx / ed + coor.longitude * M_PI / 180.0) * 180.0 / M_PI;
    
    double BWD = (dy / ec + coor.latitude * M_PI / 180.0) * 180.0 / M_PI;
    
    CLLocationCoordinate2D outCoor = CLLocationCoordinate2DMake(BWD, BJD);
    return outCoor;
}

- (void) newFetchAllqinxieRound:(NSMutableArray *)initPoints{
    [_millonPoints removeAllObjects];
    [_westLocations removeAllObjects];
    [_eastLocations removeAllObjects];
    [_northLocations removeAllObjects];
    [_southLocations removeAllObjects];
    
    for (int i  = 0; i < initPoints.count; i++) {
        CLLocation* location = [initPoints objectAtIndex:i];
        CLLocationCoordinate2D coordinate = location.coordinate;
        CLLocationCoordinate2D west_Coor = [self coorToDistance:coordinate dis:_tiaodai_H/tan(_xiangji_angle) ang:(90 - _angle)];
    }
    
}

//初始点得到四个方向的初始点 //这个方法得出的位移量貌似有一些怪异
- (void)fetchAllqinxieRound:(NSMutableArray*)initPoints{
    
    if (initPoints == nil || initPoints.count == 0) {
        ShowResult(@"没有足够的航点");
        return;
    }
    
    [_millonPoints removeAllObjects];
     [_westLocations removeAllObjects];
     [_eastLocations removeAllObjects];
     [_northLocations removeAllObjects];
     [_southLocations removeAllObjects];

    NSLog(@"米勒投影转坐标啦！");
    for (int i=0; initPoints.count>0 && i<initPoints.count; i++) {
        CLLocation* location = [initPoints objectAtIndex:i];
        CLLocationCoordinate2D coordinate = location.coordinate;
        ZZCPoint * point = [self.zzcLocationChange MillierConvertion:coordinate];
        [self.millonPoints addObject:point];
    }
    
    ZZCPoint* temp_point = [_millonPoints objectAtIndex:0];
    double temp_X = temp_point.point_x;
    double temp_Y = temp_point.point_y;
    _intMillonPoint.point_x = temp_X;
    _intMillonPoint.point_y = temp_Y;

    
    for (int i = 0; i < _millonPoints.count; i++) {
        ZZCPoint* point = [_millonPoints objectAtIndex:i];
        
        double point_x;
        double point_y;
        
        
        
        point_x = (point.point_x - _intMillonPoint.point_x)*cos(_angle * M_PI/180.0) - (point.point_y - _intMillonPoint.point_y)*sin(_angle * M_PI/180.0);
        point_y = (point.point_x - _intMillonPoint.point_x)*sin(_angle * M_PI/180.0) + (point.point_y - _intMillonPoint.point_y)*cos(_angle * M_PI/180.0);
        
        NSLog(@"fetchAllqinxieRound_point_x: %f",point_x);
        NSLog(@"fetchAllqinxieRound_point_y: %f",point_y);
        
        double west_X = (point_x - _tiaodai_H/tan(_xiangji_angle * M_PI/180.0)) * cos(_angle * M_PI/180.0) + point_y * sin(_angle * M_PI/180.0) + _intMillonPoint.point_x;
        double west_Y = point_y * cos(_angle * M_PI/180.0) - (point_x - _tiaodai_H/tan(_xiangji_angle * M_PI/180.0)) * sin(_angle * M_PI/180.0) + _intMillonPoint.point_y;
        
        NSLog(@"fetchAllqinxieRound_west_X: %f",west_X);
        NSLog(@"fetchAllqinxieRound_west_Y: %f",west_Y);
        
        ZZCPoint * west_Point = [[ZZCPoint alloc] initWithPoint:west_X point_y:west_Y height:0];
        CLLocationCoordinate2D weat_Coor = [_zzcLocationChange MillierConvertionBack:west_Point];
        
        NSLog(@"fetchAllqinxieRound_weat_Coor.lat: %f",weat_Coor.latitude);
        NSLog(@"fetchAllqinxieRound_weat_Coor.lon: %f",weat_Coor.longitude);
        
        
        CLLocation * west_Loc = [[CLLocation alloc] initWithLatitude:weat_Coor.latitude longitude:weat_Coor.longitude];
        [_westLocations addObject:west_Loc];
        
        double east_X = (point_x + _tiaodai_H/tan(_xiangji_angle * M_PI/180.0)) * cos(_angle * M_PI/180.0) + point_y * sin(_angle * M_PI/180.0) + _intMillonPoint.point_x;
        
        double east_Y = point_y * cos(_angle * M_PI/180.0) - (point_x + _tiaodai_H/tan(_xiangji_angle * M_PI/180.0)) * sin(_angle * M_PI/180.0) + _intMillonPoint.point_y;
        
        ZZCPoint * east_Point = [[ZZCPoint alloc] initWithPoint:east_X point_y:east_Y height:0];
        CLLocationCoordinate2D east_Coor = [_zzcLocationChange MillierConvertionBack:east_Point];
        CLLocation * east_Loc = [[CLLocation alloc] initWithLatitude:east_Coor.latitude longitude:east_Coor.longitude];
        [_eastLocations addObject:east_Loc];
        
        double south_X = (point_x) * cos(_angle * M_PI/180.0) + (point_y + _tiaodai_H/tan(_xiangji_angle * M_PI/180.0)) * sin(_angle * M_PI/180.0) + _intMillonPoint.point_x;
        
        double south_Y = (point_y + _tiaodai_H/tan(_xiangji_angle * M_PI/180.0)) * cos(_angle * M_PI/180.0) - point_x  * sin(_angle * M_PI/180.0) + _intMillonPoint.point_y;
        
        ZZCPoint * south_Point = [[ZZCPoint alloc] initWithPoint:south_X point_y:south_Y height:0];
        CLLocationCoordinate2D south_Coor = [_zzcLocationChange MillierConvertionBack:south_Point];
        CLLocation * south_Loc = [[CLLocation alloc] initWithLatitude:south_Coor.latitude longitude:south_Coor.longitude];
        [_southLocations addObject:south_Loc];
        
        double north_X = point_x  * cos(_angle * M_PI/180.0) + (point_y - _tiaodai_H/tan(_xiangji_angle * M_PI/180.0)) * sin(_angle * M_PI/180.0) + _intMillonPoint.point_x;
        
        double north_Y = (point_y - _tiaodai_H/tan(_xiangji_angle * M_PI/180.0)) * cos(_angle * M_PI/180.0) - point_x  * sin(_angle * M_PI/180.0) + _intMillonPoint.point_y;
        ZZCPoint * north_Point = [[ZZCPoint alloc] initWithPoint:north_X point_y:north_Y height:0];
        CLLocationCoordinate2D north_Coor = [_zzcLocationChange MillierConvertionBack:north_Point];
        CLLocation * north_Loc = [[CLLocation alloc] initWithLatitude:north_Coor.latitude longitude:north_Coor.longitude];
        [_northLocations addObject:north_Loc];
    }

}


//拿到所有边界点的xy转换后坐标 然后偏角60度
- (void)fetchAllMillonPoints:(NSMutableArray*)initPoints{

    NSLog(@"米勒投影转坐标啦！");
    for (int i=0; initPoints.count>0 && i<initPoints.count; i++) {
        CLLocation* location = [initPoints objectAtIndex:i];
            CLLocationCoordinate2D coordinate = location.coordinate;
            ZZCPoint * point = [self.zzcLocationChange MillierConvertion:coordinate];
            [self.millonPoints addObject:point];
    }
    
    ZZCPoint* temp_point = [_millonPoints objectAtIndex:0];
    double temp_X = temp_point.point_x;
    double temp_Y = temp_point.point_y;
    _intMillonPoint.point_x = temp_X;
    _intMillonPoint.point_y = temp_Y;
    NSMutableArray * tempArray = [[NSMutableArray alloc] init];
    
    for (int i = (int)(self.millonPoints.count - 1); i >= 0; i--) {
         ZZCPoint* point = [_millonPoints objectAtIndex:i];
        
        double point_x;
        double point_y;
        
        //判断飞行模式然后做不同处理
        if (_mode == ZZCRouteMode_tiaodai) {
            point_x = (point.point_x - _intMillonPoint.point_x)*cos(_angle * M_PI/180.0) - (point.point_y - _intMillonPoint.point_y)*sin(_angle * M_PI/180.0);
            point_y = (point.point_x - _intMillonPoint.point_x)*sin(_angle * M_PI/180.0) + (point.point_y - _intMillonPoint.point_y)*cos(_angle * M_PI/180.0);
            
            point.point_y = point_y;
            point.point_x = point_x;
            NSLog(@"fetchAllMillonPoints-point.point_x:%f",point.point_x);
            NSLog(@"fetchAllMillonPoints-point.point_y:%f",point.point_y);
            [tempArray addObject:point];
            
        }else if(_mode == ZZCRouteMode_qinxie){
            
            point_x = (point.point_x - _intMillonPoint.point_x)*cos(_angle * M_PI/180.0) - (point.point_y - _intMillonPoint.point_y)*sin(_angle * M_PI/180.0);
            point_y = (point.point_x - _intMillonPoint.point_x)*sin(_angle * M_PI/180.0) + (point.point_y - _intMillonPoint.point_y)*cos(_angle * M_PI/180.0);
            
            point.point_y = point_y;
            point.point_x = point_x;
            NSLog(@"fetchAllMillonPoints-point.point_x:%f",point.point_x);
            NSLog(@"fetchAllMillonPoints-point.point_y:%f",point.point_y);
            [tempArray addObject:point];
            
        
        }else {
         
            /*point_x = (point.point_x - _intMillonPoint.point_x)*cos(HRANGLE) - (point.point_y - _intMillonPoint.point_y)*sin(HRANGLE);
         
            point_y = (point.point_x - _intMillonPoint.point_x)*sin(HRANGLE) + (point.point_y - _intMillonPoint.point_y)*cos(HRANGLE);*/
            
            point_x = point.point_x;
            point_y = point.point_y;
            
            point.point_y = point_y;
            point.point_x = point_x;
            NSLog(@"fetchAllMillonPoints-point.point_x:%f",point.point_x);
            NSLog(@"fetchAllMillonPoints-point.point_y:%f",point.point_y);
            [tempArray addObject:point];
            
        }
        
        
    }
    
    
    //坐标转换后存入数组 以备后用
    for (int i = 0; i < tempArray.count; i++) {
        _millonPoints[i] = tempArray[i];
    }
    
    NSLog(@"米勒点的个数%lu",self.millonPoints.count);
    
}

//拿到所有初步计算的航点
- (void)fetchAllRoutePoints:(NSMutableArray*)millonPoints{

    double offsetX = 0.0;
    double offsetY = 0.0;
    
    
    if (_mode == ZZCRouteMode_tiaodai) {
        //计算网格的最小XY偏量
        offsetX = _tiaodai_H / F * CW * (1 - _hxChongdie);
        offsetY = _tiaodai_H / F * CH * (1 - _pxChongdie);
        
        //这里需要加一个判断 高程过高就不能飞了
        
        if (offsetX > (_max_X - _min_X - 2*_tiaodai_H) || offsetY > (_max_Y - _min_Y - 2*_tiaodai_H)){
            ShowResult(@"高度超阈值，请重新设定！");
            return;
        }

    }else{
    
        switch (_qinxie_mode) {
            case ZZCQinxieMode_west:
                offsetX = _tiaodai_H / F * CW * (1 - _hxChongdie) * 0.707107;
                offsetY = _tiaodai_H / F * CH * (1 - _pxChongdie);
                
                //这里需要加一个判断 高程过高就不能飞了
                
                if (offsetX > (_max_X - _min_X - 2*_tiaodai_H) || offsetY > (_max_Y - _min_Y - 2*_tiaodai_H)) {
                    ShowResult(@"高度超阈值，请重新设定！");
                    return;
                }
                break;
            case ZZCQinxieMode_east:
                offsetX = _tiaodai_H / F * CW * (1 - _hxChongdie) * 0.707107;
                offsetY = _tiaodai_H / F * CH * (1 - _pxChongdie);
                
                //这里需要加一个判断 高程过高就不能飞了
                
                if (offsetX > (_max_X - _min_X - 2*_tiaodai_H) || offsetY > (_max_Y - _min_Y - 2*_tiaodai_H)) {
                    ShowResult(@"高度超阈值，请重新设定！");
                    return;
                }
                break;
            case ZZCQinxieMode_north:
                offsetX = _tiaodai_H / F * CW * (1 - _hxChongdie);
                offsetY = _tiaodai_H / F * CH * (1 - _pxChongdie) * 0.707107;
                
                //这里需要加一个判断 高程过高就不能飞了
                
                if (offsetX > (_max_X - _min_X - 2*_tiaodai_H) || offsetY > (_max_Y - _min_Y - 2*_tiaodai_H)) {
                    ShowResult(@"高度超阈值，请重新设定！");
                    return;
                }
                break;
            case ZZCQinxieMode_south:
                offsetX = _tiaodai_H / F * CW * (1 - _hxChongdie);
                offsetY = _tiaodai_H / F * CH * (1 - _pxChongdie) * 0.707107;
                
                //这里需要加一个判断 高程过高就不能飞了
                
                if (offsetX > (_max_X - _min_X - 2*_tiaodai_H) || offsetY > (_max_Y - _min_Y - 2*_tiaodai_H)) {
                    ShowResult(@"高度超阈值，请重新设定！");
                    return;
                }
                break;
                
            default:
                break;
        }
    
    }
    
    NSLog(@"fetchAllRoutePoints-offsetX:%f",offsetX);
    NSLog(@"fetchAllRoutePoints-offsetY:%f",offsetY);
    
    double x_Point_number = (_max_X - _min_X)/ offsetX;
    double y_Point_number = (_max_Y - _min_Y)/ offsetY;
    
    NSLog(@"fetchAllRoutePoints-x_Point_number:%f",x_Point_number);
    NSLog(@"fetchAllRoutePoints-y_Point_number:%f",y_Point_number);

    
    
    //通过这两不交替循环把横纵两路的扩充点都找出来 并把所有的航点都存在allroutepoints 把所有的扩充点和满足点都存在_kuochongpoints里面
    //这里的type设置用来判断纵横方向
    [self kuochongBoundPoints:x_Point_number y_num:y_Point_number offsetX:offsetX offsetY:offsetY type:0];
    [self kuochongBoundPoints:y_Point_number y_num:x_Point_number offsetX:offsetX offsetY:offsetY type:1];
    
    
    //这里设置一个临时的temp_Array来存储有顺序的所有条件点
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    for (int i =0; _allRoutePoints.count > 0&&i < _allRoutePoints.count; i++) {
        ZZCPoint* point = [_allRoutePoints objectAtIndex:i];
        
        
        //这个点在所有点内但不在_kuochongPoints内 不要不要
        
        if ([self inorNot_array:_kuochongPoints point:point] == -1) {
            NSLog(@"这个点不满足条件");
        }else{
        
            [temp addObject:point];
            
        
        }
    }
    
    //通过上面的调整顺序可以得到顺序点集
    //下面把把点转存到-kuochongPoints里面
    for (int i = 0; i < temp.count; i++) {
        ZZCPoint * point = [temp objectAtIndex:i];
        [_kuochongPoints setObject:point atIndexedSubscript:i];
    }
    
    NSLog(@"所有条带/倾斜飞航点个数：%lu",self.allRoutePoints.count);
    NSLog(@"temp个数：%lu",temp.count);
    NSLog(@"所有条带/倾斜飞满足条件且扩充后航点个数：%lu",self.kuochongPoints.count);
}


//扩充点数的方法打包在这里

- (void)kuochongBoundPoints:(double) x_point_num y_num:(double) y_point_num offsetX:(double) offsetX offsetY:(double) offsetY type:(int)type{
 

    [_allRoutePoints removeAllObjects];//首先请空这个数组里面的东西 应为要执行两次
    
    for(int i = 0; i < x_point_num; i++)
    {
        
        ZZCPoint * lastPoint = [[ZZCPoint alloc] init];//定义这个点来记录上一个点的坐标
        
        if (i%2 == 0) {
            for(int j = 0; j < y_point_num; j++)
            {
                ZZCPoint * initRoutePt;
                
                if (type == 0) {
                    initRoutePt = [[ZZCPoint alloc] initWithPoint:_min_X + i * offsetX point_y:_min_Y + j * offsetY height:0];
                }else{
                
                    initRoutePt = [[ZZCPoint alloc] initWithPoint:_min_X + j * offsetX point_y:_min_Y + i * offsetY height:0];
                }
                
                [_allRoutePoints addObject:initRoutePt];
                
                
                //点在多边形内部而且不重复就添加
                if([self inorNot_array:_kuochongPoints point:initRoutePt] == -1&&[self inorNot:_millonPoints routePoint:initRoutePt]) {
                    [_kuochongPoints addObject:initRoutePt];
                    
                    NSLog(@"加了一个内部点");
                }
                
                if (_allRoutePoints.count > 1) {
                    lastPoint = [_allRoutePoints objectAtIndex:_allRoutePoints.count - 2];//lastpoint记录的是当前allpoints里面的倒数第二点，我们要做的事就是吧从无到有 从有到无的两个点扩充进来
                }else{
                
                    //只有一个点的时候不存在倒数第二个点一说
                    lastPoint = [_allRoutePoints objectAtIndex:0];
                    
                }
                
                if ([self inorNot:_millonPoints routePoint:lastPoint] == NO&&[self inorNot:_millonPoints routePoint:initRoutePt] == YES) {
                    //从无到有
                    //先判断是否已经在里面了
                    if ([self inorNot_array:_kuochongPoints point:lastPoint] == -1) {
                        [_kuochongPoints addObject:lastPoint];
                        NSLog(@"加了一个扩充点");
                    }
                }
                
                if ([self inorNot:_millonPoints routePoint:lastPoint] == YES&&[self inorNot:_millonPoints routePoint:initRoutePt] == NO) {
                    //从有到无
                    //先判断是否已经在里面了
                    if ([self inorNot_array:_kuochongPoints point:initRoutePt] == -1) {
                        [_kuochongPoints addObject:initRoutePt];
                        NSLog(@"加了一个扩充点");
                    }
                }
                
                NSLog(@"fetchAllRoutePoints-initRoutePt_x:%f",initRoutePt.point_x);
                NSLog(@"fetchAllRoutePoints-initRoutePt_y:%f",initRoutePt.point_y);
            }
        }else{
            
            for(int j = y_point_num; j >= 0; j--)
            {
                ZZCPoint * initRoutePt;
                
                if (type == 0) {
                    initRoutePt = [[ZZCPoint alloc] initWithPoint:_min_X + i * offsetX point_y:_min_Y + j * offsetY height:0];
                }else{
                    
                    initRoutePt = [[ZZCPoint alloc] initWithPoint:_min_X + j * offsetX point_y:_min_Y + i * offsetY height:0];
                }
                
                
                
                [_allRoutePoints addObject:initRoutePt];
                
                
                //点在多边形内部而且不重复就添加
                if([self inorNot:_millonPoints routePoint:initRoutePt]&&[self inorNot_array:_kuochongPoints point:initRoutePt] == -1) {
                    [_kuochongPoints addObject:initRoutePt];
                    NSLog(@"加了一个内部点");
                }
                
                if (_allRoutePoints.count > 1) {
                    lastPoint = [_allRoutePoints objectAtIndex:_allRoutePoints.count - 2];//lastpoint记录的是当前allpoints里面的倒数第二点，我们要做的事就是吧从无到有 从有到无的两个点扩充进来
                }else{
                    
                    //只有一个点的时候不存在倒数第二个点一说
                    lastPoint = [_allRoutePoints objectAtIndex:0];
                    
                }
                
                if ([self inorNot:_millonPoints routePoint:lastPoint] == NO&&[self inorNot:_millonPoints routePoint:initRoutePt] == YES) {
                    //从无到有
                    
                    //先判断是否已经在里面了
                    if ([self inorNot_array:_kuochongPoints point:lastPoint] == -1) {
                        [_kuochongPoints addObject:lastPoint];
                        NSLog(@"加了一个扩充点");
                    }
                    
                }
                
                if ([self inorNot:_millonPoints routePoint:lastPoint] == YES&&[self inorNot:_millonPoints routePoint:initRoutePt] == NO) {
                    //从有到无
                    
                    //先判断是否已经在里面了
                    if ([self inorNot_array:_kuochongPoints point:initRoutePt] == -1) {
                        [_kuochongPoints addObject:initRoutePt];
                        NSLog(@"加了一个扩充点");
                    }
                }
                
                NSLog(@"fetchAllRoutePoints-initRoutePt_x:%f",initRoutePt.point_x);
                NSLog(@"fetchAllRoutePoints-initRoutePt_y:%f",initRoutePt.point_y);
            }
            
            
        }
        
        
    }

}


//在这里写一个函数来判断某个点事都已经存在于数组之中 并且返回其下标志
- (int) inorNot_array:(NSMutableArray*)points point:(ZZCPoint *)point{

    for (int i = 0; points.count>0&&i < points.count; i++) {
        
        ZZCPoint* real_point = [points objectAtIndex:i];
        
        
        if (real_point.point_x == point.point_x && real_point.point_y == point.point_y) {
            return i;
        }    }
    
    
    return -1;
    

}

//拿到所有初步计算的环形飞航点
- (void)fetchAllHuanraoRoutePoints:(NSMutableArray*)millonPoints{

    
    //得到XYZ的最小偏量
    double offsetX = _huanrao_Hmax / F * CW * (1 - _hxChongdie);
    double offsetY = _huanrao_Hmax / F * CW * (1 - _hxChongdie);
    double offsetZ = _huanrao_Hmax / F * CH * (1 - _pxChongdie);
    
    
    double x_Point_number = (_max_X - _min_X)/ offsetX;
    double y_Point_number = (_max_Y - _min_Y)/ offsetY;
    double z_Point_number = (_huanrao_Hmax - _huanrao_Hmin)/ offsetZ;
    
    if (x_Point_number == 0 || y_Point_number == 0||z_Point_number == 0) {
        ShowResult(@"高程设定异常，请重新设定！");
        return;
    }
    
    NSLog(@"fetchAllHuanraoRoutePoints-x_Point_number:%f",x_Point_number);
    NSLog(@"fetchAllHuanraoRoutePoints-y_Point_number:%f",y_Point_number);
    NSLog(@"fetchAllHuanraoRoutePoints-z_Point_number:%f",z_Point_number);
    
    for(int i = 0; i < x_Point_number; i++)
    {
        ZZCPoint * initRoutePt = [[ZZCPoint alloc] initWithPoint:_min_X + i * offsetX point_y:_min_Y height:_huanrao_Hmin];
        initRoutePt.heading = 180;
        [_allRoutePoints addObject:initRoutePt];
        
        NSLog(@"_allRoutePoints.point_x:%f",initRoutePt.point_x);
        NSLog(@"_allRoutePoints.point_y:%f",initRoutePt.point_y);
    }
    
    for(int i = 0; i < y_Point_number; i++)
    {
        ZZCPoint * initRoutePt = [[ZZCPoint alloc] initWithPoint:_max_X point_y:_min_Y + i*offsetY height:_huanrao_Hmin];
        
        initRoutePt.heading = -90;
        
        [_allRoutePoints addObject:initRoutePt];
        
        
        NSLog(@"_allRoutePoints.point_x:%f",initRoutePt.point_x);
        NSLog(@"_allRoutePoints.point_y:%f",initRoutePt.point_y);
    }
    
    for(int i = 0; i < x_Point_number; i++)
    {
        ZZCPoint * initRoutePt = [[ZZCPoint alloc] initWithPoint:_max_X - i*offsetX point_y:_max_Y height:_huanrao_Hmin];
        
        initRoutePt.heading = 0;
        [_allRoutePoints addObject:initRoutePt];
        
        NSLog(@"_allRoutePoints.point_x:%f",initRoutePt.point_x);
        NSLog(@"_allRoutePoints.point_y:%f",initRoutePt.point_y);
    }
    
    for(int i = 0; i < y_Point_number; i++)
    {
        ZZCPoint * initRoutePt = [[ZZCPoint alloc] initWithPoint:_min_X  point_y:_max_Y - i*offsetY height:_huanrao_Hmin];
        
        initRoutePt.heading = 90;
        [_allRoutePoints addObject:initRoutePt];
        
        NSLog(@"_allRoutePoints.point_x:%f",initRoutePt.point_x);
        NSLog(@"_allRoutePoints.point_y:%f",initRoutePt.point_y);
    }
    
    
    NSMutableArray *temp_Array = [[NSMutableArray alloc] init];
    
    for (int i = 1; i < z_Point_number; i++) {
        for (int j = 0; j < _allRoutePoints.count; j++) {
            
            ZZCPoint * point = [_allRoutePoints objectAtIndex:j];
            ZZCPoint * new_point = [[ZZCPoint alloc] initWithPoint:point.point_x point_y:point.point_y height:_huanrao_Hmin + i * offsetZ];
            new_point.heading = point.heading;
            [temp_Array addObject:new_point];
        }
    }
    
    for (int i = 0; i < temp_Array.count; i++) {
        ZZCPoint * point = [temp_Array objectAtIndex:i];
        [_allRoutePoints addObject:point];
    }
    
    NSLog(@"所有环绕飞航点个数：%lu",(unsigned long)self.allRoutePoints.count);

}


/**
 *
 这个函数用于条带飞判断初步得到的航点是否在多边形之内
 *
 **/
//判断航点是否在边界范围内
- (bool)inorNot:(NSMutableArray*)millonPoints routePoint:(ZZCPoint*)point{

    int i, j, c = 0;
    int nvert = (int)millonPoints.count;
    j = nvert - 1;
    NSLog(@"inorNot-nvert：%d",nvert);
    NSLog(@"inorNot-point_x：%f",point.point_x);
    NSLog(@"inorNot-point_y：%f",point.point_y);
    
    ZZCPoint* point_i;
    ZZCPoint* point_j;
    for (i = 0; i<nvert; i++)
    {
        
         point_i = [millonPoints objectAtIndex:i];
         point_j = [millonPoints objectAtIndex:j];
        
        if(((point_i.point_y<point.point_y && point_j.point_y>=point.point_y) || (point_j.point_y<point.point_y && point_i.point_y>=point.point_y)) && (point_i.point_x<=point.point_x || point_j.point_x<=point.point_x))
        {
            c ^= ((point_i.point_x + (point.point_y-point_i.point_y)/(point_j.point_y-point_i.point_y)*(point_j.point_x-point_i.point_x)) < point.point_x);
        }
        
        j=i;
    }
    
    return c==0?NO:YES;
}
    


/**
 *
定义该方法来集中使用前文提到的方法 方便外部调用
 *
 **/
- (void)addRoutePoint:(NSMutableArray*)initPoints{
    [self fetchAllMillonPoints:initPoints];
    [self outerRect:_millonPoints];
    switch (_mode) {
        case ZZCRouteMode_tiaodai:
            NSLog(@"当前模式为条带飞");
            [self fetchAllRoutePoints:_millonPoints];
            break;
        case ZZCRouteMode_huanxing:
            NSLog(@"当前模式为环绕飞");
            [self fetchAllHuanraoRoutePoints:_millonPoints];
            break;
        case ZZCRouteMode_qinxie:
            NSLog(@"当前模式为倾斜飞");
            [self fetchAllRoutePoints:_millonPoints];
            break;
            
        default:
            break;
    }
    
    
    
    switch (_mode) {
        case ZZCRouteMode_qinxie:
        {
            for (int i = 0; _kuochongPoints != nil&&i < _kuochongPoints.count; i++) {
                ZZCPoint * point = [_kuochongPoints objectAtIndex:i];
                
                
                double tmp_X;
                double tmp_Y;
                double tmp_Z;
                
                
                tmp_X = point.point_x * cos(_angle * M_PI/180.0) + point.point_y * sin(_angle * M_PI/180.0) + _intMillonPoint.point_x;
                
                tmp_Y = point.point_y * cos(_angle * M_PI/180.0) - point.point_x * sin(_angle * M_PI/180.0) + _intMillonPoint.point_y;
                
                tmp_Z = 0;
                
                
                ZZCPoint * routPoint = [[ZZCPoint alloc] initWithPoint:tmp_X point_y:tmp_Y height:tmp_Z];
                
                
                
                NSLog(@"addRoutePoint-point.point_x : %f",tmp_X);
                NSLog(@"addRoutePoint-point.point_y : %f",tmp_Y);
                NSLog(@"addRoutePoint-point.point.height : %f",tmp_Z);
                
                [_routePoints addObject:routPoint];
            }
        
        }
            break;
        case ZZCRouteMode_quanjin:
            
            break;
        case ZZCRouteMode_tiaodai:
            for (int i = 0; _kuochongPoints != nil&&i < _kuochongPoints.count; i++) {
                ZZCPoint * point = [_kuochongPoints objectAtIndex:i];
                
                
                double tmp_X;
                double tmp_Y;
                double tmp_Z;
                
                
                tmp_X = point.point_x * cos(_angle * M_PI/180.0) + point.point_y * sin(_angle * M_PI/180.0) + _intMillonPoint.point_x;
                
                tmp_Y = point.point_y * cos(_angle * M_PI/180.0) - point.point_x * sin(_angle * M_PI/180.0) + _intMillonPoint.point_y;
                
                tmp_Z = 0;
                
                
                ZZCPoint * routPoint = [[ZZCPoint alloc] initWithPoint:tmp_X point_y:tmp_Y height:tmp_Z];
                
                
                
                NSLog(@"addRoutePoint-point.point_x : %f",tmp_X);
                NSLog(@"addRoutePoint-point.point_y : %f",tmp_Y);
                NSLog(@"addRoutePoint-point.point.height : %f",tmp_Z);
                
                [_routePoints addObject:routPoint];
            }
            break;
        case ZZCRouteMode_huanxing:
        {
            for (int i =0;_allRoutePoints != nil&&i<_allRoutePoints.count; i++) {
            ZZCPoint* point = [_allRoutePoints objectAtIndex:i];
            double tmp_X;
            double tmp_Y;
            double tmp_Z;
            
            /*tmp_X = point.point_x * cos(HRANGLE) + point.point_y * sin(HRANGLE) + _intMillonPoint.point_x;
             
             tmp_Y = point.point_y * cos(HRANGLE) - point.point_x * sin(HRANGLE) + _intMillonPoint.point_y;*/
            tmp_X = point.point_x;
            tmp_Y = point.point_y;
            tmp_Z = point.height;
            
            
            ZZCPoint * routPoint = [[ZZCPoint alloc] initWithPoint:tmp_X point_y:tmp_Y height:tmp_Z];
            routPoint.heading = point.heading;
            
            
            
            NSLog(@"addRoutePoint-point.point_x : %f",tmp_X);
            NSLog(@"addRoutePoint-point.point_y : %f",tmp_Y);
            NSLog(@"addRoutePoint-point.point.height : %f",tmp_Z);
            
            [_routePoints addObject:routPoint];
        }
        }
            break;
            
        default:
            break;
    }
    
 
    NSLog(@"符合条件航点个数：%lu",self.routePoints.count);
}

//外部唯一接口函数
- (void)fetchRouteLocations:(NSMutableArray*)initPoints{

    [self addRoutePoint:initPoints];
    
    for (int i = 0; _routePoints != nil&&i<_routePoints.count; i++) {
            ZZCPoint* point = [_routePoints objectAtIndex:i];
            CLLocationCoordinate2D coordinate = [self.zzcLocationChange MillierConvertionBack:point];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            [self.routeLocations addObject:location];
    }
    
}


//qinxie外部唯一接口函数
- (void)fetchQinxieRouteLocations:(NSMutableArray*)westPoints northPoints:(NSMutableArray*)northPoints eastPoints:(NSMutableArray*)eastPoints southPoints:(NSMutableArray*)southPoints{
    
    [self addRoutePoint:westPoints];
    for (int i = 0; _routePoints != nil&&i<_routePoints.count; i++) {
        ZZCPoint* point = [_routePoints objectAtIndex:i];
        CLLocationCoordinate2D coordinate = [self.zzcLocationChange MillierConvertionBack:point];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [self.routeLocations addObject:location];
    }
    
    _westCount = (int)_routePoints.count;
    
    [_millonPoints removeAllObjects];
    [_allRoutePoints removeAllObjects];
    [_kuochongPoints removeAllObjects];
    [_routePoints removeAllObjects];
    
    [self addRoutePoint:northPoints];
    for (int i = 0; _routePoints != nil&&i<_routePoints.count; i++) {
        ZZCPoint* point = [_routePoints objectAtIndex:i];
        CLLocationCoordinate2D coordinate = [self.zzcLocationChange MillierConvertionBack:point];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [self.routeLocations addObject:location];
    }
    _northCount = (int)_routePoints.count;
    [_millonPoints removeAllObjects];
    [_allRoutePoints removeAllObjects];
    [_kuochongPoints removeAllObjects];
    [_routePoints removeAllObjects];
    
    [self addRoutePoint:eastPoints];
    for (int i = 0; _routePoints != nil&&i<_routePoints.count; i++) {
        ZZCPoint* point = [_routePoints objectAtIndex:i];
        CLLocationCoordinate2D coordinate = [self.zzcLocationChange MillierConvertionBack:point];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [self.routeLocations addObject:location];
    }
    _eastCount = (int)_routePoints.count;
    [_millonPoints removeAllObjects];
    [_allRoutePoints removeAllObjects];
    [_kuochongPoints removeAllObjects];
    [_routePoints removeAllObjects];
    
    [self addRoutePoint:southPoints];
    for (int i = 0; _routePoints != nil&&i<_routePoints.count; i++) {
        ZZCPoint* point = [_routePoints objectAtIndex:i];
        CLLocationCoordinate2D coordinate = [self.zzcLocationChange MillierConvertionBack:point];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [self.routeLocations addObject:location];
    }
    _southCount = (int)_routePoints.count;
    
    
    
}


//生成航点在mapview上面
-(void)setRouteLocation:(NSMutableArray*)routeLocations withMapView:(MKMapView *)mapView{

    NSLog(@"符合条件航点标记个数：%lu",self.routeLocations.count);
    
    
    
    if (_mode == ZZCRouteMode_qinxie) {
        CLLocationCoordinate2D W_points[_westCount];
        CLLocationCoordinate2D N_points[_northCount];
        CLLocationCoordinate2D E_points[_eastCount];
        CLLocationCoordinate2D S_points[_southCount];
        
        NSLog(@"总点数：%lu",(unsigned long)routeLocations.count);
        NSLog(@"西部点数：%d",_westCount);
        NSLog(@"北部点数：%d",_northCount);
        NSLog(@"东部点数：%d",_eastCount);
        NSLog(@"南部点数：%d",_southCount);
        
        for (int i =0; routeLocations != nil&&i < routeLocations.count; i++) {
            CLLocation *location = [routeLocations objectAtIndex:i];
            CLLocationCoordinate2D coordinate = location.coordinate;
            CLLocationCoordinate2D coordinateChange = [self.zzcLocationChange WorldGS2MarsGS:coordinate];
            if (i<_westCount) {
                W_points[i] = coordinateChange;
            }else if (_westCount<=i&&i<_northCount+_westCount){
            
                N_points[i-_westCount] = coordinateChange;
                
            }else if (_northCount+_westCount<=i&&i<_eastCount+_westCount+_eastCount){
            
                E_points[i-_westCount-_northCount] = coordinateChange;
            }else{
            
                S_points[i-_westCount-_northCount-_eastCount] = coordinateChange;
            }
            
            
            DJIRouteAnnotion *routeAnnotation = [[DJIRouteAnnotion alloc] initWithCoordiante:coordinateChange];
            [routeAnnotation setIIndex:i];
            [mapView addAnnotation:routeAnnotation];
        }
        
       
        
        //在这里加入最初始的那个出发点
        CLLocation *location = [routeLocations objectAtIndex:_begin_index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        CLLocationCoordinate2D coordinateChange = [self.zzcLocationChange WorldGS2MarsGS:coordinate];
        DJIBeginPointAnnotation *beginAnnotation = [[DJIBeginPointAnnotation alloc] initWithCoordiante:coordinateChange];
        [mapView addAnnotation:beginAnnotation];
        
        //绘制路线
        if (_N_polyline == nil) {
            _N_polyline = [northPolyLine polylineWithCoordinates:N_points count:_northCount];
            [mapView addOverlay:_N_polyline];
        }else{
            
            [mapView removeOverlay:_N_polyline];
            _N_polyline = [northPolyLine polylineWithCoordinates:N_points count:_northCount];
            [mapView addOverlay:_N_polyline];
            
            
        }

        //绘制路线
        if (_W_polyline == nil) {
            _W_polyline = [westPolyLine polylineWithCoordinates:W_points count:_westCount];
            [mapView addOverlay:_W_polyline];
        }else{
            
            [mapView removeOverlay:_W_polyline];
            _W_polyline = [westPolyLine polylineWithCoordinates:W_points count:_westCount];
            [mapView addOverlay:_W_polyline];
            
            
        }

        //绘制路线
        if (_E_polyline == nil) {
            _E_polyline = [eastPolyLine polylineWithCoordinates:E_points count:_eastCount];
            [mapView addOverlay:_E_polyline];
        }else{
            
            [mapView removeOverlay:_E_polyline];
            _E_polyline = [eastPolyLine polylineWithCoordinates:E_points count:_eastCount];
            [mapView addOverlay:_E_polyline];
            
            
        }

        //绘制路线
        if (_S_polyline == nil) {
            _S_polyline = [southPolyLine polylineWithCoordinates:S_points count:_southCount];
            [mapView addOverlay:_S_polyline];
        }else{
            
            [mapView removeOverlay:_S_polyline];
            _S_polyline = [southPolyLine polylineWithCoordinates:S_points count:_southCount];
            [mapView addOverlay:_S_polyline];
            
            
        }

        
    }else{
    
    //非倾斜飞条件
    //在这里声明一个数组专门存这些点的2d坐标用来绘制路线
    CLLocationCoordinate2D points[routeLocations.count];
    
    for (int i =0; routeLocations != nil&&i < routeLocations.count; i++) {
        CLLocation *location = [routeLocations objectAtIndex:i];
        CLLocationCoordinate2D coordinate = location.coordinate;
        CLLocationCoordinate2D coordinateChange = [self.zzcLocationChange WorldGS2MarsGS:coordinate];
        points[i] = coordinateChange;
        DJIRouteAnnotion *routeAnnotation = [[DJIRouteAnnotion alloc] initWithCoordiante:coordinateChange];
        [routeAnnotation setIIndex:i];
        [mapView addAnnotation:routeAnnotation];
    }
    
        
        if (routeLocations == nil||routeLocations.count == 0) {
            return;
        }
        
    //在这里加入最初始的那个出发点
    CLLocation *location = [routeLocations objectAtIndex:_begin_index];
    CLLocationCoordinate2D coordinate = location.coordinate;
    CLLocationCoordinate2D coordinateChange = [self.zzcLocationChange WorldGS2MarsGS:coordinate];
    DJIBeginPointAnnotation *beginAnnotation = [[DJIBeginPointAnnotation alloc] initWithCoordiante:coordinateChange];
    [mapView addAnnotation:beginAnnotation];
    
    //绘制路线
    if (_polyline == nil) {
        _polyline = [routeLine polylineWithCoordinates:points count:routeLocations.count];
        [mapView addOverlay:_polyline];
    }else{
    
        [mapView removeOverlay:_polyline];
        _polyline = [routeLine polylineWithCoordinates:points count:routeLocations.count];
        [mapView addOverlay:_polyline];
    
    
    }
    }
    
}

/**
 *  Current Edit Points
 *
 *  @return Return an NSArray contains multiple CCLocation objects
 */
- (NSArray *)getRoutePoints{
    return _routeLocations;
}



- (void)cleanAllPointsWithMapView:(MKMapView *)mapView{

    [_millonPoints removeAllObjects];
    [_allRoutePoints removeAllObjects];
    [_kuochongPoints removeAllObjects];
    [_routePoints removeAllObjects];
    [_routeLocations removeAllObjects];
    
    NSArray* annos = [NSArray arrayWithArray:mapView.annotations];
    for (int i = 0; i < annos.count; i++) {
        id<MKAnnotation> ann = [annos objectAtIndex:i];
        if ([ann isKindOfClass: [DJIRouteAnnotion class]]||[ann isKindOfClass: [DJIBeginPointAnnotation class]]) {
            [mapView removeAnnotation:ann];
        }
        
    }
    
    //把这个线也删了
    if (_polyline != nil) {
        [mapView removeOverlay:_polyline];
    }
    
    //把这个线也删了
    if (_W_polyline != nil) {
        [mapView removeOverlay:_W_polyline];
    }
    //把这个线也删了
    if (_N_polyline != nil) {
        [mapView removeOverlay:_N_polyline];
    }
    //把这个线也删了
    if (_E_polyline != nil) {
        [mapView removeOverlay:_E_polyline];
    }
    //把这个线也删了
    if (_S_polyline != nil) {
        [mapView removeOverlay:_S_polyline];
    }
    
    
    
}



//这个方法太暴力了，所有点重新计算，影像了时间消耗
- (void)updateRouteView:(NSMutableArray*)initPoints withMapView:(MKMapView *)mapView{
    if (initPoints.count == 0) {
        NSLog(@"没点了还绘制啥啊,但是东西还是要清除！");
        [_millonPoints removeAllObjects];
        [_allRoutePoints removeAllObjects];
        [_kuochongPoints removeAllObjects];
        [_routePoints removeAllObjects];
        [_routeLocations removeAllObjects];
    }
    else{
    [self cleanAllPointsWithMapView:mapView];
    [self fetchRouteLocations:initPoints];
    [self setRouteLocation:_routeLocations withMapView:mapView];
    }
    
}


//专门解决倾斜的四部分同时显示的
- (void)updateqinxieRouteView:(NSMutableArray*)westPoints northPoints:(NSMutableArray*)northPoints eastPoints:(NSMutableArray*)eastPoints southPoints:(NSMutableArray*)southPoints withMapView:(MKMapView *)mapView{
    if (westPoints.count == 0) {
        NSLog(@"没点了还绘制啥啊,但是东西还是要清除！");
        [_millonPoints removeAllObjects];
        [_allRoutePoints removeAllObjects];
        [_kuochongPoints removeAllObjects];
        [_routePoints removeAllObjects];
        [_routeLocations removeAllObjects];
    }
    else{
        [self cleanAllPointsWithMapView:mapView];
        [self fetchQinxieRouteLocations:westPoints northPoints:northPoints eastPoints:eastPoints southPoints:southPoints];
        [self setRouteLocation:_routeLocations withMapView:mapView];
    }
    
}


//定义这个方法来解决拖动overlays的优化问题

- (void)updateRouteViewForTT:(double)changed_x changed_y:(double)changed_y withMapView:(MKMapView *)mapView{

    for (int i = 0; i < _routeLocations.count; i++) {
        CLLocation * location = [_routeLocations objectAtIndex:i];
        location = [[CLLocation alloc] initWithLatitude:location.coordinate.latitude + changed_x longitude:location.coordinate.longitude + changed_y];
        _routeLocations[i] = location;
    }
    

    NSArray* annos = [NSArray arrayWithArray:mapView.annotations];
    for (int i = 0; i < annos.count; i++) {
        id<MKAnnotation> ann = [annos objectAtIndex:i];
        if ([ann isKindOfClass: [DJIRouteAnnotion class]]) {
            [mapView removeAnnotation:ann];
        }
        
    }
    
    [self setRouteLocation:_routeLocations withMapView:mapView];
    
}

@end
