//
//  AppDelegate.m
//  qzh
//
//  Created by xianming on 2018/1/19.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#import "JPUSHService.h"
#import "JSHAREService.h"

// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
// 如果需要使用idfa功能所需要引入的头文件（可选）
#import <AdSupport/AdSupport.h>

#import <WebKit/WebKit.h>
#define JG_APP_KEY @"1e4feaf6946a7e11f3a23f0c";//乐豆
#import "AppDelegate.h"
#import "Util.h"
#import "LoginViewControllerF.h"



NSString *wxLogBack;

@interface AppDelegate ()<JPUSHRegisterDelegate>{
    
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [NSThread sleepForTimeInterval:1];
    
    LoginViewControllerF *rootVC = [[LoginViewControllerF alloc]init ];
    UINavigationController *navVC = [[UINavigationController alloc]initWithRootViewController:rootVC];
    self.window.rootViewController = navVC;
    [self.window makeKeyAndVisible];
    
    //jspush
    //在线程中启动会有警告,无法准确统计推送数量
    [self threaadStartJpush:launchOptions];
    //清空通知数量
    [self resetBageNumber];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            if (@available(iOS 10.0, *)) {
                _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"qzh"];
            } else {
                // Fallback on earlier versions
            }
            if (@available(iOS 10.0, *)) {
                [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                    if (error != nil) {
                        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                        abort();
                    }
                }];
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

//jpush  ===========================================================================================
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}

//根据情况而定
-(void)resetBageNumber
{
    //清除app又上角的通知,但是不清除通知同送；下面的代码不行，哈哈
    UILocalNotification *clearEpisodeNotification = [[UILocalNotification alloc] init];
    clearEpisodeNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:(1*1)];
    clearEpisodeNotification.timeZone = [NSTimeZone defaultTimeZone];
    clearEpisodeNotification.applicationIconBadgeNumber = -1;
    [[UIApplication sharedApplication] scheduleLocalNotification:clearEpisodeNotification];
    //清除消息和数字
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)threaadStartJpush:(NSDictionary *)launchOptions
{
    dispatch_queue_t queue = dispatch_queue_create("startJpush", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [self startJpush:launchOptions];  //启动推送
        [self initJShare:launchOptions]; //启动注册分享
    });
}
- (void)initJShare:(NSDictionary *)launchOptions{
    
    NSString *url = @"http://wx.ldgame.com/Share/getAll?";
    url = [url stringByAppendingString:[UtilTool hbo_getEncryptString]];
    NSDictionary *nsdrict = [UtilTool hbo_getSendRequest:url];
    if (nsdrict) {
        NSString *code = [nsdrict objectForKey:@"code"];
        if (0==code.integerValue) {
            NSDictionary *data = [nsdrict objectForKey:@"data"];
            NSDictionary *weixin = [data objectForKey:@"weixin"];
            NSDictionary *qq = [data objectForKey:@"qq"];
            NSDictionary *weibo = [data objectForKey:@"txweibo"];
            
            NSString *wxAppId = [weixin objectForKey:@"appid"];
            NSString *wxAppKey = [weixin objectForKey:@"secret"];
            NSString *qqAppId = [qq objectForKey:@"appid"];
            NSString *qqAppKey = [qq objectForKey:@"secret"];
            NSString *wbAppId = [weibo objectForKey:@"appid"];
            NSString *webAppKey = [weibo objectForKey:@"secret"];
            
            //注册极光分享
            JSHARELaunchConfig *config = [[JSHARELaunchConfig alloc] init];
            config.appKey = JG_APP_KEY;
            config.SinaWeiboAppKey = wbAppId;
            config.SinaWeiboAppSecret = webAppKey;
            config.SinaRedirectUri = @"https://www.jiguang.cn"; //这个字段还需要配置?!
            config.QQAppId = qqAppId;
            config.QQAppKey = qqAppKey;
            config.WeChatAppId = wxAppId;
            config.WeChatAppSecret = wxAppKey;
            config.FacebookAppID = @"";
            config.FacebookDisplayName = @"";
            config.TwitterConsumerKey = @"";
            config.TwitterConsumerSecret = @"";
            [JSHAREService setupWithConfig:config];
            [JSHAREService setDebug:YES];
        }
    }else{
        NSLog(@"注册分享功能失败");
    }
}

- (void)startJpush:(NSDictionary *)launchOptions
{
    
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    NSString *appKey = JG_APP_KEY;
    NSString *channel = @"qzhAppstore";
    Boolean isProduction = false;
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:advertisingId];
}
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{
    
    return YES;
    
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return YES;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return YES;
}

@end
