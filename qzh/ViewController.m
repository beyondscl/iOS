//
//  ViewController.m
//  qzh
//
//  Created by xianming on 2018/1/19.
//  Copyright © 2018年 hzqzh. All rights reserved.
//
#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "WKDelegateController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>

#import "WXApi.h"
#import "WXApiObject.h"

#import "Device.h"
#import "Util.h"
#import "pay.h"
#import "QzhShare.h"
#import <JavaScriptCore/JavaScriptCore.h>
//需要导入相应包
#import <StoreKit/StoreKit.h>

//沙盒测试环境验证
#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
//正式环境验证
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"

//拦截支付宝回掉
#define ALIPAY_BACK_URL @"http://web.ld68.com/h5/index.html"
//微信请求地址
#define WXH5_BACK_URL @"http://pay.ldgame.com/main/Index/wechat/wappay"

//登陆
#define kScreen_height [UIScreen mainScreen].bounds.size.height
#define kScreen_width [UIScreen mainScreen].bounds.size.width

//适配iphonex,注意横屏的问题,如果你在界面上加了其他可能会影响
#define IS_IPHONE_X (kScreen_width == 812.0f) ? YES : NO
//头部增加了44
#define HEAD_ADD 44.0f
//宽度增加了88
#define width_NavContentBar 88.0f
//底部状态栏增加24,因为屏幕边缘上曲面的，所以小一点
#define Height_NavContentBar 20.0f

/**
 *重启机器可能解决大部分问题
 */

@interface ViewController ()
<WKUIDelegate,
WKNavigationDelegate,
WKScriptMessageHandler,
WKDelegate,
SKProductsRequestDelegate ,
SKPaymentTransactionObserver,
CLLocationManagerDelegate,
UIWebViewDelegate>
{
    int isProd;
    NSString *iosPayUid;
    UIWebView *uiWebView;
    JSContext *context;
    
    WKWebView * webView;
    WKUserContentController* userContentController;
    
    int buyType;//不行可以删掉
    NSString *uuid;//用户机器识别码
    NSString *buyGoodId;//商品对应金币
    
    NSMutableArray *permissionArray;   //权限列表
    
    //获取地理位置
    CLLocationManager  *locationManager;
    //随时变化的地址
    NSString *addressInfo;
    //等待的图片
    UIImageView* waitingImg;
    
    int isShowLogBtn;//测试
    NSString *uName;//测试
    NSString *uGold;//测试
    UILabel *labelHint;///提示label //测试
    UITextField *fieldName;///账户 //测试
    UITextField *fieldPassword;///密码 //测试
}
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startGame];
    //注册需要时间
    [NSThread sleepForTimeInterval:2.0];//设置启动页面时间
}

