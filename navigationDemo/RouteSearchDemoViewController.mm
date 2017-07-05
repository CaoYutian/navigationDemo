//
//  RouteSearchDemoViewController.mm
//  BaiduMapApiDemo
//
//  Copyright 2011 Baidu Inc. All rights reserved.
//

#import "RouteSearchDemoViewController.h"
#import "WayPointRouteSearchDemoViewController.h"
#import "PoiSearchDemoViewController.h"
#import "UIImage+Rotate.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "RouteAnnotation.h"

@interface RouteSearchDemoViewController (){
    BMKOpenPanorama *_openPanorama;//调起全景类
    double JingDu;    //经度
    double WeiDu;     //维度
}

@end

@implementation RouteSearchDemoViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
//        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
	_routesearch = [[BMKRouteSearch alloc]init];
	_startCityText.text = @"北京";
	_startAddrText.text = @"摩托罗拉大厦";
	_endCityText.text = @"北京";
	_endAddrText.text = @"天安门";

    UIBarButtonItem* btnWayPoint = [[UIBarButtonItem alloc]init];
    btnWayPoint.target = self;
    btnWayPoint.action = @selector(wayPointDemo);
    btnWayPoint.title = @"途经点";
    btnWayPoint.enabled=TRUE;
    self.navigationController.topViewController.navigationItem.rightBarButtonItem = btnWayPoint;
    
    UIBarButtonItem* btnPoiSearch = [[UIBarButtonItem alloc]init];
    btnPoiSearch.target = self;
    btnPoiSearch.action = @selector(wayPoiSearch);
    btnPoiSearch.title = @"搜索";
    btnPoiSearch.enabled=TRUE;
    self.navigationController.topViewController.navigationItem.leftBarButtonItem = btnPoiSearch;
    
    _locService = [[BMKLocationService alloc]init];
    _openPanorama = [[BMKOpenPanorama alloc] init];

    [self startLocation];
}

-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _routesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    _openPanorama.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _routesearch.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _openPanorama.delegate = nil;
}

- (void)dealloc {
    if (_routesearch != nil) {
        _routesearch = nil;
    }
    if (_mapView) {
        _mapView = nil;
    }
}

#pragma mark 开始定位
- (void)startLocation {
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
//    _mapView.showsUserLocation = YES;//显示定位图层
    
    //普通定位
        _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    //跟随
//    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    //罗盘
    _mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;

    
    _mapView.showsUserLocation = YES;
}

- (void)endLocation {
    [_locService stopUserLocationService];
    _mapView.showsUserLocation = NO;
}

- (void)wayNavigation {
    
}

#pragma mark 获取位置失败
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(nonnull NSError *)error{
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"打开定位开关" message:@"定位服务未开启，进入系统【设置】 > 【隐私】 > 【定位服务】中打开开关，并允许使用使用定位服务" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"立即开启", nil];
    
    [alertview show];
}

- (void)wayPointDemo {
    WayPointRouteSearchDemoViewController * wayPointCont = [[WayPointRouteSearchDemoViewController alloc]init];
    wayPointCont.title = @"驾车途经点";
    UIBarButtonItem *customLeftBarButtonItem = [[UIBarButtonItem alloc] init];
    customLeftBarButtonItem.title = @"返回";
    self.navigationItem.backBarButtonItem = customLeftBarButtonItem;
    [self.navigationController pushViewController:wayPointCont animated:YES];
}

- (void)wayPoiSearch {
    PoiSearchDemoViewController * wayPointCont = [[PoiSearchDemoViewController alloc]init];
    wayPointCont.title = @"搜索";
    UIBarButtonItem *customLeftBarButtonItem = [[UIBarButtonItem alloc] init];
    customLeftBarButtonItem.title = @"返回";
    self.navigationItem.backBarButtonItem = customLeftBarButtonItem;
    [self.navigationController pushViewController:wayPointCont animated:YES];
}

#pragma mark - BMKMapViewDelegate
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[RouteAnnotation class]]) {
		return [(RouteAnnotation*)annotation getRouteAnnotationView:view];
	}
	return nil;
}

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
	if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor alloc] initWithRed:0 green:1 blue:1 alpha:1];
        polylineView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
	return nil;
}

