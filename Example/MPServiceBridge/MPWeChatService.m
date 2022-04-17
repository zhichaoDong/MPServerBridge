//
//  MPWeChatService.m
//  test
//
//  Created by 董志超 on 2022/4/14.
//

#import "MPWeChatService.h"

@interface MPWeChatService ()<UIApplicationDelegate>
@end

@implementation MPWeChatService

+   (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%s",__FUNCTION__);
    return YES;
}

+  (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"%s",__FUNCTION__);
}


@end
