//
//  AppDelegate.h
//  navigationDemo
//
//  Created by Sunshine on 2017/7/3.
//  Copyright © 2017年 Sunshine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate>{
    UINavigationController *navigationController;
}

@property (strong, nonatomic) UIWindow *window;

@end