#pragma mark - BMKRouteSearchDelegate
- (void)onGetTransitRouteResult:(BMKRouteSearch*)searcher result:(BMKTransitRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"onGetTransitRouteResult error:%d", (int)error);
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
	[_mapView removeAnnotations:array];
	array = [NSArray arrayWithArray:_mapView.overlays];
	[_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
		BMKTransitRouteLine* plan = (BMKTransitRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
		NSInteger size = [plan.steps count];
		int planPointCounts = 0;
		for (int i = 0; i < size; i++) {
            BMKTransitStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                
            }
            if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.instruction;
            item.type = 3;
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKTransitStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
		BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
		[_mapView addOverlay:polyLine]; // 添加路线overlay
		delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR) {
        //检索地址有歧义,返回起点或终点的地址信息结果：BMKSuggestAddrInfo，获取到推荐的poi列表
        NSLog(@"检索地址有岐义，请重新输入。");
        [self showGuide];
    }
}
- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"onGetDrivingRouteResult error:%d", (int)error);
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
	[_mapView removeAnnotations:array];
	array = [NSArray arrayWithArray:_mapView.overlays];
	[_mapView removeOverlays:array];
	if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
		NSInteger size = [plan.steps count];
		int planPointCounts = 0;
		for (int i = 0; i < size; i++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                
            }
            if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            
            NSLog(@"%@   %@    %@", transitStep.entraceInstruction, transitStep.exitInstruction, transitStep.instruction);
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        // 添加途经点
        if (plan.wayPoints) {
            for (BMKPlanNode* tempNode in plan.wayPoints) {
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item = [[RouteAnnotation alloc]init];
                item.coordinate = tempNode.pt;
                item.type = 5;
                item.title = tempNode.name;
                [_mapView addAnnotation:item];
            }
        }
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
		BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
		[_mapView addOverlay:polyLine]; // 添加路线overlay
		delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR) {
        //检索地址有歧义,返回起点或终点的地址信息结果：BMKSuggestAddrInfo，获取到推荐的poi列表
        NSLog(@"检索地址有岐义，请重新输入。");
        [self showGuide];
    }
}

- (void)onGetWalkingRouteResult:(BMKRouteSearch*)searcher result:(BMKWalkingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"onGetWalkingRouteResult error:%d", (int)error);
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
	[_mapView removeAnnotations:array];
	array = [NSArray arrayWithArray:_mapView.overlays];
	[_mapView removeOverlays:array];
	if (error == BMK_SEARCH_NO_ERROR) {
        BMKWalkingRouteLine* plan = (BMKWalkingRouteLine*)[result.routes objectAtIndex:0];
		NSInteger size = [plan.steps count];
		int planPointCounts = 0;
		for (int i = 0; i < size; i++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                
            }
            if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
		BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
		[_mapView addOverlay:polyLine]; // 添加路线overlay
		delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR) {
        //检索地址有歧义,返回起点或终点的地址信息结果：BMKSuggestAddrInfo，获取到推荐的poi列表
        NSLog(@"检索地址有岐义，请重新输入。");
        [self showGuide];
    }
}

