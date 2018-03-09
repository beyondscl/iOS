//
//  pay.h
//  qzh
//
//  Created by xianming on 2018/3/1.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#ifndef pay_h
#define pay_h


#endif /* pay_h */
#import <Foundation/Foundation.h>//由于使用了NSObject，所以导入此头文件
@interface pay : NSObject{
    
}
+(NSString*)zfbPay:(NSString *)uid price:(NSString *)price productid:(NSString *)productid hintstr:(NSString *)hintstr;
+(NSSet*)appleGetProduct:(NSString *)goodid;

@end

