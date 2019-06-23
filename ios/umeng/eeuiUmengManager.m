
//
//  eeuiUmengManager.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/20.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiUmengManager.h"
#import <UMCommon/UMCommon.h>
#import <UMAnalytics/MobClick.h>
#import <UMCommonLog/UMCommonLogHeaders.h>

@interface eeuiUmengManager ()

@property(nonatomic,strong) NSMutableDictionary * msgidLists;

@end

@implementation eeuiUmengManager

+ (eeuiUmengManager *)sharedIntstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)init:(NSString*)key channel:(NSString*)channel launchOptions:(NSDictionary*)launchOptions
{
    NSString * deviceID =[UMConfigure deviceIDForIntegration];
    NSLog(@"集成测试的deviceID:%@", deviceID);
    //开发者需要显式的调用此函数，日志系统才能工作
    [UMCommonLogManager setUpUMCommonLogManager];
    #if DEBUG
    [UMConfigure setLogEnabled:YES];
    #endif
    [MobClick setScenarioType:E_UM_NORMAL];


    [UMConfigure initWithAppkey:key channel:channel];

    // Push's basic setting
    UMessageRegisterEntity * entity = [[UMessageRegisterEntity alloc] init];
    //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
    entity.types = UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionAlert|UMessageAuthorizationOptionSound;
    [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            // 用户选择了接收Push消息
            NSLog(@"===granted=YES===");
        }else{
            // 用户拒绝接收Push消息
            NSLog(@"===granted==NO==");
        }
    }];
}

- (void)setNotificationClickHandler:(WXModuleKeepAliveCallback)callback
{
    self.callback = callback;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationClick:) name:kUmengNotification object:nil];
}

- (void)notificationClick:(NSNotification *)notification
{
    NSDictionary *data = notification.userInfo;
    NSString *msgid = data[@"d"]?data[@"d"]:@"";
    if (_msgidLists == nil) {
        _msgidLists = [[NSMutableDictionary alloc] init];
    }
    if ([msgid isEqualToString:_msgidLists[msgid]]) {
        return;
    }
    [_msgidLists setObject:msgid forKey:msgid];
    //
    NSDictionary *alert = data[@"aps"][@"alert"];
    if ([alert isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        for (NSString * key in data) {
            if (![key isEqualToString:@"aps"] &&
                ![key isEqualToString:@"d"] &&
                ![key isEqualToString:@"p"]) {
                [extra setObject:data[key] forKey:key];
            }
        }
        NSDictionary *result = @{@"status":@"click",
                                 @"msgid":msgid,
                                 @"title":alert[@"title"]?alert[@"title"]:@"",
                                 @"subtitle":alert[@"subtitle"]?alert[@"subtitle"]:@"",
                                 @"text":alert[@"body"]?alert[@"body"]:@"",
                                 @"extra":extra,
                                 @"rawData":data};
        self.callback(result, YES);
    }

}

@end
