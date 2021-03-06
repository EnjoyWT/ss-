//
//  AppDelegate.m
//  XHGTY
//
//  Created by 杨健 on 2016/11/15.
//  Copyright © 2016年 杨健. All rights reserved.
//

#import "AppDelegate.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import "ThirdSDKDefine.h"

#import <AMapFoundationKit/AMapFoundationKit.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WebViewController.h"
#import "WXApi.h"
#import "HttpTools.h"
#import "UMessage.h"
#import "SVProgressHUD.h"
#import <JSPatchPlatform/JSPatch.h>

// 引入JPush功能所需头文件
#import "AppModel.h"
#import "JPUSHService.h"
#import "WKWebViewController.h"

#import "DHGuidePageHUD.h"
#import <AMapFoundationKit/AMapFoundationKit.h>

#import <AMapSearchKit/AMapSearchKit.h>
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif


static NSString *appKey = @"dcd205f49eadbac179b60c1e";
static NSString *channel = @"App Store";


@interface AppDelegate ()<JPUSHRegisterDelegate,UNUserNotificationCenterDelegate>

@property (nonatomic,strong)UIStoryboard *story;

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
   [AMapServices sharedServices].apiKey = GDMapKey;
    
    
    
    [JSPatch startWithAppKey:JSpatchKey];
    [JSPatch setupRSAPublicKey:@"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDFdJzeIDB+0y8lb5OzYBJcW3Nn\nF90KGrEJVWbrBeAZtGM8fmjkH1Z/nMs13XTRv6iOSjhtCpA+tm8itwT4Ekd067ln\nd3DizrTIuSRiLYpLUlKePy2TPmZmyUSl7eA4m9iFDx0jEYFdAtzwRHT1YrqvQJTp\nirbngh42uNzPtHyIWQIDAQAB\n-----END PUBLIC KEY-----"];
    [JSPatch sync];

    
    


    [[UINavigationBar appearance] setBarTintColor:[[UIColor alloc] initWithRed:237/255.0 green:31/255.0 blue:65/255.0 alpha:1]];
    [self shareSDKInterGration];
 
    application.statusBarHidden = NO;
    

    [[UITabBar appearance]setTintColor:[UIColor redColor]];
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSForegroundColorAttributeName:[UIFont systemFontOfSize:32]}];
    
    
 //   [self setXh];
    
    [UMessage startWithAppkey:UMKey launchOptions:launchOptions httpsEnable:YES ];
    [UMessage openDebugMode:YES];

    //注册通知
    [UMessage registerForRemoteNotifications];
    //iOS10必须加下面这段代码。
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate=self;
    UNAuthorizationOptions types10=UNAuthorizationOptionBadge|UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:types10 completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            //点击允许
            
        } else {
            //点击不允许
            
        }
    }];
    
    //
    //Required添加初始化APNs代码
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    [application setApplicationIconBadgeNumber:0];
    
    // Optional添加初始化JPush代码
    [JPUSHService setupWithOption:launchOptions appKey:appKey channel:channel apsForProduction:NO];
    [self savadata];

    return  YES;
}

-(void)savadata{

    
    
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0]stringByAppendingFormat:@"/Caches"];
    NSString * file = [NSString stringWithFormat:@"%@/userAccount.shouchang",path];
    if(![NSArray arrayWithContentsOfFile:file]){
    NSArray * arrary = @[@{@"time":@"2017-04-05",@"haoma":@[@"03",@"04",@"10",@"15",@"21",@"31",@"07"],@"qishu":@"2017041",@"kjtime":@"04-02 21:30"}];
      [arrary writeToFile:file atomically:YES];
    }
  

}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 
    return YES;
}


- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"token = %@",deviceToken);
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}


#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    NSLog(@"UserInfo = %@",userInfo);
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}




- (void)applicationDidBecomeActive:(UIApplication *)application{
    [JSPatch sync];
    [application setApplicationIconBadgeNumber:0];
}




- (void)shareSDKInterGration{
    
    [ShareSDK registerApp:kMobAppKey activePlatforms:@[@(SSDKPlatformTypeWechat), @(SSDKPlatformTypeQQ)] onImport:^(SSDKPlatformType platformType) {
        switch (platformType){
          
            case SSDKPlatformTypeWechat:
                [ShareSDKConnector connectWeChat:[WXApi class]];
                break;
            case SSDKPlatformTypeQQ:
                [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                break;
            default:
                break;
        }
    } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
        switch (platformType)
        {
            case SSDKPlatformTypeWechat:
                [appInfo SSDKSetupWeChatByAppId:kWeiXinAppID appSecret:kWeiXinAppSecret];
                break;
            case SSDKPlatformTypeQQ:
                [appInfo SSDKSetupQQByAppId:kQQAppID appKey:kQQAppKey authType:SSDKAuthTypeSSO];
                break;
            default:
                break;
        }
    }];
}


//NSDate -----> NSString
- (NSString *)getFormatDateStringWithDate:(NSDate *)date  withFormatStyle:(NSString *)dateFormatStyle
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormatStyle];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

-(NSString *)timeStrTotimestamp:(NSString*)timeStr withFormat:(NSString *)format{
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    //[inputFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [inputFormatter setDateFormat:format];
    NSDate* inputDate = [inputFormatter dateFromString:timeStr];
    
    NSString *timeStamp = [NSString stringWithFormat:@"%ld",(long)[inputDate timeIntervalSince1970]];
    return timeStamp;
}

@end
