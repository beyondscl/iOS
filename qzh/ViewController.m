//
//  ViewController.m
//  qzh
//
//  Created by xianming on 2018/1/19.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "WXApi.h"
#import "WXApiObject.h"



/**
 *重启机器可能解决大部分问题
 */

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //load the game url
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
//    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://10.0.20.184:8900/bin/index.html"]]];
    [self.view addSubview:webView];
    
//    拉起苹果支付
    
    
//    拉起微信支付
//    NSDictionary *resp = [ViewController sendSynchronousRequest];
//    [ViewController wxPay:resp];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *拉起微信支付
 */
+(void)wxPay:(NSDictionary *)resp{
    if(resp){
        NSString *code = [resp objectForKey:@"code"];
        NSString *message = [resp objectForKey:@"message"];

        if ([code isEqual:@"0"]) {
            NSDictionary *data = [resp objectForKey:@"data"];
            NSString *appid = [data objectForKey:@"appid"];
            NSString *noncestr = [data objectForKey:@"noncestr"];
            NSString *package = [data objectForKey:@"package"];
            NSString *prepayid = [data objectForKey:@"prepayid"];
            NSString *partnerid = [data objectForKey:@"partnerid"];
            NSString *timestamp = [data objectForKey:@"timestamp"];
            NSString *sign = [data objectForKey:@"sign"];
            
            //open the wx
            [WXApi registerApp:appid];
            PayReq *request = [[PayReq alloc] init];
            request.partnerId = partnerid;
            request.prepayId= prepayid;
            request.package = package;
            request.nonceStr= noncestr;
            request.timeStamp= timestamp.intValue;
            request.sign= sign;
            [WXApi sendReq:request];
            
        }else{
            NSLog(@"%@",message);
        }
    }else{
        NSLog(@"%s","返回数据为空或者转换json错误");
    }

}
/**
 *微信支付回掉函数
 */
//微信SDK自带的方法，处理从微信客户端完成操作后返回程序之后的回调方法,显示支付结果的
-(void) onResp:(BaseResp*)resp
{
    NSString *title = @"微信支付";
    //启动微信支付的response
    NSString *payResoult = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        switch (resp.errCode) {
            case 0:
                payResoult = @"支付结果：成功!";
                break;
            case -1:
                payResoult = @"支付结果：失败!";
                break;
            case -2:
                payResoult = @"用户已经退出支付!";
                break;
            default:
                payResoult = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
                break;
        }
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:payResoult
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  NSLog(@"action = %@", action);
                                                              }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

/**
 *发送同步请求
 */
+(NSDictionary *)sendSynchronousRequest{
    //1、创建一个URL
    //协议头+主机地址+接口名称+?+参数1&参数2&参数3
    //这里的话是我自己使用.Net开发的一个本地后台接口 http://192.168.1.0:8080/login?username=LitterL&pwd=123
    //不是https需要配置info.plist
    NSURL *url = [NSURL URLWithString:@"http://wx.ldgame.com/index.php/Pay/wxapp?uid=10206434&price=0.01"];
    
    //2、创建请求(Request)对象(默认为GET请求)；
    NSURLRequest *requst = [[NSURLRequest alloc]initWithURL:url];
    
    //3、发送请求
    /*
     第一个参数:请求对象
     第二个参数:响应头
     第三个参数:错误信息
     返回值:NSData类型,响应体信息
     */
    NSError *error = nil;
    NSURLResponse *response = nil;
    //发送同步请求(sendSynchronousRequest)
    NSData *data = [NSURLConnection sendSynchronousRequest:requst returningResponse:&response error:&error];
    //如果没有错误就执行
    if (!error) {
        NSString *response = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *resp = [ViewController dictionaryWithJsonString:response];
        //打印的服务端返回的信息以及错误信息
//        NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"%@",resp);
        return resp;
    }
    return nil;
}

/**
 *NSString -> json
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

/**
 *弹出框
 */
- (IBAction)showAlert:(UIButton *)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"微信支付"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //响应事件
                                                              NSLog(@"action = %@", action);
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
