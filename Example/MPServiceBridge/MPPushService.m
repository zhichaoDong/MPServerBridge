//
//  MPPushService.m
//  MPServiceBridge_Example
//
//  Created by 董志超 on 2022/4/15.
//  Copyright © 2022 zhichaoDong. All rights reserved.
//

#import "MPPushService.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

@interface MPPushService ()<UIApplicationDelegate,UNUserNotificationCenterDelegate>
@end

@implementation MPPushService

+ (void)testLocationPush{
    //创建通知
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = @"新消息通知";
        content.subtitle = @"";
        content.body = @"某某老板向您转账一个亿!请注意查收!";
        content.badge = @1;//角标数
        content.categoryIdentifier = @"categoryIdentifier";
        content.launchImageName=@"sc";
        //声音设置 [UNNotificationSound soundNamed:@"sound.mp3"] 通知文件要放到bundle里面
        UNNotificationSound *sound = [UNNotificationSound defaultSound];
        content.sound = sound;
        
        //添加附件
        //maxinum 10M
        NSString *imageFile = [[NSBundle mainBundle] pathForResource:@"icon_push" ofType:@"png"];
        //maxinum 5M
    //    NSString *audioFile = [[NSBundle mainBundle] pathForResource:@"sound" ofType:@"mp3"];
        //maxinum 50M
        //NSString *movieFile = [[NSBundle mainBundle] pathForResource:@"movie" ofType:@"mp4"];
     
        UNNotificationAttachment *imageAttachment = [UNNotificationAttachment attachmentWithIdentifier:@"iamgeAttachment" URL:[NSURL fileURLWithPath:imageFile] options:nil error:nil];
    //    UNNotificationAttachment *audioAttachment = [UNNotificationAttachment attachmentWithIdentifier:@"audioAttachment" URL:[NSURL fileURLWithPath:audioFile] options:nil error:nil];
        //添加多个只能显示第一个
        content.attachments = @[imageAttachment];
         
        /** 通知触发机制
         Trigger 设置本地通知触发条件,它一共有以下几种类型：
         UNPushNotificaitonTrigger 推送服务的Trigger，由系统创建
         UNTimeIntervalNotificationTrigger 时间触发器，可以设置多长时间以后触发，是否重复。如果设置重复，重复时长要大于60s
         UNCalendarNotificationTrigger 日期触发器，可以设置某一日期触发
         UNLocationNotificationTrigger 位置触发器，用于到某一范围之后，触发通知。通过CLRegion设定具体范围。
         */
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
        
        //创建UNNotificationRequest通知请求对象
        NSString *requestIdentifier = @"requestIdentifier";
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:trigger];
        
        //将通知加到通知中心
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            
        }];
}

+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%s",__FUNCTION__);
    [MPPushService registerPushSericesWithApplication:application launchOptions:launchOptions];
    return YES;
}

+ (void)registerPushSericesWithApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions {
    application.applicationIconBadgeNumber = 0;
    
    if (@available(iOS 10.0, *)) {
        // iOS 10 later
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //设置监听通知的接收与点击事件的代理
        center.delegate = (id<UNUserNotificationCenterDelegate>)[MPPushService class];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error && granted) {
                //用户点击允许
                NSLog(@"注册成功");
                [MPPushService  testLocationPush];
            } else {
                //用户点击不允许
                NSLog(@"注册失败");
            }
        }];
        
    } else {
        // iOS 8 later
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound) categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    /// 注意这里注册远程推送
    [application registerForRemoteNotifications];
    
}


#pragma mark - iOS 10
#pragma mark - UNUserNotificationCenterDelegate
/// iOS 10收到消息
+ (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)) {
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"推送通知: 远程推送");
        [MPPushService didReceiveMessage:notification.request.content.userInfo];
    } else {
        NSLog(@"推送通知: 本地推送");
    }
    // Required
    // iOS 10 之后 前台展示推送的形式
    completionHandler(UNNotificationPresentationOptionAlert);
}

/// 点击推送消息
+ (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)) {
    NSLog(@"用户点击推送消息");
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (userInfo[@"aps"][@"data"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CMUserClickNotificationData" object:userInfo[@"aps"][@"data"]];
    }
    completionHandler();
}

#pragma mark - iOS 8
/// iOS 8 收到消息&点击推送消息都走这里
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (application.applicationState == UIApplicationStateActive) {
        [MPPushService didReceiveMessage:userInfo];
    } else if (application.applicationState == UIApplicationStateInactive) {
        /// 后台点击推送进来
        if (userInfo[@"aps"][@"data"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CMUserClickNotificationData" object:userInfo[@"aps"][@"data"]];
        }
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - 注册结果
/// 注册成功
+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //保存deviceToken
    NSString *deviceTokenString;
    if (@available(iOS 13.0, *)) {
        NSMutableString *deviceTokenMutString = [NSMutableString string];
        const char *bytes = deviceToken.bytes;
        NSInteger count = deviceToken.length;
        for (int i = 0; i < count; i++) {
            [deviceTokenMutString appendFormat:@"%02x", bytes[i]&0x000000FF];
        }
        deviceTokenString = deviceTokenMutString.copy;
    } else {
        deviceTokenString = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    NSLog(@"=================================== deviceTokenString：%@", deviceTokenString);
    NSUserDefaults *udf = [NSUserDefaults standardUserDefaults];
    [udf setValue:deviceTokenString forKey:@"device_token"];
    [udf synchronize];
}
/// 注册失败
+ (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSUserDefaults *udf = [NSUserDefaults standardUserDefaults];
    [udf setValue:nil forKey:@"device_token"];
    [udf synchronize];
}


#pragma mark - actions
+ (void)didReceiveMessage:(NSDictionary *)userInfo {
    NSLog(@"收到推送：%@",userInfo);
}

@end

