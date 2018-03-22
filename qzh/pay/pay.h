#ifndef pay_h
#define pay_h
#endif /* pay_h */
#define webInter @"http://39.108.178.35/myweb/webinter/";

#import <JavaScriptCore/JavaScriptCore.h>
#import <Foundation/Foundation.h>//由于使用了NSObject，所以导入此头文件
#import <StoreKit/StoreKit.h>

@interface pay : NSObject{
    
}
+(NSString*)hbo_zfbPay:(NSString *)uid price:(NSString *)price productid:(NSString *)productid hintstr:(NSString *)hintstr;
+(NSSet*)hbo_appleGetProduct:(NSString*)goodid;
+(void)hbo_payCallback:(NSString *)buyGoodId uid:(NSString*)uid uName:(NSString*)uName isProd:(int)isProd context:(JSContext *)context uiWebView:(UIWebView*)uiWebView;
+(void)hbo_verifyPurchaseWithPaymentTransaction;
@end

