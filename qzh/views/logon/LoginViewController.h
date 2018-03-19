//
//  LoginViewController.h
//  WebViews
//
//  Created by xianming on 2018/3/13.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#ifndef LoginViewController_h
#define LoginViewController_h


#endif /* LoginViewController_h */
#import <UIKit/UIKit.h>



@protocol UserDelegate<NSObject>

@optional

- (void)getUserInfo;

@end

@interface LoginViewController:UIViewController

@property (nonatomic, copy) void (^GameVCBlock)(NSDictionary *userInfo);

@end


