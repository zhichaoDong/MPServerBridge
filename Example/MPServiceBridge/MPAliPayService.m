//
//  MPAliPayService.m
//  test
//
//  Created by 董志超 on 2022/4/14.
//

#import "MPAliPayService.h"

@interface MPAliPayService ()<UIApplicationDelegate>
@end

@implementation MPAliPayService
+  (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%s",__FUNCTION__);
    return YES;
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"%s",__FUNCTION__);
}


@end
