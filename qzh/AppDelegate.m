//
//  AppDelegate.m
//  qzh
//
//  Created by xianming on 2018/1/19.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

//jpush============
// 引入Jg功能所需头文件
#import "JPUSHService.h"
#import "JSHAREService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
// 如果需要使用idfa功能所需要引入的头文件（可选）
#import <AdSupport/AdSupport.h>

//#import <TencentOpenAPI/QQApiInterface.h>
//#import <TencentOpenAPI/TencentOAuth.h>

#import "WXApi.h"
#import "WXApiObject.h"

#import <WebKit/WebKit.h>

//#define JG_APP_KEY @"36cefe5825971b84eb09c1fd";//卡卡
#define JG_APP_KEY @"1e4feaf6946a7e11f3a23f0c";//乐豆


//============


#import "AppDelegate.h"
#import "Util.h"

NSString *wxLogBack;

@interface AppDelegate ()<JPUSHRegisterDelegate,WXApiDelegate>{
    NSString *WX_APPID;
    NSString *WX_SECRET_ID;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   //jspush
    //在线程中启动会有警告,无法准确统计推送数量
    [self threaadStartJpush:launchOptions];
    //清空通知数量
    [self resetBageNumber];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"qzh"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
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
        //*****************1. 通过队列多线程来异步加载图片*****************
        /*
         NSOperationQueue *queue = [[NSOperationQueue alloc]init];
         NSInvocationOperation *op = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(downLoadImage) object:nil];
         [queue addOperation:op];
         */
        
        //**********2. 通过NSObject的performSelectorInBackground多线程方法来异步请求图片**********//
        //[self performSelectorInBackground:@selector(downLoadImage) withObject:nil];
        
        
        //***************3. 通过GCD的方式创建一个新的线程来异步加载图片***************//
        dispatch_queue_t queue = dispatch_queue_create("startJpush", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(queue, ^{
            [self startJpush:launchOptions];  //启动推送
            [self initJShare:launchOptions]; //启动注册分享
        });
    }
- (void)initJShare:(NSDictionary *)launchOptions{
    
    NSString *url = @"http://wx.ldgame.com/Share/getAll?";
    url = [url stringByAppendingString:[UtilTool getEncryptString]];
    NSDictionary *nsdrict = [UtilTool getSendRequest:url];
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

            WX_APPID = wxAppId;
            WX_SECRET_ID =wxAppKey;

            //微信登陆|支付需要
            [WXApi registerApp:wxAppId enableMTA:NO];
            //libc++abi.dylib: terminating with uncaught exception of type NSException,请配置enableMTA no
            //-Objc -all_load
            
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
            config.FacebookAppID = @"1847959632183996";
            config.FacebookDisplayName = @"JShareDemo";
            config.TwitterConsumerKey = @"4hCeIip1cpTk9oPYeCbYKhVWi";
            config.TwitterConsumerSecret = @"DuIontT8KPSmO2Y1oAvby7tpbWHJimuakpbiAUHEKncbffekmC";
            [JSHAREService setupWithConfig:config];
            [JSHAREService setDebug:YES];
        }
    }else{
        NSLog(@"注册分享功能失败");
    }
}
    
- (void)startJpush:(NSDictionary *)launchOptions
    {
        
        // Override point for customization after application launch.
        //Required
        //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            // 可以添加自定义categories
            // NSSet<UNNotificationCategory *> *categories for iOS10 or later
            // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
        }
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
        
        
        // Optional
        // 获取IDFA
        // 如需使用IDFA功能请添加此代码并在初始化方法的advertisingIdentifier参数中填写对应值
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


//微信，QQ,新浪并列回调句柄
/*! @brief 处理微信通过URL启动App时传递的数据
 * 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
 * @param url 微信启动第三方应用时传递过来的URL
 * @return 成功返回YES，失败返回NO。
 */
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{

//    [QQApiInterface handleOpenURL:url delegate:self];
//    [TencentOAuth HandleOpenURL:url];
      [WXApi handleOpenURL:url delegate:self];
    
    //微信h5支付->弹出页面->拉起本身app,此时需要删除多余的控件层
    NSString *urlSchemeStr = [url absoluteString];
    NSString *scehma = @"fungameqzh1://";
    if ([urlSchemeStr hasPrefix:scehma]) {
        UIViewController *vc = (UIViewController *)self.window.rootViewController;
        NSArray *views = [vc.self.view subviews];
        [UtilTool deletePayView: views];
    }
    
    return true;

}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [WXApi handleOpenURL:url delegate:self];
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    [JSHAREService handleOpenUrl:url];
    return YES;
