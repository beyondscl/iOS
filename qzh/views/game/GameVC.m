//
//  GameVC.m
//  UiLearn
//
//  Created by xianming on 2018/3/16.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameVC.h"
#import "Util.h"
#import "pay.h"
#import "Commutate.h"
#import "DownLoad.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "SVProgressHUD.h"

#import <StoreKit/StoreKit.h>


@interface GameVC()<UINavigationControllerDelegate,
UserInfoDelegate,
UIWebViewDelegate,
DownProgress,
SKProductsRequestDelegate ,
SKPaymentTransactionObserver>{
    NSDictionary *userInfo;
    id<DownProgress> downProgressDele;
    DownLoad *download;
    int isShowWait;//判断当前是否已有提示框
    
}
@end

@implementation GameVC

-(float)setDownProgress:(float)p{
    NSLog(@"接受下载协议回掉!%f",p);
    return -1.0f;
}
-(id)initWithInfo:(NSDictionary*)info{
    self = [super init];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];//注册苹果支付回掉
    
    userInfo = info; //初始化用户数据
    download = [DownLoad new];//初始化下载和代理
    [download doInit:self];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.delegate = self;
    
    isShowWait = 0;
    //测试下载和协议
    //[download download:@"http://www.71bird.com/qzh/web.zip"];//web.zip
    
    UIImage *load = [UIImage imageNamed:@"imgs/login/loading1.jpg"];
    UIImageView *loading = [[UIImageView alloc]initWithImage:load];
    loading.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:loading];
    [SVProgressHUD showWithStatus:@"努力加载中..."];
    
    [self loadGame];
}

-(void)loadGame{
    
    @try{
        NSString *code = [userInfo objectForKey:@"code"];
        if(0==code.intValue){
            NSString *pathStr = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"web"];
            NSString *_pathStr = [NSString stringWithFormat:@"%@/index.html",pathStr];
            NSURL *url = [NSURL fileURLWithPath:_pathStr];
            UIWebView *webview = [[UIWebView alloc]initWithFrame:self.view.frame];
            webview.backgroundColor = [UIColor blackColor];
            webview.delegate = self;
            [webview loadRequest:[NSURLRequest requestWithURL:url]];
            [self.view addSubview:webview];
        }
        
    }@catch(NSException *e){
        NSLog(@"webViewDidFinishLoad:%@",e);
    }
}

#pragma mark 去掉导航栏
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)setUserInfo:(NSDictionary*)userInfo{
    NSLog(@"get data");
}


// uiwebview delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *absolutePath = request.URL.absoluteString;
    NSString *scheme = @"qzh://";
    if ([absolutePath hasPrefix:scheme]) {
        NSString *subPath = [absolutePath substringFromIndex:scheme.length];
        if ([subPath containsString:@"?"]) {//1个或多个参数
            NSArray *components = [subPath componentsSeparatedByString:@"?"];
            NSString *methodName = [components firstObject];
            methodName = [methodName stringByReplacingOccurrencesOfString:@"_" withString:@":"];
            if([methodName isEqualToString:@"jsCallapp"]){
                NSString *params = [components lastObject];
                NSArray *param = [params componentsSeparatedByString:@"&"];
                NSString *cmd = [param[0] componentsSeparatedByString:@"="][1];
                NSString *gooid = [param[1] componentsSeparatedByString:@"="][1];
                if(10000 == gooid.intValue&&2==cmd.intValue){//登陆回掉
                    @try{
                        NSString *code = [userInfo objectForKey:@"code"];
                        if(0==code.intValue){
                            NSDictionary *_UserInfo = [userInfo objectForKey:@"data"];
                            NSString *uid = [_UserInfo objectForKey:@"uid"];
                            NSString *token = [_UserInfo objectForKey:@"token"];
                            NSString *host = [_UserInfo objectForKey:@"ip"];
                            NSString *port = @"7002";
                            host = @"203.19.33.6";
                            NSDictionary * dic = @{@"cmd":@"1",@"uid":uid,@"token":token,@"host":host,@"port":port };
                            NSString *jsstring =[UtilTool convertToJSONData:dic];
                            jsstring = [jsstring stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                            NSString *textJS = [NSString stringWithFormat:@"%@%@%@", @"appCalljs('" ,jsstring,@"')"];
                            JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
                            [context evaluateScript:textJS];
                        }
                    }@catch(NSException *e){
                        NSLog(@"webViewDidFinishLoad:%@",e);
                    }
                    
                }else if(3==cmd.intValue){//登陆回掉
                    [self.navigationController popToRootViewControllerAnimated:NO];
                }else{
                    if(0==isShowWait){
                        //                        SVProgressHUDStyleLight,
                        //                        SVProgressHUDStyleDark,
                        //                        SVProgressHUDStyleCustom
                        isShowWait = 1;
                        [SVProgressHUD showWithStatus:@"正在链接App Store"];
                        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                    }else{
                        return NO;
                    }
                    NSSet *nsset = [pay appleGetProduct:gooid];
                    SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
                    request.delegate=self;//单独提出去
                    [request start];
                }
            }
        }
    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //方式一，使用native方式，拦截URL方式
    //[uiWebView stringByEvaluatingJavaScriptFromString:@"appCalljs('123123');"];
    //方式二 jsbreage
    [SVProgressHUD dismiss];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}
//uiwebview delegate end------------------

//苹果支付------------------
//收到的产品信息回调
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSArray *myProduct = response.products;
    if (myProduct.count == 0) {
        [UtilTool doAlert:@"无法获取产品信息，购买失败"];
        [self dissmiss];
        return;
    }
    SKPayment * payment = [SKPayment paymentWithProduct:myProduct[0]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//弹出错误信息
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    [UtilTool doAlert:[error localizedDescription]];
    [self dissmiss];
}

-(void) requestDidFinish:(SKRequest *)request
{
    NSLog(@"----------反馈信息结束--------------");
}
// 处理交易结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
                NSLog(@"transactionIdentifier = %@", transaction.transactionIdentifier);
                //                [pay payCallback:buyGoodId uid:uuid uName:uName isProd:isProd context:context uiWebView:uiWebView];
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
// 交易完成
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [self dissmiss];
    
    NSString * productIdentifier = transaction.payment.productIdentifier;
    //    NSString * receipt = [transaction.transactionReceipt base64EncodedString];
    if ([productIdentifier length] > 0) {
        // 向自己的服务器验证购买凭证,可以开线程
        [pay verifyPurchaseWithPaymentTransaction];
    }
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

// 交易失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    [self dissmiss];
    if(transaction.error.code != SKErrorPaymentCancelled) {
        NSDictionary<NSErrorUserInfoKey,id> * _Nonnull extractedExpr = transaction.error.userInfo;
        NSDictionary *userInfo = extractedExpr;
        [UtilTool doAlert:[userInfo objectForKey:@"NSLocalizedDescription"]];
    } else {
        [UtilTool doAlert:@"取消交易!"];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}
// 已购商品
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [self dissmiss];
    // 对于已购商品，处理恢复购买的逻辑
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
//苹果支付完成------------------

-(void)dissmiss{
    isShowWait = 0;
    [SVProgressHUD dismiss];
}

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//取消注册苹果支付
}
@end
