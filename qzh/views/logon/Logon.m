//
//  Logon.m
//  UiLearn
//
//  Created by xianming on 2018/3/15.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Logon.h"
#import "Util.h"
#import "FileUtil.h"
static NSString *dfSignup = @"http://wx.ldgame.com/index.php/Stepone/dfSignup";//注册
static NSString *touSignin = @"http://wx.ldgame.com/index.php/Stepone/touSignin";//游客登录地址
static NSString *findkey = @"http://wx.ldgame.com/index.php/Stepone/findkey";//找回密码地址
static NSString *sendMsg = @"http://wx.ldgame.com/index.php/Verifymsg/send_vmsg";//发送验证码地址
static NSString *dfSignin = @"http://wx.ldgame.com/index.php/Stepone/dfSignin";//传统登录地址


@interface Logon()
    
    @end

@implementation Logon
    
+(NSDictionary *)hbo_dfSignin:(NSString *)account password:(NSString *)password{
    NSString *ency = [UtilTool hbo_getEncryptString];
    password = [UtilTool hbo_md5:password];
    NSString *dataString = [NSString stringWithFormat:@"account=%@&password=%@%@",account,password,ency];
    NSDictionary *d = [UtilTool hbo_getPostData:dfSignin bodyString:dataString];
    return d;
}
+(NSDictionary *)hbo_touSignin{
    NSString *dataString = [UtilTool hbo_getEncryptString2];
    NSDictionary *d = [UtilTool hbo_getPostData:touSignin bodyString:dataString];
    return d;
}
+(NSDictionary*)hbo_findkey:(NSString *)account  pass:(NSString*)pass verifyCode:(NSString*)verifyCode{
    NSString *ency = [UtilTool hbo_getEncryptString];
    pass = [UtilTool hbo_md5:pass];
    NSString *dataString = [NSString stringWithFormat:@"account=%@&pass1=%@&pass2=%@&verify_code=%@%@",account,pass,pass,verifyCode,ency];
    NSDictionary *d = [UtilTool hbo_getPostData:findkey bodyString:dataString];
    return  d;
}
    //注册发送验证吗|找回密码发送验证
+(NSDictionary*)hbo_sendvVrifyMsg:(NSString *)account type:(NSString*)type{
    //    NSString *type = @"phoneRegist";//emailRegist
    NSString *ency = [UtilTool hbo_getEncryptString];
    
    NSString *dataString = [NSString stringWithFormat:@"account=%@&type=%@%@",account,type,ency];
    NSDictionary *d = [UtilTool hbo_getPostData:sendMsg bodyString:dataString];
    return  d;
}
+(NSDictionary*)hbo_dfSignup:(NSString *)account  pass:(NSString*)pass verifyCode:(NSString*)verifyCode nickname:(NSString*)nickname{
    NSString *ency = [UtilTool hbo_getEncryptString];
    pass = [UtilTool hbo_md5:pass];
    NSString *dataString = [NSString stringWithFormat:@"account=%@&pass1=%@&pass2=%@&verify_code=%@&nickname=%@%@",account,pass,pass,verifyCode,nickname,ency];
    NSDictionary *d = [UtilTool hbo_getPostData:dfSignup bodyString:dataString];
    return d;
}
    @end
