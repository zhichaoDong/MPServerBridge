//
//  AppDelegate+MPServiceBridge.h
//  MPServiceBridge
//
//  Created by zhichaoDong on 2020/3/14.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (MPServiceBridge)

/// 关联Class 和 protocol (UIApplicationDelegate)
/// ⚠️:  Class 作为 key , Protocol 作为 value
/// @param serverDict Class 和 Protocol 组成的字典
/// 例子:
/// NSDictionary dict = @{
///                  "实现接口类的名称" : "绑定的协议",
///                  "实现接口类的名称" : "绑定的协议"
///                 }
+ (void)mp_registerServiceDict:(NSDictionary *)serverDict;

/// 根据protocol 取到所关联的 Class
/// @param protocol 协议(UIApplicationDelegate)
/// @param classBlock 返回该协议所关联过的类
+ (void)mp_serviceClassByProtocol:(Protocol *)protocol classBlock:(void(^)(Class class))classBlock;

@end

NS_ASSUME_NONNULL_END
