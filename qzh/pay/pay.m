//
//  pay.m
//  qzh
//
//  Created by xianming on 2018/3/1.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#import <Foundation/Foundation.h>
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
    //    if(resp){
    //        NSString *code = [resp objectForKey:@"code"];
    //        NSString *message = [resp objectForKey:@"message"];
    //
    //        if ([code isEqual:@"0"]) {
    //            NSDictionary *data = [resp objectForKey:@"data"];
    //            NSString *appid = [data objectForKey:@"appid"];
    //            NSString *noncestr = [data objectForKey:@"noncestr"];
    //            NSString *package = [data objectForKey:@"package"];
    //            NSString *prepayid = [data objectForKey:@"prepayid"];
    //            NSString *partnerid = [data objectForKey:@"partnerid"];
    //            NSString *timestamp = [data objectForKey:@"timestamp"];
    //            NSString *sign = [data objectForKey:@"sign"];
    //
    //            PayReq *request = [[PayReq alloc] init];
    //            request.partnerId = partnerid;
    //            request.prepayId= prepayid;
    //            request.package = package;
    //            request.nonceStr= noncestr;
    //            request.timeStamp= timestamp.intValue;
    //            request.sign= sign;
    //            [WXApi sendReq:request];
    //
    //        }else{
    //            NSLog(@"%@",message);
    //        }
    //    }else{
    //        NSLog(@"%s","返回数据为空或者转换json错误");
    //    }
    NSLog(@"%s","不支持应用内拉起微信支付");
}

- (NSSet*)appleGetProduct:(NSString *)goodid {
    NSLog(@"---------请求对应的产品信息------------");
    NSArray *product = nil;
    long int buyType = goodid.integerValue;
    switch (buyType) {
        case 1001:
            product = [NSArray arrayWithObject:ProductID_IAP_1];
            break;
        case 1002:
            product = [NSArray arrayWithObject:ProductID_IAP_2];
            break;
        case 1003:
            product = [NSArray arrayWithObject:ProductID_IAP_3];
            break;
        case 1004:
            product = [NSArray arrayWithObject:ProductID_IAP_4];
            break;
        case 1005:
            product = [NSArray arrayWithObject:ProductID_IAP_5];
            break;
        case 1006:
            product = [NSArray arrayWithObject:ProductID_IAP_6];
            break;
    }
    return [NSSet setWithArray:product];
}



@end

