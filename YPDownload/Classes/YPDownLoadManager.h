//
//  YPDownLoadManager.h
//  YPDownLoader
//
//  Created by 胡云鹏 on 2016/12/19.
//  Copyright © 2016年 yongche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPDownLoader.h"

NS_ASSUME_NONNULL_BEGIN

@interface YPDownLoadManager : NSObject

+ (instancetype)defaultManager;

/**
 下载指定url的文件
 
 @param url 文件的url路径
 @param downloadProgressBlock 下载进度回调
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
- (void)downLoadWithURL:(NSURL *)url downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock success:(nullable void(^)(NSString *cacheFilePath))successBlock failure:(nullable void(^)(NSError *error))failureBlock;


/**
 暂停指定url下载
 */
- (void)pauseWithURL: (NSURL *)url;


/**
 取消指定url下载
 */
- (void)cancelWithURL: (NSURL *)url;


/**
 取消所有
 */
- (void)pauseAll;

@end

NS_ASSUME_NONNULL_END
