//
//  RouteSearchDemoViewController.h
//  BaiduMapApiDemo
//
//  Copyright 2011 Baidu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

@interface RouteSearchDemoViewController : UIViewController<BMKMapViewDelegate, BMKRouteSearchDelegate,BMKLocationServiceDelegate,BMKOpenPanoramaDelegate> {
	IBOutlet BMKMapView* _mapView;
	IBOutlet UITextField* _startCityText;
	IBOutlet UITextField* _startAddrText;
	IBOutlet UITextField* _endCityText;
	IBOutlet UITextField* _endAddrText;
    BMKRouteSearch* _routesearch;
    BMKLocationService* _locService;
}

-(IBAction)onClickBusSearch;
-(IBAction)onClickDriveSearch;
-(IBAction)onClickWalkSearch;
- (IBAction)onClickRidingSearch:(id)sender;
- (IBAction)onClickNewBusSearch:(id)sender;
- (IBAction)textFiledReturnEditing:(id)sender;
- (IBAction)navigationAction:(id)sender;


@end