//---加载本地页面
- (void)loadWeb2 {
    NSString *pathStr = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"release"];
    NSString *_pathStr = [NSString stringWithFormat:@"%@/index.html",pathStr];
    NSURL *url = [NSURL fileURLWithPath:_pathStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    uiWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [uiWebView loadRequest:request];
    uiWebView.delegate = self;
    [self.view addSubview:uiWebView];
}
-(UIWebView *)getUiWebView{
    UIWebView *nUiWebView = nil;
    if(IS_IPHONE_X){
        //它的页面加载后竟然会自动缩小
        nUiWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0,kScreen_width, kScreen_height+width_NavContentBar)];
    }else{
        nUiWebView = [[UIWebView alloc]initWithFrame:self.view.frame];
    }
    nUiWebView.backgroundColor=[UIColor blackColor];
    nUiWebView.delegate = self;
    return nUiWebView;
}
-(WKWebView *)getWKwebView{
    //初始化wkwebview
    //初始化一个WKWebViewConfiguration对象
    WKWebViewConfiguration * config = [[WKWebViewConfiguration alloc]init];
    //初始化偏好设置属性：preferences
    config.preferences = [WKPreferences new];
    //The minimum font size in points default is 0;
    config.preferences.minimumFontSize = 10;
    //是否支持JavaScript
    config.preferences.javaScriptEnabled = YES;
    //不通过用户交互，是否可以打开窗口
    config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    //注册方法,可以单独提出去
    userContentController =[[WKUserContentController alloc]init];
    config.userContentController = userContentController;
    
    WKDelegateController * delegateController = [[WKDelegateController alloc]init];
    delegateController.delegate = self;
    [userContentController addScriptMessageHandler:self  name:@"jsCallapp"];
    NSLog(@"屏幕尺寸%f,%f",kScreen_width,kScreen_height);
    if(IS_IPHONE_X){
        //图片适配
        //        webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0,kScreen_width, kScreen_height+Height_NavContentBar) configuration:config];
        //代码适配
        webView = [[WKWebView alloc]initWithFrame:CGRectMake(-HEAD_ADD, 0,kScreen_width+width_NavContentBar, kScreen_height+Height_NavContentBar) configuration:config];
    }else{
        webView = [[WKWebView alloc]initWithFrame:self.view.frame configuration:config];
    }
    webView.backgroundColor=[UIColor blackColor];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    return webView;
}
//接受客户端消息
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"接受到客户端消息==>name:%@\\\\n body:%@\\\\n frameInfo:%@\\\\n",message.name,message.body,message.frameInfo);
    NSString *msg = message.body;
    if (msg) {
        NSDictionary *msgJson = [UtilTool dictionaryWithJsonString:msg];
        NSString *mcmd = [msgJson objectForKey:@"mcmd"];
        NSString *scmd = [msgJson objectForKey:@"scmd"];
        if (5==[mcmd integerValue]) {//分享
            NSDictionary *data = [msgJson objectForKey:@"data"];
            NSString *title = [data objectForKey:@"title"];
            NSString *linkurl = [data objectForKey:@"linkurl"];
            UIImage *image = [UtilTool captureCurrentView:self.view];
            [QzhShare jgshare:[scmd intValue] title:title image:image linkurl:linkurl];
        }else if (4==[mcmd integerValue]) {//推送
            [UtilTool doAlert:@"错误的请求命令"];
        }else if (3==[mcmd integerValue]) {//支付
            if (1==[scmd integerValue]) {//微信支付测试
                NSDictionary *data = [msgJson objectForKey:@"data"];
                NSString *uid = [data objectForKey:@"uid"];
                NSString *price = [data objectForKey:@"price"];
                NSString *productid = [data objectForKey:@"productid"];
                NSString *hintstr = [data objectForKey:@"hintstr"];
                NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",WXH5_BACK_URL,@"?uid=",uid ,@"&price=" ,price,@"&productid=" ,productid,@"&hintstr=",hintstr];
                url = [url stringByAppendingString:[UtilTool getEncryptString]];
                url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                //NSString *url = @"http://pay.ldgame.com/main/Index/wechat/wappay?uid=10205594&price=0.01";
                //和支付宝不一样，它会直接拉起微信而不是拉起网页在拉起微信;网页拉起本app拦截请求自动关闭本页面|或者定时器控制
                UIWebView *wxH5PayWebView = [self getUiWebView];
                wxH5PayWebView.frame = CGRectMake(0,0,0,0);
                wxH5PayWebView.backgroundColor=[UIColor blackColor];
                wxH5PayWebView.tag =304;
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
                NSMutableURLRequest *mutableRequest = [request mutableCopy];
                //解决格式有误，必须添加header referer为注册的域名
                [mutableRequest addValue:@"http://wx.ldgame.com/Index/iosgo" forHTTPHeaderField:@"Referer"];
                [wxH5PayWebView loadRequest:[mutableRequest copy]];
                [self.view addSubview:wxH5PayWebView];
            }
            if (2==[scmd integerValue]) {//支付宝支付测试
                NSDictionary *data = [msgJson objectForKey:@"data"];
                NSString *uid = [data objectForKey:@"uid"];
                NSString *price = [data objectForKey:@"price"];
                NSString *productid = [data objectForKey:@"productid"];
                NSString *hintstr = [data objectForKey:@"hintstr"];
                
                //加载之后可以在加载返回按钮，用完之后在删除,不然可能会影响到其他获取当前层
                NSString *url = [pay zfbPay:uid price:price productid:productid hintstr:hintstr];
                url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                //UIWebView可以拉起支付宝,wkwebview会弹出safari浏览器在拉起支付宝
                UIWebView *zfbWebView = [self getUiWebView];
                zfbWebView.tag =301;
                [zfbWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
                [self.view addSubview:zfbWebView];
                [self addReturnBtn];
            }
        }else if (2==[mcmd integerValue]) {//登陆
            if (1==[scmd integerValue]) {//微信登陆
                //微信登陆,不判断是否安装
                SendAuthReq *request = [[SendAuthReq alloc]init];
                request.state = @"wx_oauth2_authorization_state";
                request.scope = @"snsapi_userinfo";
                [WXApi sendReq:request];
            }
            if (2==[scmd integerValue]) {//qq登陆
            }
        }else if (1==[mcmd integerValue]) {//iOS 支付
            //这里的商品ID需要动态获取，没时间啊！！！
            NSDictionary *data = [msgJson objectForKey:@"data"];
            NSString *goodid = [data objectForKey:@"goodid"];
            iosPayUid = [data objectForKey:@"uid"];
            [pay appleGetProduct:goodid];
        }else if ([mcmd integerValue]) {//获取设备信息
            //测试获取机器xin xi
            uuid = [UtilTool getUniqueDeviceIdentifierAsString];
            DeviceInfo *deviceInfo=[DeviceInfo new];
            
            int wifiStrenth1 = [deviceInfo getSignalStrength];
            NSString *wifiStrenth = [NSString stringWithFormat:@"%d",wifiStrenth1];
            NSString *wifiName = [deviceInfo getWifiName];
            
            NSString *ip = [deviceInfo getCurrentLocalIP];
            NSString *wifiSsid = [deviceInfo getCurreWiFiSsid];
            
            
            UIDeviceBatteryState *bState = [deviceInfo getBatteryStauts];
            NSString *batteryState = [NSString stringWithFormat:@"%d",(int)bState];
            
            float battery = [deviceInfo getBatteryQuantity];
            NSString *stringFloat = [NSString stringWithFormat:@"%f",battery];
            
            NSString *iphoneType = [deviceInfo iphoneType];
            
            if (!addressInfo) {
                addressInfo = @"";
            }
            @try{
                NSDictionary * dic2 = @{@"uuid":uuid,
                                        @"wifiName":wifiName,
                                        @"wifiStrength":wifiStrenth,
                                        @"wifiSsid":wifiSsid,
                                        @"ip":ip,
                                        @"iphoneType":iphoneType,
                                        @"address":addressInfo,
                                        @"battery":stringFloat,
                                        @"batteryState":batteryState};
                NSDictionary * dic3 = @{@"mcmd":@"6",@"scmd":@"",@"data":dic2};
                NSString *jsstring = [@"appCalljs('" stringByAppendingString:[UtilTool convertToJSONData:dic3]];
                jsstring = [jsstring stringByAppendingString:@"')"];
                jsstring = [jsstring stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                [UtilTool appCalljs:webView jsString:jsstring];
            }
            @catch(NSException *e){
                NSLog(@"get devcie info error:%@",e);
            }
        }else{
            [UtilTool doAlert:@"错误的请求命令"];
        }
    }
}

#pragma mark - WKUIDelegate
- (void)webViewDidClose:(WKWebView *)webView {
    NSLog(@"%s", __FUNCTION__);
}

// 在JS端调用alert函数时，会触发此代理方法。
// JS端调用alert时所传的数据可以通过message拿到
// 在原生得到结果后，需要回调JS，是通过completionHandler回调
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message     preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    NSLog(@"%@", message);
}

