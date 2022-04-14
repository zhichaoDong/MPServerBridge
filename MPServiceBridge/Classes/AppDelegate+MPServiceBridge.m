//
//  AppDelegate+MPServiceBridge.m
//  MPServiceBridge
//
//  Created by zhichaoDong on 2020/3/14.
//

#import "AppDelegate+MPServiceBridge.h"
#import <objc/runtime.h>

const char k_serverStoreKey;

@interface AppDelegate ()
@property (nonatomic, strong) NSMutableDictionary * serviceStore;
@end

@implementation AppDelegate (MPServiceBridge)

+ (instancetype)shared {
    static id _bridge = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _bridge = [[self alloc] init];
    });
    return _bridge;
}

- (NSMutableDictionary *)serviceStore{
    NSMutableDictionary * store = objc_getAssociatedObject(self, &k_serverStoreKey);
    if (!store) {
        store = [NSMutableDictionary new];
        objc_setAssociatedObject(self, &k_serverStoreKey, store, OBJC_ASSOCIATION_RETAIN);
    }
    return store;
}

#pragma mark - Public
+ (void)mp_registerServiceDict:(NSDictionary *)serverDict{
    NSArray * classList = serverDict.allKeys;
    NSArray * protocolList = serverDict.allValues;
    for (int i=0; i<classList.count; i++) {
        NSString * classStr = classList[i];
        Class class = NSClassFromString(classStr);
        
        NSString * protoStr = protocolList[i];
        Protocol * protocol = NSProtocolFromString(protoStr);
        [AppDelegate registerService:class andProtocol:protocol];
    }
}

+ (void)mp_serviceClassByProtocol:(Protocol *)protocol classBlock:(void(^)(Class class))classBlock{
    NSArray * classList =  [AppDelegate shared].serviceStore.allKeys;
    for (int i=0; i<classList.count; i++) {
        NSString * classStr = classList[i];
        Class class = NSClassFromString(classStr);
        if (classBlock && class) {
            classBlock(class);
        }
    }
}

#pragma mark - Private
+ (void)registerService:(Class)a_class andProtocol:(Protocol *)protocol {
    NSAssert3([a_class conformsToProtocol:protocol],@"【%@ Debug Msg】%@ is not conforms %@!",[self class],NSStringFromClass(a_class),NSStringFromProtocol(protocol));
    if ([a_class conformsToProtocol:protocol])
    {
        NSString * className = NSStringFromClass(a_class);
        AppDelegate * bridge = [AppDelegate shared];
        [bridge.serviceStore setValue:NSStringFromProtocol(protocol)
                                             forKey:className];
    }
}

+ (Class)serviceForProtocol:(Protocol *)protocol {
    NSString * className = [[AppDelegate shared].serviceStore valueForKey:NSStringFromProtocol(protocol)];
    NSAssert1(className,@"【%@ Debug Msg】not find Service class!",[self class]);
    return NSClassFromString(className);
}

@end
