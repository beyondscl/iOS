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
    
+(NSDictionary *)dfSignin:(NSString *)account password:(NSString *)password{
    NSString *ency = [UtilTool getEncryptString];
    password = [UtilTool md5:password];
    NSString *dataString = [NSString stringWithFormat:@"account=%@&password=%@%@",account,password,ency];
    NSDictionary *d = [UtilTool getPostData:dfSignin bodyString:dataString];
    return d;
}
+(NSDictionary *)touSignin{
    NSString *dataString = [UtilTool getEncryptString2];
    NSDictionary *d = [UtilTool getPostData:touSignin bodyString:dataString];
    return d;
}
+(NSDictionary*)findkey:(NSString *)account  pass:(NSString*)pass verifyCode:(NSString*)verifyCode{
    NSString *ency = [UtilTool getEncryptString];
    pass = [UtilTool md5:pass];
    NSString *dataString = [NSString stringWithFormat:@"account=%@&pass1=%@&pass2=%@&verify_code=%@%@",account,pass,pass,verifyCode,ency];
    NSDictionary *d = [UtilTool getPostData:findkey bodyString:dataString];
    return  d;
}
    //注册发送验证吗|找回密码发送验证
+(NSDictionary*)sendvVrifyMsg:(NSString *)account type:(NSString*)type{
    //    NSString *type = @"phoneRegist";//emailRegist
    NSString *ency = [UtilTool getEncryptString];
    
    NSString *dataString = [NSString stringWithFormat:@"account=%@&type=%@%@",account,type,ency];
    NSDictionary *d = [UtilTool getPostData:sendMsg bodyString:dataString];
    return  d;
}
+(NSDictionary*)dfSignup:(NSString *)account  pass:(NSString*)pass verifyCode:(NSString*)verifyCode nickname:(NSString*)nickname{
    NSString *ency = [UtilTool getEncryptString];
    pass = [UtilTool md5:pass];
    NSString *dataString = [NSString stringWithFormat:@"account=%@&pass1=%@&pass2=%@&verify_code=%@&nickname=%@%@",account,pass,pass,verifyCode,nickname,ency];
    NSDictionary *d = [UtilTool getPostData:dfSignup bodyString:dataString];
    return d;
}
    @end