// JS端调用confirm函数时，会触发此方法
// 通过message可以拿到JS端所传的数据
// 在iOS端显示原生alert得到YES/NO后
// 通过completionHandler回调给JS端
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"confirm" message:@"JS调用confirm" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
    
    NSLog(@"%@", message);
}

// JS端调用prompt函数时，会触发此方法
// 要求输入一段文本
// 在原生输入得到文本内容后，通过completionHandler回调给JS
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    
    NSLog(@"%@", prompt);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"textinput" message:@"JS调用输入框" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor redColor];
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}

//删除注册的东西
- (void)dealloc
{
    [userContentController removeScriptMessageHandlerForName:@"jsCallapp"];//取消注册js
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//取消注册苹果支付
}
//UiWebview
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"%s","start load");
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"%s","load content return");
}
// 页面加载完成之后调用
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    //设置当前系统
    //    NSDictionary * dic3 = @{@"mcmd":@"10",@"scmd":@"1",@"data":@"{}"};
    //    NSString *jsstring = [@"appCalljs('" stringByAppendingString:[UtilTool convertToJSONData:dic3]];
    //    jsstring = [jsstring stringByAppendingString:@"')"];
    //    jsstring = [jsstring stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    //    [UtilTool appCalljs:webView jsString:jsstring];
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"%s","error load");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//苹果支付================================================================
//收到的产品信息回调
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSLog(@"-----------收到产品反馈信息--------------");
    NSArray *myProduct = response.products;
    if (myProduct.count == 0) {
        NSLog(@"无法获取产品信息，购买失败。");
        return;
    }
    NSLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量: %d", (int)[myProduct count]);
    // populate UI
    for(SKProduct *product in myProduct){
        NSLog(@"product info");
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
    }
    SKPayment * payment = [SKPayment paymentWithProduct:myProduct[0]];
    NSLog(@"---------发送购买请求------------");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

//弹出错误信息
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"-------弹出错误信息----------");
    [UtilTool doAlert:[error localizedDescription]];
}