/**
 *返回骑行搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果，类型为BMKRidingRouteResult
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetRidingRouteResult:(BMKRouteSearch *)searcher result:(BMKRidingRouteResult *)result errorCode:(BMKSearchErrorCode)error {
    NSLog(@"onGetRidingRouteResult error:%d", (int)error);
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKRidingRouteLine* plan = (BMKRidingRouteLine*)[result.routes objectAtIndex:0];
        NSInteger size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKRidingStep* transitStep = [plan.steps objectAtIndex:i];
            if (i == 0) {
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.instruction;
            item.degree = (int)transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKRidingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR) {
        //检索地址有歧义,返回起点或终点的地址信息结果：BMKSuggestAddrInfo，获取到推荐的poi列表
        NSLog(@"检索地址有岐义，请重新输入。");
        [self showGuide];
    }
}

/**
 *返回公共交通路线检索结果（new）
 *@param searcher 搜索对象
 *@param result 搜索结果，类型为BMKMassTransitRouteResult
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetMassTransitRouteResult:(BMKRouteSearch*)searcher result:(BMKMassTransitRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"onGetMassTransitRouteResult error:%d", (int)error);
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKMassTransitRouteLine* routeLine = (BMKMassTransitRouteLine*)[result.routes objectAtIndex:0];
        
        BOOL startCoorIsNull = YES;
        CLLocationCoordinate2D startCoor;//起点经纬度
        CLLocationCoordinate2D endCoor;//终点经纬度
        
        NSInteger size = [routeLine.steps count];
        NSInteger planPointCounts = 0;
        for (NSInteger i = 0; i < size; i++) {
            BMKMassTransitStep* transitStep = [routeLine.steps objectAtIndex:i];
            for (BMKMassTransitSubStep *subStep in transitStep.steps) {
                //添加annotation节点
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = subStep.entraceCoor;
                item.title = subStep.instructions;
                item.type = 2;
                [_mapView addAnnotation:item];
                
                if (startCoorIsNull) {
                    startCoor = subStep.entraceCoor;
                    startCoorIsNull = NO;
                }
                endCoor = subStep.exitCoor;
                
                //轨迹点总数累计
                planPointCounts += subStep.pointsCount;

                //steps中是方案还是子路段，YES:steps是BMKMassTransitStep的子路段（A到B需要经过多个steps）;NO:steps是多个方案（A到B有多个方案选择）
                if (transitStep.isSubStep == NO) {//是子方案，只取第一条方案
                    break;
                }
                else {
                    //是子路段，需要完整遍历transitStep.steps
                }
            }
        }
        
        //添加起点标注
        RouteAnnotation* startAnnotation = [[RouteAnnotation alloc]init];
        startAnnotation.coordinate = startCoor;
        startAnnotation.title = @"起点";
        startAnnotation.type = 0;
        [_mapView addAnnotation:startAnnotation]; // 添加起点标注
        //添加终点标注
        RouteAnnotation* endAnnotation = [[RouteAnnotation alloc]init];
        endAnnotation.coordinate = endCoor;
        endAnnotation.title = @"终点";
        endAnnotation.type = 1;
        [_mapView addAnnotation:endAnnotation]; // 添加终点标注
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        NSInteger index = 0;
        for (BMKMassTransitStep* transitStep in routeLine.steps) {
            for (BMKMassTransitSubStep *subStep in transitStep.steps) {
                for (NSInteger i = 0; i < subStep.pointsCount; i++) {
                    temppoints[index].x = subStep.points[i].x;
                    temppoints[index].y = subStep.points[i].y;
                    index++;
                }
                
                //steps中是方案还是子路段，YES:steps是BMKMassTransitStep的子路段（A到B需要经过多个steps）;NO:steps是多个方案（A到B有多个方案选择）
                if (transitStep.isSubStep == NO) {//是子方案，只取第一条方案
                    break;
                }
                else {
                    //是子路段，需要完整遍历transitStep.steps
                }
            }
        }
        
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR) {
        //检索地址有歧义,返回起点或终点的地址信息结果：BMKSuggestAddrInfo，获取到推荐的poi列表
        NSLog(@"检索地址有岐义，请重新输入。");
        [self showGuide];
    }
}

#pragma mark - action
-(IBAction)onClickBusSearch
{
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
	start.name = _startAddrText.text;
	BMKPlanNode* end = [[BMKPlanNode alloc]init];
	end.name = _endAddrText.text;
    
    BMKTransitRoutePlanOption *transitRouteSearchOption = [[BMKTransitRoutePlanOption alloc]init];
    transitRouteSearchOption.city= @"北京市";
    transitRouteSearchOption.from = start;
    transitRouteSearchOption.to = end;
    BOOL flag = [_routesearch transitSearch:transitRouteSearchOption];
    
    if(flag) {
        NSLog(@"bus检索发送成功");
    }
    else {
        NSLog(@"bus检索发送失败");
    }
}

-(IBAction)textFiledReturnEditing:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)navigationAction:(id)sender {

    //初始化调启导航时的参数管理类
    BMKNaviPara* para = [[BMKNaviPara alloc]init];
    //初始化起点节点
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    //指定起点经纬度
    CLLocationCoordinate2D coor1;
    coor1.latitude = WeiDu;
    coor1.longitude = JingDu;
    start.pt = coor1;
    //指定起点名称
    start.name = @"摩托罗拉大厦";
    //指定起点
    para.startPoint = start;
    
    //初始化终点节点
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    //指定终点经纬度
    CLLocationCoordinate2D coor2;
    coor2.latitude = 39.90868;
    coor2.longitude = 116.3956;
    end.pt = coor2;
    //指定终点名称
    end.name = @"天安门";
    //指定终点
    para.endPoint = end;
    
    //指定返回自定义scheme
    para.appScheme = @"baidumapsdk://mapsdk.baidu.com";
    
    //调启百度地图客户端导航
    [BMKNavigation openBaiduMapNavigation:para];

}

-(IBAction)onClickDriveSearch
{
	BMKPlanNode* start = [[BMKPlanNode alloc]init];
	start.name = _startAddrText.text;
    start.cityName = @"北京市";
	BMKPlanNode* end = [[BMKPlanNode alloc]init];
	end.name = _endAddrText.text;
    end.cityName = @"北京市";
    
    BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
    drivingRouteSearchOption.from = start;
    drivingRouteSearchOption.to = end;
    drivingRouteSearchOption.drivingRequestTrafficType = BMK_DRIVING_REQUEST_TRAFFICE_TYPE_NONE;//不获取路况信息
    BOOL flag = [_routesearch drivingSearch:drivingRouteSearchOption];
    if(flag)
    {
        NSLog(@"car检索发送成功");
    }
    else
    {
        NSLog(@"car检索发送失败");
    }

}

-(IBAction)onClickWalkSearch
{    
	BMKPlanNode* start = [[BMKPlanNode alloc]init];
	start.name = _startAddrText.text;
    start.cityName = _startCityText.text;
	BMKPlanNode* end = [[BMKPlanNode alloc]init];
	end.name = _endAddrText.text;
    end.cityName = _endCityText.text;

    
    BMKWalkingRoutePlanOption *walkingRouteSearchOption = [[BMKWalkingRoutePlanOption alloc]init];
    walkingRouteSearchOption.from = start;
    walkingRouteSearchOption.to = end;
    BOOL flag = [_routesearch walkingSearch:walkingRouteSearchOption];
    if(flag)
    {
        NSLog(@"walk检索发送成功");
    }
    else
    {
        NSLog(@"walk检索发送失败");
    }

}

- (IBAction)onClickRidingSearch:(id)sender {
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.name = _startAddrText.text;
    start.cityName = _startCityText.text;
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.name = _endAddrText.text;
    end.cityName = _endCityText.text;
    
    BMKRidingRoutePlanOption *option = [[BMKRidingRoutePlanOption alloc]init];
    option.from = start;
    option.to = end;
    BOOL flag = [_routesearch ridingSearch:option];
    if (flag)
    {
        NSLog(@"骑行规划检索发送成功");
    }
    else
    {
        NSLog(@"骑行规划检索发送失败");
    }
}

//新公交路线规划 - 支持跨城公交
- (IBAction)onClickNewBusSearch:(id)sender {
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.name = _startAddrText.text;
    start.cityName = _startCityText.text;
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.name = _endAddrText.text;
    end.cityName = _endCityText.text;
    
    BMKMassTransitRoutePlanOption *option = [[BMKMassTransitRoutePlanOption alloc]init];
    option.from = start;
    option.to = end;
    BOOL flag = [_routesearch massTransitSearch:option];
    
    if(flag) {
        NSLog(@"公交交通检索（支持垮城）发送成功");
    } else {
        NSLog(@"公交交通检索（支持垮城）发送失败");
    }
}

#pragma mark - 私有
//根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [_mapView setVisibleMapRect:rect];
    _mapView.zoomLevel = _mapView.zoomLevel - 0.3;
}

//检索提示
-(void)showGuide
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"检索提示"
                                                    message:@"检索地址有岐义，请重新输入。"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
//    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
        NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
    
    JingDu = userLocation.location.coordinate.longitude;
    WeiDu = userLocation.location.coordinate.latitude;
}

@end
