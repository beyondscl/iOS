//
//  Util.m
//  qzh
//
//  Created by xianming on 2018/2/6.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Util.h"

#import "SAMKeychain.h"
#import "SAMKeychainQuery.h"

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
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    
    NSString *strApplicationUUID =  [SAMKeychain passwordForService:appName account:@"incoding"];
    if (strApplicationUUID == nil)
    {
        strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        
        NSError *error = nil;
        SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
        query.service = appName;
        query.account = @"incoding";
        query.password = strApplicationUUID;
        query.synchronizationMode = SAMKeychainQuerySynchronizationModeNo;
        [query save:&error];
        
    }
    return strApplicationUUID;
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

//app调用界面方法
+(void)appCalljs:(WKWebView *)wkwebview jsString:(NSString *)jsString{
    [wkwebview evaluateJavaScript:jsString completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"appCalljs>>>>>>>>>>>>: %@ error: %@", response, error);
    }];
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

@end

