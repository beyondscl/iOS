//
//  FileUtil.h
//  UiLearn
//
//  Created by xianming on 2018/3/14.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#ifndef FileUtil_h
#define FileUtil_h


#endif /* FileUtil_h */
#import <Foundation/Foundation.h>

@interface FileUtil : NSObject


//获取Document路径
+ (NSString *)hbo_getDocumentPath;
//获取Library路径
+ (NSString *)hbo_getLibraryPath;
//获取应用程序路径
+ (NSString *)hbo_getApplicationPath;
//获取Cache路径
+ (NSString *)hbo_getCachePath;
//获取Temp路径
+ (NSString *)hbo_getTempPath;
//判断文件是否存在于某个路径中
+ (BOOL)hbo_fileIsExistOfPath:(NSString *)filePath;
//从某个路径中移除文件
+ (BOOL)hbo_removeFileOfPath:(NSString *)filePath;
//从URL路径中移除文件
- (BOOL)hbo_removeFileOfURL:(NSURL *)fileURL;
//创建文件路径
+(BOOL)hbo_creatDirectoryWithPath:(NSString *)dirPath;
//创建文件
+ (BOOL)hbo_creatFileWithPath:(NSString *)filePath;
//保存文件
+ (BOOL)hbo_saveFile:(NSString *)filePath withData:(NSData *)data;
//追加写文件
+ (BOOL)hbo_appendData:(NSData *)data withPath:(NSString *)path;
//获取文件
+ (NSData *)hbo_getFileData:(NSString *)filePath;
//读取文件
+ (NSData *)hbo_getFileData:(NSString *)filePath startIndex:(long long)startIndex length:(NSInteger)length;
+ (BOOL)hbo_moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath;
//拷贝文件
+(BOOL)hbo_copyFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath;
//获取文件夹下文件列表
+ (NSArray *)hbo_getFileListInFolderWithPath:(NSString *)path;
//获取文件大小
+ (long long)hbo_getFileSizeWithPath:(NSString *)path;
//获取文件创建时间
+ (NSString *)hbo_getFileCreatDateWithPath:(NSString *)path;
//获取文件所有者
+ (NSString *)hbo_getFileOwnerWithPath:(NSString *)path;
//获取文件更改日期
+ (NSString *)hbo_getFileChangeDateWithPath:(NSString *)path;
//下载并拷贝文件
+ (NSError*)hbo_moveFileFromDown:(NSURL *)location toFullPath:(NSString*)toFullPath;
//下载文件的根目录
+(NSString*)hbo_getRootPath;
//解压文件
+(void)hbo_unZip:(NSString*)zipPath unzipPath:(NSString*)unzipPath;
//获取文件的md5值
+(NSString*)hbo_getFileMD5WithPath:(NSString*)path;
@end