//    if (YES == [TencentOAuth CanHandleOpenURL:url]){
//        return [TencentOAuth HandleOpenURL:url];
//    }else{
//        return [WXApi handleOpenURL:url delegate:self];
//    }
}

//通过调用获取用户信息接口，获取用户在第三方平台的用户 ID、头像等资料完成账号体系的构建。
+(void) getSocialUserInfo:(JSHAREPlatform)platform handler:(JSHARESocialHandler)handler{
    [JSHAREService getSocialUserInfo:platform handler:^(JSHARESocialUserInfo *userInfo, NSError *error) {
        NSString *alertMessage;
        NSString *title;
        if (error) {
            title = @"失败";
            alertMessage = @"无法获取到用户信息";
        }else{
            title = userInfo.name;
            alertMessage = [NSString stringWithFormat:@"昵称: %@\n 头像链接: %@\n 性别: %@\n",userInfo.name,userInfo.iconurl,userInfo.gender == 1? @"男" : @"女"];
        }
        UIAlertView *Alert = [[UIAlertView alloc] initWithTitle:title message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [Alert show];
        });
    }];
}


/* 微信回调，不管是登录还是分享成功与否，都是走这个方法 @brief 发送一个sendReq后，收到微信的回应
 * qq登陆回掉
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * resp具体的回应内容，是自动释放的
 */
-(void) onResp:(BaseResp*)resp{
    switch (resp.errCode) {
        case 0://用户同意
        {
            //0 success -1 fail -2 cacel等
//            if([resp isKindOfClass:[PayResp class]]){//微信支付
//                [UtilTool doAlert:@"支付成功"];
//            }
//            if([resp isKindOfClass:[SendMessageToWXResp class]]){//微信分享
//            }
            if([resp isKindOfClass:[SendAuthResp class]]){//微信登陆
                SendAuthResp *aresp = (SendAuthResp *)resp;
                [self weChatCallBackWithCode:aresp.code];
            }
        }
            break;
        case -4://用户拒绝授权
            //do ...
            break;
        case -2://用户取消
            //do ...
            break;
        default:
            break;
    }
}
- (void)weChatCallBackWithCode:(NSString *)code{
    NSString *url = @"https://api.weixin.qq.com/sns/oauth2/access_token?appid=";
    url = [url stringByAppendingString:WX_APPID];
    url = [url stringByAppendingString:@"&secret="];
    url = [url stringByAppendingString:WX_SECRET_ID];
    url = [url stringByAppendingString:@"&code="];
    url = [url stringByAppendingString:code];
    url = [url stringByAppendingString:@"&grant_type=authorization_code"];
    NSDictionary *resp = [UtilTool getSendRequest:url];
    if (nil!=resp) {
        NSString *access_token =[resp objectForKey:@"access_token"];
        NSString *openid = [resp objectForKey:@"openid"];
        [self getUserInfoWithAccessToken:access_token andOpenId:openid];
    }
}
//wx获取用户信息
- (void)getUserInfoWithAccessToken:(NSString *)accessToken andOpenId:(NSString *)openId{
    NSString *url2 = @"https://api.weixin.qq.com/sns/userinfo?access_token=";
    url2 = [url2 stringByAppendingString:accessToken];
    url2 = [url2 stringByAppendingString:@"&openid="];
    url2 = [url2 stringByAppendingString:openId];
    NSDictionary *resp2 = [UtilTool getSendRequest:url2];
    if (nil!=url2) {
        //这里还不知道如何回掉主线程 调用js先，弹出来看看数据吧
        UIViewController *vc = (UIViewController *)self.window.rootViewController;
        NSArray *views = [vc.self.view subviews];
        WKWebView *webview = [views lastObject];
        NSString *data = [UtilTool convertToJSONData:resp2];
        NSDictionary * dic3 = @{@"mcmd":@"2",@"scmd":@"1",@"data":data};
        NSString *jsstring = [@"appCalljs('" stringByAppendingString:[UtilTool convertToJSONData:dic3]];
        jsstring = [jsstring stringByAppendingString:@"')"];
        jsstring = [jsstring stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSLog(@"微信登陆信息%@",jsstring);
//        [UtilTool appCalljs:webview jsString:jsstring];
    }else{
        [UtilTool doAlert:@"登陆失败"];
    }
}
// 处理QQ在线状态的回调
- (void)isOnlineResponse:(NSDictionary *)response {
    NSLog(@" ----isOnlineResponse %@",response);
}

/**
 处理来至QQ的请求
 */
//- (void)onReq:(QQBaseReq *)req{
//    NSLog(@" ----QQBaseReq %@",req);
//}

//zfb支付------------

//------------

@end
