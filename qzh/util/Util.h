//
//  Util.h
//  qzh
//
//  Created by xianming on 2018/2/6.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#ifndef Util_h
#define Util_h


#endif /* Util_h */
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <Foundation/Foundation.h>//由于使用了NSObject，所以导入此头文件
@interface UtilTool : NSObject{
    
}
+(void)hbo_doAlert:(NSString *)Msg;
+ (NSDictionary *)hbo_dictionaryWithJsonString:(NSString *)jsonString;
+ (NSString*)hbo_convertToJSONData:(id)infoDict;
+(NSDictionary *)hbo_getSendRequest:(NSString *)urlOrigin;
+(NSString *)hbo_getUniqueDeviceIdentifierAsString;
//时间撮
+(NSString *)hbo_getTimeString;
//md5加密
+ (NSString *)hbo_md5EncryptWithString:(NSString *)string;
//用于请求php后台数据
+ (NSString *)hbo_getEncryptString;
+ (NSString *)hbo_getEncryptString2;
//app调用界面方法
+(void)hbo_appCalljs:(WKWebView *)wkwebview jsString:(NSString *)jsString;
//截屏
+ (UIImage *)hbo_captureCurrentView:(UIView *)view;
//删除多余的支付控件,支付宝等会拉起额外的控件层
+ (void)hbo_deletePayView:(NSArray *)view;
//post提交
+(NSDictionary*)hbo_getPostData:(NSString*)url bodyString:(NSString*)bodyString;
//md5
+ (NSString *)hbo_md5:(NSString *)input;
//验证手机号码
+ (BOOL)hbo_validateCellPhoneNumber:(NSString *)cellNum;

//hbo
+(void)hbo_sayHello;
@end
