//
//  QWxShare.m
//  qzh
//
//  Created by xianming on 2018/2/7.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QzhShare.h"

#import "JSHAREService.h"


@implementation QzhShare

+ (void)wechatShareLinkWithScene:(int)scene imgurl:(NSString *)imgurl linkurl:(NSString *)linkurl  title:(NSString *)title andDescription:(NSString *)description
{
//    NSLog(@"调用了微信分享");
//
//    //封装mediaMessage对象
//    WXMediaMessage *message = [WXMediaMessage message];
//
//    //设置微信分享的title
//    [message setTitle:title];
//    //设置分享描述内容
//    [message setDescription:description];
//    //设置分享所需图片
////    [message setThumbImage:[UIImage imageNamed:@"app_bg"]];
//    NSURL *url2 = [NSURL URLWithString:imgurl];
//    [message setThumbImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url2]]];
//
//
//    //封装WXWebpageObject对象
//    WXWebpageObject *ext = [WXWebpageObject object];
//    ext.webpageUrl = linkurl;
//    message.mediaObject = ext;
//
//    //发送请求
//    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
//    req.bText = NO;
//    req.message = message;
//    req.scene =  scene;//
////    WXSceneTimeline
//    [WXApi sendReq:req];
}


//主要是分享标题，图片，链接
+(void)jgshare:(int)sence title:(NSString *)title  image:(UIImage *)image linkurl:(NSString *)linkurl{
    if (!title) {
        title = @"乐豆游戏中心";
    }
    NSData *dataObj = UIImageJPEGRepresentation(image, 1.0);
    
    JSHAREMessage *message = [JSHAREMessage message];
    message.title = title;//标题
    message.text = @"分享测试分享测试分享测试分享测试";//这里用于文本分享
    message.platform = sence;//分享到哪里
    message.image = dataObj;//图片
    message.url = linkurl;//用于连接
    message.mediaType = JSHARELink;//分享链接：可以加入图片的链接
    [JSHAREService share:message handler:^(JSHAREState state, NSError *error) {
    }];
}

@end
