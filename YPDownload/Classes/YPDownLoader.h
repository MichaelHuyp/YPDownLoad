//
//  YPDownLoader.h
//  YPDownLoader
//
//  Created by 胡云鹏 on 2016/12/6.
//  Copyright © 2016年 yongche. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YPDownLoaderState) {
    // 占位
    YPDownLoaderStateUnknown,
    // 暂停状态
    YPDownLoaderStatePause,
    // 正在下载中
    YPDownLoaderStateDowning,
    // 下载成功
    YPDownLoaderStateSuccess,
    // 下载失败
    YPDownLoaderStateFailed
};

@interface YPDownLoader : NSObject

/** 下载状态 */
@property (nonatomic, assign) YPDownLoaderState state;

// 恢复下载
- (void)resume;

// 暂停任务
- (void)pause;

// 取消任务并清除缓存
- (void)cancelAndClearCache;


/**
 下载指定url的文件

 @param url 文件的url路径
 @param downloadProgressBlock 下载进度回调
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
- (void)downLoadWithURL:(NSURL *)url downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock success:(nullable void(^)(NSString *cacheFilePath))successBlock failure:(nullable void(^)(NSError *error))failureBlock;

@end

NS_ASSUME_NONNULL_END













































