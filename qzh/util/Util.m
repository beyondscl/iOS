//
//  Util.m
//  qzh
//
//  Created by xianming on 2018/2/6.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Util.h"

//#import "SAMKeychain.h"
//#import "SAMKeychainQuery.h"

#import <WebKit/WebKit.h>

#import <CommonCrypto/CommonDigest.h>

//秘钥
static NSString *encryptionKey = @"ledougamecenter";

@implementation UtilTool
    
+(void)doAlert:(NSString *)Msg{
    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"系统提示"
                                                        message:Msg
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"确定",nil) otherButtonTitles:nil];
    [alerView show];
}
    
    //字典转jsonstring
+ (NSString*)convertToJSONData:(id)infoDict
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        NSString *jsonString = @"";
        
        if (! jsonData)
        {
            NSLog(@"Got an error: %@", error);
        }else
        {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
        jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
        
        [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        return jsonString;
    }
    
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
    {
        if (jsonString == nil) {
            return nil;
        }
        
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        if(err)
        {
            NSLog(@"json解析失败：%@",err);
            return nil;
        }
        return dic;
    }
    
    //发送同步请求json,返回字典
+(NSDictionary *)getSendRequest:(NSString *)urlOrigin{
    urlOrigin = [urlOrigin stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlOrigin];
    NSURLRequest *requst = [[NSURLRequest alloc]initWithURL:url];
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:requst returningResponse:&response error:&error];
    //如果没有错误就执行
    if (!error) {
        NSString *response = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *respJson = [self dictionaryWithJsonString:response];
        return respJson;
    }
    NSLog(@"请求网络地址失败%@",error);
    return nil;
}
    
    //获取uuid
+(NSString *)getUniqueDeviceIdentifierAsString
    {
        //    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
        //
        //    NSString *strApplicationUUID =  [SAMKeychain passwordForService:appName account:@"incoding"];
        //    if (strApplicationUUID == nil)
        //    {
        //        strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        //
        //        NSError *error = nil;
        //        SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
        //        query.service = appName;
        //        query.account = @"incoding";
        //        query.password = strApplicationUUID;
        //        query.synchronizationMode = SAMKeychainQuerySynchronizationModeNo;
        //        [query save:&error];
        //
        //    }
        //    return strApplicationUUID;
        
        return @"";
    }
+(NSString *)getTimeString{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", a];
    NSArray * arr = [timeString componentsSeparatedByString:@"."];
    return arr[0];
}
    //md5加密
+ (NSString *)md5EncryptWithString:(NSString *)string{
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    return [result lowercaseString];
}
    //用于请求php后台数据
+ (NSString *)getEncryptString{
    NSString *time = [self getTimeString];
    NSString *key1 = [time stringByAppendingString:encryptionKey];
    NSString *secret1 = [self md5EncryptWithString:key1];
    NSString *key2 = [secret1 stringByAppendingString:encryptionKey];
    NSString *secret3 = [self md5EncryptWithString:key2];
    NSString * appendUrl = [NSString stringWithFormat:@"%@%@%@%@", @"&time=", time,@"&secret=",secret3];
    return appendUrl;
}
+ (NSString *)getEncryptString2{
    NSString *time = [self getTimeString];
    NSString *key1 = [time stringByAppendingString:encryptionKey];
    NSString *secret1 = [self md5EncryptWithString:key1];
    NSString *key2 = [secret1 stringByAppendingString:encryptionKey];
    NSString *secret3 = [self md5EncryptWithString:key2];
    NSString * appendUrl = [NSString stringWithFormat:@"%@%@%@%@", @"time=", time,@"&secret=",secret3];
    return appendUrl;
}
    
    //app调用界面方法
+(void)appCalljs:(WKWebView *)wkwebview jsString:(NSString *)jsString{
    @try{
        [wkwebview evaluateJavaScript:jsString completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            NSLog(@"appCalljs>>>>>>>>>>>>: %@ error: %@", response, error);
        }];
    }@catch(NSException *e){NSLog(@"evaluateJavaScript error:%@",e);};
}
    
    //截屏
+ (UIImage *)captureCurrentView:(UIView *)view {
    CGRect frame = view.frame;
    UIGraphicsBeginImageContext(frame.size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:contextRef];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
    //删除多余的支付控件,支付宝等会拉起额外的控件层
+ (void)deletePayView:(NSArray *)views{
    for (UIView *v in views) {
        if (v.tag >=300 && v.tag <400) {
            [v removeFromSuperview];
        }
    }
}
    //post提交
+(NSDictionary*)getPostData:(NSString*)url bodyString:(NSString*)bodyString{
    NSURL *toUrl = [NSURL URLWithString:url];
    NSMutableURLRequest  *request = [NSMutableURLRequest requestWithURL:toUrl];
    request.HTTPMethod=@"POST";
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody=bodyData;
    NSError *error=nil;
    NSData *responseData=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error) {
        NSLog(@"post 请求错误：%@",error.localizedDescription);
        return nil;
    }
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"ios服务器验证返回-->%@",dic);
    return dic;
}
    
    //md5
+ (NSString *)md5:(NSString *)input{
    const char *cStr = [input UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
    
+ (BOOL)validateCellPhoneNumber:(NSString *)cellNum{
        /**
         * 手机号码
         * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
         * 联通：130,131,132,152,155,156,185,186
         * 电信：133,1349,153,180,189
         */
        NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
        
        /**
         10         * 中国移动：China Mobile
         11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
         12         */
        NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
        
        /**
         15         * 中国联通：China Unicom
         16         * 130,131,132,152,155,156,185,186
         17         */
        NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
        
        /**
         20         * 中国电信：China Telecom
         21         * 133,1349,153,177,180,189
         22         */
        NSString * CT = @"^1((33|53|77|8[09])[0-9]|349)\\d{7}$";
        
        /**
         25         * 大陆地区固话及小灵通
         26         * 区号：010,020,021,022,023,024,025,027,028,029
         27         * 号码：七位或八位
         28         */
        // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
        
        NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
        NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
        NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
        NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
        // NSPredicate *regextestPHS = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
        
        if(([regextestmobile evaluateWithObject:cellNum] == YES)
           || ([regextestcm evaluateWithObject:cellNum] == YES)
           || ([regextestct evaluateWithObject:cellNum] == YES)
           || ([regextestcu evaluateWithObject:cellNum] == YES)){
            return YES;
        }else{
            return NO;
        }
    }
    
    @end

