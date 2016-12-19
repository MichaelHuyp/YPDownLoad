//
//  XMGDownLoaderFileTool.h
//  XMGDownLoadLib
//
//  Created by 小码哥 on 2016/11/26.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMGDownLoaderFileTool : NSObject

+ (BOOL)isFileExists: (NSString *)path;

+ (long long)fileSizeWithPath: (NSString *)path;

+ (void)moveFile:(NSString *)fromPath toPath: (NSString *)toPath;


+ (void)removeFileAtPath: (NSString *)path;

@end