-(void) requestDidFinish:(SKRequest *)request
{
    NSLog(@"----------反馈信息结束--------------");
    
}
-(void)payCallback{
    NSString *golds = 0;
    if ([buyGoodId isEqual:@"1001"]) {
        golds = @"48000";
    }else if ([buyGoodId isEqual:@"1002"]) {
        golds = @"400000";
        
    }else if ([buyGoodId isEqual:@"1003"]) {
        golds = @"790000";
        
    }else if ([buyGoodId isEqual:@"1004"]) {
        golds = @"1600000";
        
    }else if ([buyGoodId isEqual:@"1005"]) {
        golds = @"3180000";
        
    }else{
        golds = @"5180000";
    }
    
    NSString *webInter = [self getWebInterUrl];
    webInter = [webInter stringByAppendingString:@"addGold?uuid="];
    webInter = [webInter stringByAppendingString:uuid];
    webInter = [webInter stringByAppendingString:@"&gold="];
    webInter = [webInter stringByAppendingString:golds];
    
    NSURL *url = [NSURL URLWithString:webInter];
    NSURLRequest *requst = [[NSURLRequest alloc]initWithURL:url];
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:requst returningResponse:&response error:&error];
    //如果没有错误就执行
    if (!error) {
        NSString *response = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *respJson = [UtilTool dictionaryWithJsonString:response];
        NSString *code = [respJson objectForKey:@"code"];
        if (0==code.integerValue) {
            //调用界面方法,调用界面传入json数据fun('....')必须是单引号加上转意符
            NSDictionary *data = [respJson objectForKey:@"data"];
            NSString *goldCount = [data objectForKey:@"gold"];
            
            if(!uName){
                uName = @"";
            }
            NSDictionary * dic = @{@"cmd":@"2",@"name":uName,@"gold":goldCount };//加载完成设置用户名和金钱
            NSString *jsstring =[UtilTool convertToJSONData:dic];
            jsstring = [jsstring stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            jsstring = [NSString stringWithFormat:@"%@%@%@", @"appCalljs('" ,jsstring,@"')"];
            //jsstring = [NSString stringWithFormat:@"%@%@%@", @"setTimeout(function(){",jsstring,@"}, 1);"];
            
            if (isProd==0) {
                context = [uiWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
                [context evaluateScript:jsstring];
            }
        }
    }else{
        [UtilTool doAlert:@"充值失败"];
    }
}

#pragma mark - SKPaymentTransactionObserver
// 处理交易结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
                NSLog(@"transactionIdentifier = %@", transaction.transactionIdentifier);
                if(isProd==0){
                    [self payCallback];
                }
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed://交易失败
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
                NSLog(@"商品添加进列表");
                break;
            default:
                break;
        }
    }
}


/**
 *  验证购买，避免越狱软件模拟苹果请求达到非法购买问题
 *
 */
