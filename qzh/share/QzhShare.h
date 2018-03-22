
#ifndef QWxShare_h
#define QWxShare_h


#endif /* QWxShare_h */
#import <Foundation/Foundation.h>//由于使用了NSObject，所以导入此头文件
#import <UIKit/UIKit.h>
#import "JSHAREService.h"
@interface QzhShare : NSObject{
    
}
+ (void)hbo_wechatShareLinkWithScene:(int)scene imgurl:(NSString *)imgurl linkurl:(NSString *)linkurl  title:(NSString *)title andDescription:(NSString *)description;

+(void)hbo_jgshare:(int)sence title:(NSString *)title  image:(UIImage *)image linkurl:(NSString *)linkurl;
@end
