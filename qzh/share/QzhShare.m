
#import <Foundation/Foundation.h>
#import "QzhShare.h"

#import "JSHAREService.h"


@implementation QzhShare

+ (void)hbo_wechatShareLinkWithScene:(int)scene imgurl:(NSString *)imgurl linkurl:(NSString *)linkurl  title:(NSString *)title andDescription:(NSString *)description
{

}

+(void)hbo_jgshare:(int)sence title:(NSString *)title  image:(UIImage *)image linkurl:(NSString *)linkurl{
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