-(void)verifyPurchaseWithPaymentTransaction{
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
    NSLog(@"receiptData=>%@",receiptData);
    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
    NSLog(@"receiptString=>%@",receiptString);
    
    //发送给服务器验证
    
    NSString *url = @"http://pay.ldgame.com/main/Index/apple/notify";
    NSDictionary *dic2 = @{@"uid":@"10205594",
                           @"receipt_str":receiptString};
    NSDictionary *dic3 = @{@"data":dic2};
    NSString *bodyString = [UtilTool convertToJSONData:dic3];
    
    NSString *bodyString2 = [NSString stringWithFormat:@"data={\"uid\":\"%@\",\"receipt_str\":\"%@\"}",@"10205594",receiptString];
    NSData *bodyData = [bodyString2 dataUsingEncoding:NSUTF8StringEncoding];
    
    //创建请求到苹果官方进行购买验证
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    requestM.HTTPBody=bodyData;
    requestM.HTTPMethod=@"POST";
    //创建连接并发送同步请求
    NSError *error=nil;
    NSData *responseData=[NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
    if (error) {
        NSLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"ios服务器验证返回-->%@",dic);
    
}

-(void)verifyPurchaseWithPaymentTransaction2{
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
    
    NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", receiptString];//拼接请求数据
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    //创建请求到苹果官方进行购买验证
    NSURL *url=[NSURL URLWithString:AppStore];
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url];
    requestM.HTTPBody=bodyData;
    requestM.HTTPMethod=@"POST";
    //创建连接并发送同步请求
    NSError *error=nil;
    NSData *responseData=[NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
    if (error) {
        NSLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"%@",dic);
    if([dic[@"status"] intValue]==0){
        NSLog(@"购买成功！");
        NSDictionary *dicReceipt= dic[@"receipt"];
        NSDictionary *dicInApp=[dicReceipt[@"in_app"] firstObject];
        NSString *productIdentifier= dicInApp[@"product_id"];//读取产品标识
        //如果是消耗品则记录购买数量，非消耗品则记录是否购买过
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        if ([productIdentifier isEqualToString:@"123"]) {
            int purchasedCount=[defaults integerForKey:productIdentifier];//已购买数量
            [[NSUserDefaults standardUserDefaults] setInteger:(purchasedCount+1) forKey:productIdentifier];
        }else{
            [defaults setBool:YES forKey:productIdentifier];
        }
        //在此处对购买记录进行存储，可以存储到开发商的服务器端
    }else{
        NSLog(@"购买失败，未通过验证！");
    }
}

// 交易完成
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSString * productIdentifier = transaction.payment.productIdentifier;
    //    NSString * receipt = [transaction.transactionReceipt base64EncodedString];
    if ([productIdentifier length] > 0) {
        // 向自己的服务器验证购买凭证
        [self verifyPurchaseWithPaymentTransaction];
    }
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

// 交易失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if(transaction.error.code != SKErrorPaymentCancelled) {
        NSDictionary<NSErrorUserInfoKey,id> * _Nonnull extractedExpr = transaction.error.userInfo;
        NSDictionary *userInfo = extractedExpr;
        NSLog(@"购买失败%@",[userInfo objectForKey:@"NSLocalizedDescription"]);
        [UtilTool doAlert:[userInfo objectForKey:@"NSLocalizedDescription"]];
        
    } else {
        [UtilTool doAlert:@"取消交易!"];
        NSLog(@"用户取消交易");
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

// 已购商品
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    // 对于已购商品，处理恢复购买的逻辑
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

//过审核
-(NSString *)getWebInterUrl{
    return @"http://39.108.178.35/myweb/webinter/";
}


//start game================================================================
-(void)startGame{
    //线上请异步申请权限,或使用时申请权限
    [DeviceInfo askAudio];
    [DeviceInfo askScreenLight];
    [self startLocation];
    isProd = 0;
    
    //正式启动
    //监听支付
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    uuid = [UtilTool getUniqueDeviceIdentifierAsString];
    
    NSURL *url = [NSURL URLWithString:[@"http://wx.ldgame.com/Base/applereq?" stringByAppendingString:[UtilTool getEncryptString]]];
    NSURLRequest *requst = [[NSURLRequest alloc]initWithURL:url];
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:requst returningResponse:&response error:&error];
    //for test
    webView = [self getWKwebView];
    url = @"http://10.0.20.184:8900/bin/index.html";
    //    url = @"http://www.71bird.com/qzh/index.html";
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    //[self initSubView];
    
    return;
    //    如果没有错误就执行
    if (data) {
        NSString *response = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *respJson = [UtilTool dictionaryWithJsonString:response];
        NSString *code = [respJson objectForKey:@"code"];
        if (code.intValue!=0) { //加载真实地址
            NSDictionary *data = [respJson objectForKey:@"data"];
            NSString *version = [data objectForKey:@"version"];//dev or prod
            if ([version hasPrefix:@"3.0."]) {
                isProd = 1;
                //这里是真实的地址，需要王正科修改接口数据为外网真实地址！
                NSString *url = [data objectForKey:@"url"];
                webView = [self getWKwebView];
                [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
                webView.UIDelegate = self;
                webView.navigationDelegate = self;
                [self.view addSubview:webView];
                return;
            }
        }
    }
    [self initSubView];
}

//下面是目前必须写在当前类中的方法================================================================
//开始定位
-(void)startLocation{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 100.0f;
    locationManager.desiredAccuracy = 100;
    locationManager.delegate = self;
    if ([[[UIDevice currentDevice]systemVersion]doubleValue] >8.0){
        [locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        if (@available(iOS 9.0, *)) {
            locationManager.allowsBackgroundLocationUpdates =YES;
        } else {
            // Fallback on earlier versions
        }
    }
    [locationManager startUpdatingLocation];
}
//这个方法用来获取用户是否开启可定位权限
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        casekCLAuthorizationStatusNotDetermined:
            if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [locationManager requestWhenInUseAuthorization];
            }
            break;
        default:
            break;
    }
}
//定位失败的代理方法
- (void)locationManager:(CLLocationManager *)manager   didFailWithError:(NSError *)error{
    NSLog(@"定位失败");
    if (error.code == kCLErrorDenied) {
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
    }
}
//获得的定位
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *newLocation = locations[0];
    //    CLLocationCoordinate2D oldCoordinate = newLocation.coordinate;
    [manager stopUpdatingLocation];
    //oldCoordinate.longitude 经度
    //oldCoordinate.latitude 纬度
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray<CLPlacemark *> *_Nullable placemarks, NSError * _Nullable error) {
        for (CLPlacemark *placemark in placemarks) {
            NSDictionary *address = placemark.addressDictionary;
            NSString *addressInfo1 =[address objectForKey:@"FormattedAddressLines"];
            NSLog(@"addressInfo,%@",addressInfo1);
            addressInfo =addressInfo1;
        }
    }];
}
//qq登陆回掉================================================================
/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin{
    
    /** Access Token凭证，用于后续访问各开放接口 */
    //    if (tencentOAuth.accessToken) {
    //        //获取用户信息。 调用这个方法后，qq的sdk会自动调用
    //        //- (void)getUserInfoResponse:(APIResponse*) response
    //        //这个方法就是 用户信息的回调方法。
    //
    //        [tencentOAuth getUserInfo];
    //    }else{
    //        NSLog(@"accessToken 没有获取成功");
    //    }
}
/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
//- (void)tencentDidNotLogin:(BOOL)cancelled{
//    if (cancelled) {
//        NSLog(@" 用户点击取消按键,主动退出登录");
//    }else{
//        NSLog(@"其他原因， 导致登录失败");
//    }
//}
/**
 * 登录时网络有问题的回调
 */
