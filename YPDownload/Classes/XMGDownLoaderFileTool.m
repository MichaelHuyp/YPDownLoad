//
//  XMGDownLoaderFileTool.m
//  XMGDownLoadLib
//
//  Created by 小码哥 on 2016/11/26.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "XMGDownLoaderFileTool.h"

@implementation XMGDownLoaderFileTool

+ (BOOL)isFileExists: (NSString *)path {
    
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
    
}


+ (long long)fileSizeWithPath: (NSString *)path {
    
    if (![self isFileExists:path]) {
        return 0;
    }
    
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    
    long long size = [fileInfo[NSFileSize] longLongValue];
    
    return size;
    
    
}

+ (void)moveFile:(NSString *)fromPath toPath: (NSString *)toPath {
    
    if (![self isFileExists:fromPath]) {
        return;
    }
    
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
    
    
}

+ (void)removeFileAtPath: (NSString *)path {
    
    if (![self isFileExists:path]) {
        return;
    }
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    
}


@end
