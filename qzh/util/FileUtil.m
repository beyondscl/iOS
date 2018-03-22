//
//  FileUtil.m
//  UiLearn
//
//  Created by xianming on 2018/3/14.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileUtil.h"
#import "ZipArchive.h"
#import "SSZipArchive.h"

#import <CommonCrypto/CommonDigest.h>
#define FileHashDefaultChunkSizeForReadingData 1024*8

@interface FileUtil()
@end

@implementation FileUtil

//获取Document路径
+ (NSString *)hbo_getDocumentPath
{
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [filePaths objectAtIndex:0];
}

//获取Library路径
+ (NSString *)hbo_getLibraryPath
{
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [filePaths objectAtIndex:0];
}

//获取应用程序路径
+ (NSString *)hbo_getApplicationPath
{
    return NSHomeDirectory();
}

//获取Cache路径
+ (NSString *)hbo_getCachePath
{
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [filePaths objectAtIndex:0];
}

//获取Temp路径
+ (NSString *)hbo_getTempPath
{
    return NSTemporaryDirectory();
}

//判断文件是否存在于某个路径中
+ (BOOL)hbo_fileIsExistOfPath:(NSString *)filePath
{
    BOOL flag = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        flag = YES;
    } else {
        flag = NO;
    }
    return flag;
}

//从某个路径中移除文件
+ (BOOL)hbo_removeFileOfPath:(NSString *)filePath
{
    BOOL flag = YES;
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if ([fileManage fileExistsAtPath:filePath]) {
        if (![fileManage removeItemAtPath:filePath error:nil]) {
            flag = NO;
        }
    }
    return flag;
}

//从URL路径中移除文件
- (BOOL)hbo_removeFileOfURL:(NSURL *)fileURL
{
    BOOL flag = YES;
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if ([fileManage fileExistsAtPath:fileURL.path]) {
        if (![fileManage removeItemAtURL:fileURL error:nil]) {
            flag = NO;
        }
    }
    return flag;
}

//创建文件路径
+(BOOL)hbo_creatDirectoryWithPath:(NSString *)dirPath
{
    BOOL ret = YES;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:dirPath];
    if (!isExist) {
        NSError *error;
        BOOL isSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!isSuccess) {
            ret = NO;
            NSLog(@"creat Directory Failed. errorInfo:%@",error);
        }
    }
    return ret;
}

//创建文件
+ (BOOL)hbo_creatFileWithPath:(NSString *)filePath
{
    BOOL isSuccess = YES;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL temp = [fileManager fileExistsAtPath:filePath];
    if (temp) {
        return YES;
    }
    NSError *error;
    //stringByDeletingLastPathComponent:删除最后一个路径节点
    NSString *dirPath = [filePath stringByDeletingLastPathComponent];
    isSuccess = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"creat File Failed. errorInfo:%@",error);
    }
    if (!isSuccess) {
        return isSuccess;
    }
    isSuccess = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    return isSuccess;
}

//保存文件
+ (BOOL)hbo_saveFile:(NSString *)filePath withData:(NSData *)data
{
    BOOL ret = YES;
    ret = [self hbo_creatFileWithPath:filePath];
    if (ret) {
        ret = [data writeToFile:filePath atomically:YES];
        if (!ret) {
            NSLog(@"%s Failed",__FUNCTION__);
        }
    } else {
        NSLog(@"%s Failed",__FUNCTION__);
    }
    return ret;
}

//追加写文件
+ (BOOL)hbo_appendData:(NSData *)data withPath:(NSString *)path
{
    BOOL result = [self hbo_creatFileWithPath:path];
    if (result) {
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
        [handle seekToEndOfFile];
        [handle writeData:data];
        [handle synchronizeFile];
        [handle closeFile];
        return YES;
    } else {
        NSLog(@"%s Failed",__FUNCTION__);
        return NO;
    }
}

//获取文件
+ (NSData *)hbo_getFileData:(NSString *)filePath
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData *fileData = [handle readDataToEndOfFile];
    [handle closeFile];
    return fileData;
}

//读取文件
+ (NSData *)hbo_getFileData:(NSString *)filePath startIndex:(long long)startIndex length:(NSInteger)length
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    [handle seekToFileOffset:startIndex];
    NSData *data = [handle readDataOfLength:length];
    [handle closeFile];
    return data;
}

//移动文件
+ (BOOL)hbo_moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fromPath]) {
        NSLog(@"Error: fromPath Not Exist");
        return NO;
    }
    if (![fileManager fileExistsAtPath:toPath]) {
        NSLog(@"Error: toPath Not Exist");
        return NO;
    }
    NSString *headerComponent = [toPath stringByDeletingLastPathComponent];
    if ([self hbo_creatFileWithPath:headerComponent]) {
        return [fileManager moveItemAtPath:fromPath toPath:toPath error:nil];
    } else {
        return NO;
    }
}

