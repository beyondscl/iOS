//
//  Logon.h
//  UiLearn
//
//  Created by xianming on 2018/3/15.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#ifndef Logon_h
#define Logon_h


#endif /* Logon_h */
#import <Foundation/Foundation.h>
@interface Logon  : NSObject

+(NSDictionary *)hbo_dfSignin:(NSString *)account password:(NSString *)password;
+(NSDictionary *)hbo_touSignin;
+(NSDictionary*)hbo_dfSignup:(NSString *)account  pass:(NSString*)pass verifyCode:(NSString*)verifyCode nickname:(NSString*)nickname;
+(NSDictionary*)hbo_findkey:(NSString *)account  pass:(NSString*)pass verifyCode:(NSString*)verifyCode;
+(NSDictionary*)hbo_sendvVrifyMsg:(NSString *)account type:(NSString*)type;
    @end