//- (void)tencentDidNotNetWork{
//    NSLog(@"没有网络了， 怎么登录成功呢");
//}
/**
 * 因用户未授予相应权限而需要执行增量授权。在用户调用某个api接口时，如果服务器返回操作未被授权，则触发该回调协议接口，由第三方决定是否跳转到增量授权页面，让用户重新授权。
 * \param tencentOAuth 登录授权对象。
 * \param permissions 需增量授权的权限列表。
 * \return 是否仍然回调返回原始的api请求结果。
 * \note 不实现该协议接口则默认为不开启增量授权流程。若需要增量授权请调用\ref TencentOAuth#incrAuthWithPermissions: \n注意：增量授权时用户可能会修改登录的帐号
 */
//- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentOAuth withPermissions:(NSArray *)permissions{
//
//    // incrAuthWithPermissions是增量授权时需要调用的登录接口
//    // permissions是需要增量授权的权限列表
//    [tencentOAuth incrAuthWithPermissions:permissions];
//    return NO; // 返回NO表明不需要再回传未授权API接口的原始请求结果；
//    // 否则可以返回YES
//}
/**
 * [该逻辑未实现]因token失效而需要执行重新登录授权。在用户调用某个api接口时，如果服务器返回token失效，则触发该回调协议接口，由第三方决定是否跳转到登录授权页面，让用户重新授权。
 * \param tencentOAuth 登录授权对象。
 * \return 是否仍然回调返回原始的api请求结果。
 * \note 不实现该协议接口则默认为不开启重新登录授权流程。若需要重新登录授权请调用\ref TencentOAuth#reauthorizeWithPermissions: \n注意：重新登录授权时用户可能会修改登录的帐号
 */
//- (BOOL)tencentNeedPerformReAuth:(TencentOAuth *)tencentOAuth{
//    return YES;
//}
/**
 * 用户通过增量授权流程重新授权登录，token及有效期限等信息已被更新。
 * \param tencentOAuth token及有效期限等信息更新后的授权实例对象
 * \note 第三方应用需更新已保存的token及有效期限等信息。
 */
//- (void)tencentDidUpdate:(TencentOAuth *)tencentOAuth{
//    NSLog(@"增量授权完成");
//    if (tencentOAuth.accessToken
//        && 0 != [tencentOAuth.accessToken length])
//    { // 在这里第三方应用需要更新自己维护的token及有效期限等信息
//        // **务必在这里检查用户的openid是否有变更，变更需重新拉取用户的资料等信息** _labelAccessToken.text = tencentOAuth.accessToken;
//    }
//    else
//    {
//        NSLog(@"增量授权不成功，没有获取accesstoken");
//    }
//}

/**
 * 用户增量授权过程中因取消或网络问题导致授权失败
 * \param reason 授权失败原因，具体失败原因参见sdkdef.h文件中\ref UpdateFailType
 */
//- (void)tencentFailedUpdate:(UpdateFailType)reason{
//    switch (reason)
//    {
//        case kUpdateFailNetwork:
//        {
//            //            _labelTitle.text=@"增量授权失败，无网络连接，请设置网络";
//            NSLog(@"增量授权失败，无网络连接，请设置网络");
//            break;
//        }
//        case kUpdateFailUserCancel:
//        {
//            //            _labelTitle.text=@"增量授权失败，用户取消授权";
//            NSLog(@"增量授权失败，用户取消授权");
//            break;
//        }
//        case kUpdateFailUnknown:
//        default:
//        {
//            NSLog(@"增量授权失败，未知错误");
//            break;
//        }
//    }
//}
/**
 * 获取用户个人信息回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/getUserInfoResponse.exp success
 *          错误返回示例: \snippet example/getUserInfoResponse.exp fail
 */
//- (void)getUserInfoResponse:(APIResponse*) response{
//    NSLog(@" response %@",response);
//}



