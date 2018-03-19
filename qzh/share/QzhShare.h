//
//  QWxShare.h
//  qzh
//
//  Created by xianming on 2018/2/7.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#ifndef QWxShare_h
#define QWxShare_h


#endif /* QWxShare_h */
#import <Foundation/Foundation.h>//由于使用了NSObject，所以导入此头文件
#import <UIKit/UIKit.h>
#import "JSHAREService.h"
@interface QzhShare : NSObject{
    
}
//微信分享 scene 0 好友，1 朋友圈,2收藏
+ (void)wechatShareLinkWithScene:(int)scene imgurl:(NSString *)imgurl linkurl:(NSString *)linkurl  title:(NSString *)title andDescription:(NSString *)description;
//QQ分享
//+ (void)qqShowMediaNewsWithScene:(int)scene imgurl:(NSString *)imgurl linkurl:(NSString *)linkurl  title:(NSString *)title andDescription:(NSString *)description;
+(void)jgshare:(int)sence title:(NSString *)title  image:(UIImage *)image linkurl:(NSString *)linkurl;
@end
