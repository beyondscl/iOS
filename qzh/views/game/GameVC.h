//
//  GameVC.h
//  UiLearn
//
//  Created by xianming on 2018/3/16.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#ifndef GameVC_h
#define GameVC_h


#endif /* GameVC_h */
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

//初始化传值
//协议传值
//块代码传值

@protocol UserInfoDelegate <NSObject>
-(void)setUserInfo:(NSDictionary*)userInfo;
@end


@interface GameVC : UIViewController
 @property (nonatomic, assign) id<UserInfoDelegate> delegate;

-(id)initWithInfo:(NSDictionary*)userinfo;
@end