//拷贝文件
+(BOOL)hbo_copyFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fromPath]) {
        NSLog(@"Error: fromPath Not Exist");
        return NO;
    }
    if (![fileManager fileExistsAtPath:toPath]) {
        NSLog(@"Error: toPath Not Exist");
        return NO;
    }
    NSString *headerComponent = [toPath stringByDeletingLastPathComponent];
    if ([self hbo_creatFileWithPath:headerComponent]) {
        return [fileManager copyItemAtPath:fromPath toPath:toPath error:nil];
    } else {
        return NO;
    }
}

//获取文件夹下文件列表,dir | file
+ (NSArray *)hbo_getFileListInFolderWithPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:path error:&error];
    if (error) {
        NSLog(@"getFileListInFolderWithPathFailed, errorInfo:%@",error);
    }
    return fileList;
}

//获取文件大小
+ (long long)hbo_getFileSizeWithPath:(NSString *)path
{
    unsigned long long fileLength = 0;
    NSNumber *fileSize;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:nil];
    if ((fileSize = [fileAttributes objectForKey:NSFileSize])) {
        fileLength = [fileSize unsignedLongLongValue];
    }
    return fileLength;
    
    //    NSFileManager* manager =[NSFileManager defaultManager];
    //    if ([manager fileExistsAtPath:path]){
    //        return [[manager attributesOfItemAtPath:path error:nil] fileSize];
    //    }
    //    return 0;
}

//获取文件创建时间
+ (NSString *)hbo_getFileCreatDateWithPath:(NSString *)path
{
    NSString *date = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:nil];
    date = [fileAttributes objectForKey:NSFileCreationDate];
    return date;
}

//获取文件所有者
+ (NSString *)hbo_getFileOwnerWithPath:(NSString *)path
{
    NSString *fileOwner = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:nil];
    fileOwner = [fileAttributes objectForKey:NSFileOwnerAccountName];
    return fileOwner;
}

//获取文件更改日期
+ (NSString *)hbo_getFileChangeDateWithPath:(NSString *)path
{
    NSString *date = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:nil];
    date = [fileAttributes objectForKey:NSFileModificationDate];
    return date;
}
//下载并拷贝文件location toFullPath:/xc/xx/xx.?
+ (NSError*)hbo_moveFileFromDown:(NSURL *)location toFullPath:(NSString*)toFullPath{
    if ([self hbo_fileIsExistOfPath:toFullPath]) {
        [self hbo_removeFileOfPath:toFullPath];
    }
    NSError *error;
    [[NSFileManager defaultManager]moveItemAtURL:location toURL:[NSURL fileURLWithPath:toFullPath] error:&error];
    if (error) {
        NSLog(@"下载后拷贝文件出错:%@",error);
    }
    return error;
}
//下载文件的根目录
+(NSString*)hbo_getRootPath{
    //    [[NSBundle mainBundle] resourcePath]
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *appbundleIdf = [[NSBundle mainBundle]bundleIdentifier];
    NSString *root =  [NSString stringWithFormat:@"%@/%@/%@/",documentPath,appbundleIdf,@"downloads"];
    root=[root stringByReplacingOccurrencesOfString:@"."withString:@"/"];
    if ([FileUtil hbo_creatDirectoryWithPath:root]) {
        NSLog(@"创建文件夹成功%@",root);
        return root;
    }
    NSLog(@"创建文件夹失败%@",root);
    return @"";
}

//解压zip文件
+(void)hbo_unZip:(NSString*)zipPath unzipPath:(NSString*)unzipPath{
    if(![self hbo_fileIsExistOfPath:zipPath]){
        NSLog(@"解压源文件不存在:%@",@"");
        return;
    }
    //    [self getFileListInFolderWithPath:unzipPath];
    NSError *error;
    if ([SSZipArchive unzipFileAtPath:zipPath toDestination:unzipPath overwrite:YES password:nil error:&error delegate:nil]) {
        NSLog(@"success");
    }
    else{
        NSLog(@"解压失败:%@",error);
    }
}


//获取文件的md5值
+(NSString*)hbo_getFileMD5WithPath:(NSString*)path

{
    
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)path, FileHashDefaultChunkSizeForReadingData);
    
}


CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  
                                  (CFStringRef)filePath,
                                  
                                  kCFURLPOSIXPathStyle,
                                  
                                  (Boolean)false);
    if (!fileURL) goto done;
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
done:
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}
@end
