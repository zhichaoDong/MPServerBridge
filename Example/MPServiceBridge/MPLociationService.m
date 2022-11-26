//
//  MPLociationService.m
//  MPServiceBridge_Example
//
//  Created by 董志超 on 2022/9/22.
//  Copyright © 2022 zhichaoDong. All rights reserved.
//

#import "MPLociationService.h"
//位置
#import <CoreLocation/CoreLocation.h>

@interface MPLociationService ()<UIApplicationDelegate,CLLocationManagerDelegate>
@end

@implementation MPLociationService
+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%s",__FUNCTION__);
    [MPLociationService registerLocationSerices];
    return YES;
}

+ (void)registerLocationSerices{
    /* 访问位置权限 */
    if([CLLocationManager locationServicesEnabled]){
        NSLog(@"开始定位");
        CLLocationManager * locationManager = [[CLLocationManager alloc]init];
        locationManager.delegate = (id<CLLocationManagerDelegate>)[MPLociationService class];
        //控制定位精度,越高耗电量越
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // 总是授权
        //if (IOS8_MORE)
        {
            //[self.locationManager requestAlwaysAuthorization];
            [locationManager requestWhenInUseAuthorization];
        }
        locationManager.distanceFilter = 10.0f;
        [locationManager startUpdatingLocation];
    }
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] == kCLErrorDenied) {
        NSLog(@"访问被拒绝");
    }
    if ([error code] == kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息");
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *newLocation = locations[0];
    //CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:37.55085 longitude:115.57938];
    NSLog(@"纬度=%f，经度=%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
//    [USER setUserLocalLatitude:[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude]];
//    [USER setUserLocalLongitude:[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude]];
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error){
        if (array.count > 0){
            CLPlacemark *placemark = [array objectAtIndex:0];
            //获取城市
            NSString *city = placemark.locality;//地区
            NSString *subCity = placemark.subLocality;//子地区
            NSString *area = placemark.administrativeArea;//行政区域
            NSString * zipCode =  placemark.postalCode;//邮编
            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placemark.administrativeArea;
            }
            NSLog(@"定位城市:%@,%@,%@", city,subCity,area);
//            [USER setUserLocalCity:city];
            
            if ([city isEqual:@"衡水市"]) {
                zipCode = @"1311";
            }else{
                zipCode = @"";
            }
//            [USER setUserLocalZipCode:zipCode];
            NSLog(@"zipCode:%@", zipCode);
            //向JS更新用户数据
//            [[NSNotificationCenter defaultCenter]postNotificationName:SEND_USERINFO_TOJS object:nil];
        }
        else if (error == nil && [array count] == 0)
        {
            NSLog(@"No results were returned.");
        }
        else if (error != nil)
        {
            NSLog(@"An error occurred = %@", error);
        }
    }];
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [manager stopUpdatingLocation];
}

@end
