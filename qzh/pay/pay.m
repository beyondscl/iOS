//
//  pay.m
//  qzh
//
//  Created by xianming on 2018/3/1.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "pay.h"
#import "Util.h"

//在内购项目中创建的商品单号
//下面的ProductId应该是事先在itunesConnect中添加好的，已存在的付费项目。否则查询会失败。
//6元卡 支付6元可得4.8万金币
#define  ProductID_IAP_1 @"ldvideo.product.pay6"
//50元卡 支付50元可得40万金币
#define ProductID_IAP_2 @"ldvideo.product.pay50"
//98元卡 支付98元可得79万金币
#define ProductID_IAP_3 @"ldvideo.product.pay98"
//198元卡 支付198元可得160万金币
#define ProductID_IAP_4 @"gldvideo.product.pay198"
//388元卡 支付388元可得318万金币
#define ProductID_IAP_5 @"gldvideo.product.pay388"
//618元卡 支付618元可得518万金币
#define ProductID_IAP_6 @"ldvideo.product.pay618"

@implementation pay

+(NSString*)zfbPay:(NSString *)uid price:(NSString *)price productid:(NSString *)productid hintstr:(NSString *)hintstr{
    NSString * url = @"http://pay.ldgame.com/main/Index/pay/aliWapPay?uid=";
    url = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",url,uid ,@"&price=" ,price,@"&productid=" ,productid,@"&hintstr=",hintstr,[UtilTool getEncryptString]];
    NSDictionary *data = [UtilTool getSendRequest:url];
    if (data) {
        NSString *code = [data objectForKey:@"code"];
        if (0==code.longLongValue) {
            url = [data objectForKey:@"data"];
        }else{
            NSLog(@"请求支付宝错误%@",[data objectForKey:@"msg"]);
        }
    }
    return url;
}

//sdk支付
-(void)wxPay:(NSDictionary *)resp{
    NSLog(@"%s","不支持应用内拉起微信支付");
}

+ (NSSet*)appleGetProduct:(NSString*)goodid {
    NSLog(@"---------请求对应的产品信息------------");
    NSArray *product = nil;
    long int buyType = goodid.integerValue;
    switch (buyType) {
        case 1:
            product = [NSArray arrayWithObject:ProductID_IAP_1];
            break;
        case 2:
            product = [NSArray arrayWithObject:ProductID_IAP_2];
            break;
        case 3:
            product = [NSArray arrayWithObject:ProductID_IAP_3];
            break;
        case 4:
            product = [NSArray arrayWithObject:ProductID_IAP_4];
            break;
        case 5:
            product = [NSArray arrayWithObject:ProductID_IAP_5];
            break;
        case 6:
            product = [NSArray arrayWithObject:ProductID_IAP_6];
            break;
    }
    return [NSSet setWithArray:product];
}


//过审核用：真实的环境，我不需要弹出信息，由后台socket发出
+(void)payCallback:(NSString *)buyGoodId uid:(NSString*)uid uName:(NSString*)uName isProd:(int)isProd context:(JSContext *)context uiWebView:(UIWebView*)uiWebView{
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
    NSString *webInterUrl = [NSString stringWithFormat:@"%@%@%@%@%@",@"http://39.108.178.35/myweb/webinter/",@"addGold?uuid=",uid,@"&gold=",golds];
    NSURL *url = [NSURL URLWithString:webInterUrl];
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

/**
 *  验证购买，避免越狱软件模拟苹果请求达到非法购买问题
 *
 */
+(void)verifyPurchaseWithPaymentTransaction{
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
    NSLog(@"receiptData=>%@",receiptData);
    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
    NSLog(@"receiptString=>%@",receiptString);
    //发送给服务器验证
    NSString *url = @"http://pay.ldgame.com/main/Index/apple/notify";
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

@end

