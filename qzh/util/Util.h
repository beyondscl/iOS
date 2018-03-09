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
+(void)doAlert:(NSString *)Msg;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
+ (NSString*)convertToJSONData:(id)infoDict;
+(NSDictionary *)getSendRequest:(NSString *)urlOrigin;
+(NSString *)getUniqueDeviceIdentifierAsString;
//时间撮
+(NSString *)getTimeString;
//md5加密
+ (NSString *)md5EncryptWithString:(NSString *)string;
//用于请求php后台数据
+ (NSString *)getEncryptString;
//app调用界面方法
+(void)appCalljs:(WKWebView *)wkwebview jsString:(NSString *)jsString;
//截屏
+ (UIImage *)captureCurrentView:(UIView *)view;
//删除多余的支付控件,支付宝等会拉起额外的控件层
+ (void)deletePayView:(NSArray *)view;

@end
