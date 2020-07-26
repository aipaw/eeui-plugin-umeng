//
//  eeuiUmeng.m
//  eeuiUmeng
//
//  Created by 高一 on 2019/3/1.
//

#import "eeuiUmeng.h"
#import "WeexInitManager.h"
#import "eeuiUmengManager.h"
#import "Config.h"
#import "eeuiNewPageManager.h"

WEEX_PLUGIN_INIT(eeuiUmeng)
@implementation eeuiUmeng

+ (instancetype) sharedManager {
    static dispatch_once_t onceToken;
    static eeuiUmeng *instance;
    dispatch_once(&onceToken, ^{
        instance = [[eeuiUmeng alloc] init];
    });
    return instance;
}

//初始化友盟
- (void) didFinishLaunchingWithOptions:(NSMutableDictionary*)lanchOption
{
    NSMutableDictionary *umeng = [[Config getObject:@"umeng"] objectForKey:@"ios"];
    NSString *enabled = [NSString stringWithFormat:@"%@", umeng[@"enabled"]];
    //
    if ([enabled containsString:@"1"] || [enabled containsString:@"true"]) {
        NSString *appKey = [NSString stringWithFormat:@"%@", umeng[@"appKey"]];
        NSString *channel = [NSString stringWithFormat:@"%@", umeng[@"channel"]];
        [[eeuiUmengManager sharedIntstance] init:appKey channel:channel launchOptions:lanchOption];
    }
}

//注册成功
- (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[[[deviceToken description ] stringByReplacingOccurrencesOfString: @"<" withString:@"" ]
                        stringByReplacingOccurrencesOfString: @">" withString:@""]
                       stringByReplacingOccurrencesOfString: @" " withString:@""
                       ];
    [eeuiUmengManager sharedIntstance].token = @{@"status":@"success", @"msg": @"", @"token": token};
    [[eeuiNewPageManager sharedIntstance] postMessage:@{@"messageType": @"umengToken", @"token": token}];
}

//注册失败
- (void) didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [eeuiUmengManager sharedIntstance].token = @{@"status":@"error", @"msg": [error localizedDescription], @"token": @""};
}

//iOS10以下使用这两个方法接收通知，
-(void) didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [UMessage setAutoAlert:NO];
    if([[[UIDevice currentDevice] systemVersion]intValue] < 10){
        [UMessage didReceiveRemoteNotification:userInfo];
    }
    [self pushInfo:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

//iOS10新增：处理前台收到通知的代理方法
-(void) willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于前台时的远程推送接受
        //关闭U-Push自带的弹出框
        [UMessage setAutoAlert:NO];
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
    }else{
        //应用处于前台时的本地推送接受
    }
    //当应用处于前台时提示设置，需要哪个可以设置哪一个
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}


//iOS10新增：处理后台点击通知的代理方法
-(void) didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        [self pushInfo:userInfo];
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
    }else{
        //应用处于后台时的本地推送接受
    }
}

- (void) pushInfo:(NSDictionary*)info
{
    NSNotification *notification =[NSNotification notificationWithName:kUmengNotification object:nil userInfo:info];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
