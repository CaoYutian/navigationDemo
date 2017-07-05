//
//  RouteAnnotation.m
//  IphoneMapSdkDemo
//
//  Created by wzy on 16/8/31.
//  Copyright © 2016年 Baidu. All rights reserved.
//

#import "RouteAnnotation.h"
#import "UIImage+Rotate.h"

@implementation RouteAnnotation

@synthesize type = _type;
@synthesize degree = _degree;

- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview
{
    BMKAnnotationView* view = nil;
    switch (_type) {
        case 0:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"start_node"];
                view.image = IMAGENAMED(@"icon_start");
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
            }
        }
            break;
        case 1:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"end_node"];
                view.image = IMAGENAMED(@"end_node");
//                [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"icon_nav_end.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
            }
        }
            break;
        case 2:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"bus_node"];
                view.image = IMAGENAMED(@"bus_node");
//                [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"icon_bus.png"]];
            }
        }
            break;
        case 3:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"rail_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"rail_node"];
                view.image = IMAGENAMED(@"rail_node");
//                [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"icon_rail.png"]];
            }
        }
            break;
        case 4:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"route_node"];
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = IMAGENAMED(@"route_node");
//            [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"icon_direction.png"]];
            view.image = [image imageRotatedByDegrees:_degree];
        }
            break;
        case 5:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"waypoint_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"waypoint_node"];
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = IMAGENAMED(@"waypoint_node");
//            [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"icon_nav_waypoint"]];
            view.image = [image imageRotatedByDegrees:_degree];
        }
            break;
            
        case 6:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bnavi_icon_location_fixed"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"bnavi_icon_location_fixed"];
            }
            view.image = IMAGENAMED(@"bnavi_icon_location_fixed");
            [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"icon_stairs.png"]];
        }
            break;
        default:
            break;
    }
    if (view) {
        view.annotation = self;
        view.canShowCallout = YES;
    }
    return view;
}

- (NSString*)getMyBundlePath1:(NSString *)filename{
    
    NSBundle * libBundle = MYBUNDLE ;
    if ( libBundle && filename ){
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
        return s;
    }
    return nil ;
}

@end
