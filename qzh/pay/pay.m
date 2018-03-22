
#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "pay.h"
#import "Util.h"

#define ProductID_IAP_1 @"ldfishing.product.pay6"
#define ProductID_IAP_2 @"ldfishing.product.pay18"
#define ProductID_IAP_3 @"ldfishing.product.pay68"
#define ProductID_IAP_4 @"ldfishing.product.pay98"
#define ProductID_IAP_5 @"ldfishing.product.pay488"
#define ProductID_IAP_6 @"ldfishing.product.pay698"

@implementation pay

+(NSString*)hbo_zfbPay:(NSString *)uid price:(NSString *)price productid:(NSString *)productid hintstr:(NSString *)hintstr{
    NSString * url = @"http://pay.ldgame.com/main/Index/pay/aliWapPay?uid=";
    url = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",url,uid ,@"&price=" ,price,@"&productid=" ,productid,@"&hintstr=",hintstr,[UtilTool hbo_getEncryptString]];
    NSDictionary *data = [UtilTool hbo_getSendRequest:url];
    if (data) {
        NSString *code = [data objectForKey:@"code"];
        if (0==code.longLongValue) {
            url = [data objectForKey:@"data"];
        }else{
            NSLog(@"请求AAAAAAA错误%@",[data objectForKey:@"msg"]);
        }
    }
    return url;
}

-(void)hbo_wxPay:(NSDictionary *)resp{
    NSLog(@"%s","不支持应用内拉起BBBBBB");
}

+ (NSSet*)hbo_appleGetProduct:(NSString*)goodid {
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


+(void)hbo_payCallback:(NSString *)buyGoodId uid:(NSString*)uid uName:(NSString*)uName isProd:(int)isProd context:(JSContext *)context uiWebView:(UIWebView*)uiWebView{
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
    if (!error) {
        NSString *response = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *respJson = [UtilTool hbo_dictionaryWithJsonString:response];
        NSString *code = [respJson objectForKey:@"code"];
        if (0==code.integerValue) {
            NSDictionary *data = [respJson objectForKey:@"data"];
            NSString *goldCount = [data objectForKey:@"gold"];
            
            if(!uName){
                uName = @"";
            }
            NSDictionary * dic = @{@"cmd":@"2",@"name":uName,@"gold":goldCount };//加载完成设置用户名和金钱
            NSString *jsstring =[UtilTool hbo_convertToJSONData:dic];
            jsstring = [jsstring stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            jsstring = [NSString stringWithFormat:@"%@%@%@", @"appCalljs('" ,jsstring,@"')"];
            //jsstring = [NSString stringWithFormat:@"%@%@%@", @"setTimeout(function(){",jsstring,@"}, 1);"];
            if (isProd==0) {
                context = [uiWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
                [context evaluateScript:jsstring];
            }
        }
    }else{
        [UtilTool hbo_doAlert:@"充值失败"];
    }
}

+(void)hbo_verifyPurchaseWithPaymentTransaction{
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
    NSLog(@"receiptData=>%@",receiptData);
    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
    NSLog(@"receiptString=>%@",receiptString);
    NSString *url = @"http://pay.ldgame.com/main/Index/apple/notify";
    NSString *bodyString2 = [NSString stringWithFormat:@"data={\"uid\":\"%@\",\"receipt_str\":\"%@\"}",@"10205594",receiptString];
    NSData *bodyData = [bodyString2 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    requestM.HTTPBody=bodyData;
    requestM.HTTPMethod=@"POST";
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

