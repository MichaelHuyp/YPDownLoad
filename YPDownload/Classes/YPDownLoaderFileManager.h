//
//  YPDownLoaderFileManager.h
//  YPDownLoader
//
//  Created by 胡云鹏 on 2016/12/16.
//  Copyright © 2016年 yongche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YPDownLoaderFileManager : NSObject

/**
 指定路径上的文件是否存在

 @param path 文件路径
 @return 存在返回YES
 */
+ (BOOL)isFileExists:(NSString *)path;


/**
 读取指定路径下文件的大小

 @param path 文件路径
 @return 文件大小
 */
+ (long long)fileSizeWithPath:(NSString *)path;


/**
 将指定路径下的文件移动到目标路径

 @param fromPath 指定路径
 @param toPath 目标路径
 */
+ (void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath;


/**
 移除指定路径下的文件
 
 @param path 文件路径
 */
+ (void)removeFileAtPath:(NSString *)path;

@end


