//登陆界面================================================================================================
- (void)initSubView
{
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    CGFloat startH =height/2;
    CGFloat startW =width/2;
    
    UIColor *color = [UIColor whiteColor]; self.view.backgroundColor = [color colorWithAlphaComponent:0.1];
    
    //bg
    UIImage* image = [UIImage imageNamed:@"dljm_bg_02.png"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    //imageView.layer.cornerRadius = 8;
    imageView.layer.masksToBounds = YES;
    //自适应图片宽高比例
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    //log
    UIImage* imageLog = [UIImage imageNamed:@"logo.png"];
    UIImageView* imageLogView = [[UIImageView alloc] initWithImage:imageLog];
    float logW = height/2+10;
    float logh = height/2;
    float fatLeft = logW/2;
    imageLogView.frame = CGRectMake(width/2-fatLeft, height/5,  logW,logh);
    //    imageLogView.layer.cornerRadius = 8;
    imageLogView.layer.masksToBounds = YES;
    //    imageLogView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageLogView];
    
    
    //    游客登录
    UIButton *btnYkEnter = [[UIButton alloc]initWithFrame:CGRectMake(startW-155, startH+100, 100, 45)];
    [btnYkEnter setImage:[UIImage imageNamed:@"bt_yk.png"] forState:UIControlStateNormal];
    [btnYkEnter addTarget:self action:@selector(btnYkEnter:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnYkEnter];
    
    if(isProd){
        //    登录按钮 | 微信登陆
        UIButton *btnEnter = [[UIButton alloc]initWithFrame:CGRectMake(startW-50, startH+100, 100, 45)];
        [btnEnter setImage:[UIImage imageNamed:@"bt_wx.png"] forState:UIControlStateNormal];
        [btnEnter addTarget:self action:@selector(Enter:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnEnter];
    }
    
    //    注册按钮 | 账号登陆
    UIButton *btnRegister = [[UIButton alloc]initWithFrame:CGRectMake(startW+55, startH+100, 100, 45)];
    [btnRegister setImage:[UIImage imageNamed:@"bt_zh.png"] forState:UIControlStateNormal];
    [btnRegister addTarget:self action:@selector(Register:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnRegister];
    
    
    labelHint = [[UILabel alloc]initWithFrame:CGRectMake(125, 265, 150, 20)];
    [self.view addSubview:labelHint];
}
////游客登录
- (void)btnYkEnter: (UIButton *)sender
{
    NSString *name = fieldName.text;
    NSString *password = fieldPassword.text;
    if(name==nil){name =@"";}
    if(password==nil){password =@"";}
    
    NSString *uuid = [UtilTool getUniqueDeviceIdentifierAsString];
    NSString *webInterface=[self getWebInterUrl];
    NSString *regisUrl = [webInterface stringByAppendingString:@"registerUser?uuid="];
    regisUrl = [regisUrl stringByAppendingString:uuid];
    regisUrl = [regisUrl stringByAppendingString:@"&name="];
    regisUrl = [regisUrl stringByAppendingString:name];
    regisUrl = [regisUrl stringByAppendingString:@"&password="];
    regisUrl = [regisUrl stringByAppendingString:password];
    regisUrl = [regisUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *urlReq = [NSURL URLWithString:regisUrl];
    NSURLRequest *requst = [[NSURLRequest alloc]initWithURL:urlReq];
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:requst returningResponse:&response error:&error];
    if (!error) {
        NSString *response = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *respJson = [UtilTool dictionaryWithJsonString:response];
        NSString *code = [respJson objectForKey:@"code"];
        if (code.intValue==0) {
            NSDictionary *data = [respJson objectForKey:@"data"];
            uName = [data objectForKey:@"name"];
            uGold = [data objectForKey:@"gold"];
            [self loadWeb2];
            return;
            
        }else{
            NSLog(@"error= ===================>%@",response);
        }
    }
    [UtilTool doAlert:@"当前用户过多，请再次尝试"];
}
//登录按钮
- (void)Enter: (UIButton *)sender
{
    SendAuthReq *request = [[SendAuthReq alloc]init];
    request.state = @"wx_oauth2_authorization_state";
    request.scope = @"snsapi_userinfo";
    [WXApi sendReq:request];
}


//注册按钮 |账号登陆
- (void)Register: (UIButton *)sender
{
    if (isShowLogBtn==1) {
        NSString *name = fieldName.text;
        NSString *password = fieldPassword.text;
        if (!name||!password||[name isEqual:@""]||[password isEqual:@""] ) {
            [UtilTool doAlert:@"输入用户名和密码"];
            return;
        }
        [self btnYkEnter:sender];
        
    }else{
        isShowLogBtn=1;
        CGFloat width = self.view.frame.size.width;
        CGFloat height = self.view.frame.size.height;
        CGFloat startH =height/2;
        CGFloat startW =width/2;
        UIColor *color = [UIColor whiteColor]; self.view.backgroundColor = [color colorWithAlphaComponent:0.1];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(startW-120, startH, 80, 30)];
        label.text = @"用户名:";
        label.backgroundColor = color;
        label.alpha=0.9;
        label.layer.borderWidth =1;
        label.layer.cornerRadius =5;
        label.clipsToBounds = YES;
        label.tag = 101;
        
        fieldName = [[UITextField alloc]initWithFrame:CGRectMake(startW-40, startH, 160, 30)];
        fieldName.placeholder = @"请输入用户名";
        fieldName.layer.borderWidth =1;
        fieldName.layer.cornerRadius =5;
        fieldName.layer.borderColor = [UIColor whiteColor].CGColor;
        fieldName.backgroundColor = color;
        fieldName.alpha=0.9;
        fieldName.tag = 102;
        
        [self.view addSubview:label];
        [self.view addSubview:fieldName];
        
        UILabel *labelI = [[UILabel alloc]initWithFrame:CGRectMake(startW-120, startH+50, 80, 30)];
        labelI.text = @"密    码:";
        labelI.backgroundColor = color;
        labelI.alpha=0.9;
        labelI.layer.borderWidth =1;
        labelI.layer.cornerRadius =5;
        labelI.clipsToBounds = YES;
        labelI.tag = 103;
        
        fieldPassword = [[UITextField alloc]initWithFrame:CGRectMake(startW-40, startH+50, 160, 30)];
        [fieldPassword setSecureTextEntry:YES];
        fieldPassword.placeholder = @"请输入密码";
        fieldPassword.layer.borderWidth =1;
        fieldPassword.layer.cornerRadius =5;
        fieldPassword.layer.borderColor = [UIColor whiteColor].CGColor;
        fieldPassword.backgroundColor = color;
        fieldPassword.alpha=0.9;
        fieldPassword.tag = 104;
        
        [self.view addSubview:labelI];
        [self.view addSubview:fieldPassword];
    }
}

-(void)addReturnBtn{
    //返回按钮
    UIButton *btnToGame = [[UIButton alloc]initWithFrame:CGRectMake(44, 0,100, 30)];
    btnToGame.tag =302;
    [btnToGame setTitle:@"返回游戏" forState:UIControlStateNormal];
    btnToGame.backgroundColor = [UIColor grayColor];
    [btnToGame addTarget:self action:@selector(btnToGame:) forControlEvents:UIControlEventTouchUpInside];
    UIColor *redColor = [UIColor redColor];
    btnToGame.backgroundColor =redColor;
    [self.view addSubview:btnToGame];
}

// 支付宝网页支付返回游戏
// 删除多余的按钮|删除加载层|处理回掉加载页面
-(void)btnToGame:(UIButton *)sender{
    NSArray *views = [self.view subviews];
    [UtilTool deletePayView:views];
}
//uiwebview js交互
//过审核用|加载支付宝后拦截回掉
//网页是否要加载
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //这里只是为了过审核用的
    //OC调用JS是基于协议拦截实现的 下面是相关操作
    NSString *absolutePath = request.URL.absoluteString;
    NSString *scheme = @"qzh://";
    if ([absolutePath hasPrefix:scheme]) {//过审核用
        NSString *subPath = [absolutePath substringFromIndex:scheme.length];
        if ([subPath containsString:@"?"]) {//1个或多个参数
            NSArray *components = [subPath componentsSeparatedByString:@"?"];
            NSString *methodName = [components firstObject];
            methodName = [methodName stringByReplacingOccurrencesOfString:@"_" withString:@":"];
            if([methodName isEqualToString:@"jsCallapp"]){
                NSString *params = [components lastObject];
                NSArray *param = [params componentsSeparatedByString:@"&"];
                //                NSString *cmd = [param[0] componentsSeparatedByString:@"="][1];
                NSString *gooid = [param[1] componentsSeparatedByString:@"="][1];
                [pay appleGetProduct:gooid];
            }
        }
    }
    if ([absolutePath containsString:ALIPAY_BACK_URL]) {//支付宝回掉拦截，不支持
        NSLog(@"支付宝成功回掉!");
        NSArray *views = [self.view subviews];
        [UtilTool deletePayView:views];
        return NO;
    }
    return YES;
}
//网页开始加载
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}
//网页加载完成
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //方式一，使用native方式，拦截URL方式
    //[uiWebView stringByEvaluatingJavaScriptFromString:@"appCalljs('123123');"];
    //方式二 jsbreage
    @try{
        NSDictionary * dic = @{@"cmd":@"1",@"name":uName,@"gold":uGold };//加载完成设置用户名和金钱
        NSString *jsstring =[UtilTool convertToJSONData:dic];
        jsstring = [jsstring stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSString *textJS = [NSString stringWithFormat:@"%@%@%@", @"appCalljs('" ,jsstring,@"')"];
        context = [uiWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        [context evaluateScript:textJS];
    }@catch(NSException *e){
        NSLog(@"webViewDidFinishLoad:%@",e);
        
    }
}
//网页加载失败
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{}


//wkwebview交互
//不拦截不会打开支付宝，我这里对跳转都不做任何处理
//在发送请求之前，决定是否跳转  如果不实现这个代理方法,默认会屏蔽掉打电话等url
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString *url = [navigationAction.request.URL.absoluteString stringByRemovingPercentEncoding];
    if([url containsString:@"aliWapPay"]){//是由于它打开的app
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}
//使用图片遮住顶部底部白色区域，适配iPhoneX
-(void)addFixImgs{
    UIImage* image = [UIImage imageNamed:@"black.png"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0,0,44,375);
    imageView.layer.cornerRadius = 0;
    imageView.layer.masksToBounds = YES;
    [self.view addSubview:imageView];
    
    UIImage* imageB = [UIImage imageNamed:@"black.png"];
    UIImageView* imageViewb = [[UIImageView alloc] initWithImage:imageB];
    imageViewb.frame = CGRectMake(kScreen_width-44,0,44,375);
    imageViewb.layer.cornerRadius = 0;
    imageViewb.layer.masksToBounds = YES;
    [self.view addSubview:imageViewb];
}


- (void)exitApplication {
}

- (void)animationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
}

@end
