//
//  NetworkUtil.m
//  UiLearn
//
//  Created by xianming on 2018/3/14.
//  Copyright © 2018年 hzqzh. All rights reserved.
// 采用代理的方式进行下载
//

#import <Foundation/Foundation.h>
#import "DownLoad.h"
#import "FileUtil.h"
#import "Commutate.h"

@interface DownLoad()<NSURLSessionDownloadDelegate>
@property NSURLSession *session;
@property (nonatomic, weak)id<DownProgress> downProgressDele;

@end

@implementation DownLoad


-(void)hbo_doInit:(id)downDelegate{
    self.downProgressDele =downDelegate;
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration  defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
}
-(Boolean)hbo_checkSession{
    if (_session==nil) {
        NSLog(@"session didnot init");
        return false;
    }
    return true;
}
-(void)hbo_download:(NSString*)urlStr{
    [self hbo_checkSession];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLSessionDownloadTask *downTask = [_session downloadTaskWithURL:url];
    [downTask resume];
}
//写入本地代理
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    //    Documents:您应该将所有de应用程序数据文件写入到这个目录下。这个目录用于存储用户数据或其它应该定期备份的信息。
    //    Library:这个目录下有两个子目录：Caches 和Preferences
    //    Preferences：应用程序的偏好设置文件。不应该直接创建偏好设置文件，而是应该使用NSUserDefaults类来取得和设置应用程序的偏好.
    //    Caches：用于存放应用程序专用的支持文件，保存应用程序再次启动过程中需要的信息。
    //    tmp 目录：这个目录用于存放临时文件，保存应用程序再次启动过程中不需要的信息。
    //    NSString *homeDir = NSHomeDirectory();
    //    NSArray *path1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSArray *path2 = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //    NSString *tmpDir =  NSTemporaryDirectory();
    //  documentPath    NSPathStore2 *    @"/var/mobile/Containers/Data/Application/0A4634BE-E03D-411B-976F-E3378DD7C122/Documents"    0x000000017017bb40
    
    NSString *rootPaht = [FileUtil hbo_getRootPath];
    NSString *filePath = @"";
    NSString *fileName = downloadTask.response.suggestedFilename;
    
    NSString *fullPath = [rootPaht stringByAppendingFormat:@"%@%@",filePath,fileName];
    [FileUtil hbo_moveFileFromDown:location toFullPath:fullPath];
    if (fileName && [fileName containsString:@".zip"]) {
        NSString *fileNameT = [[fileName componentsSeparatedByString:@"."] firstObject];
        [FileUtil hbo_unZip:fullPath unzipPath:[rootPaht stringByAppendingString:fileNameT]];
    }
}
//恢复下载代理
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}
//下载过程
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    float downPercent = 1.0*totalBytesWritten/totalBytesExpectedToWrite;
    NSLog(@"总下载百分比%1f:",downPercent);
    [self.downProgressDele setDownProgress:downPercent];
}
//请求完成,错误的代理方法
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error) {
        NSLog(@"下载出错%@:",error);
    }
}

@end
