//
//  YPDownLoadManager.m
//  YPDownLoader
//
//  Created by 胡云鹏 on 2016/12/19.
//  Copyright © 2016年 yongche. All rights reserved.
//

#import "YPDownLoadManager.h"
#import "NSString+YPDownLoader.h"

@interface YPDownLoadManager ()

/** 用来保存下载任务 */
@property (nonatomic, strong) NSMutableDictionary <NSString *, YPDownLoader *> *downLoadInfo;

@end


@implementation YPDownLoadManager

#pragma mark - Public
+ (instancetype)defaultManager
{
    static YPDownLoadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

/**
 下载指定url的文件
 
 @param url 文件的url路径
 @param downloadProgressBlock 下载进度回调
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
- (void)downLoadWithURL:(NSURL *)url downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock success:(nullable void(^)(NSString *cacheFilePath))successBlock failure:(nullable void(^)(NSError *error))failureBlock
{
    NSString *urlMD5 = [url.absoluteString yp_MD5Str];
    
    YPDownLoader *downLoader = self.downLoadInfo[urlMD5];
    
    if (downLoader) { // 如果下载任务存在 那么恢复下载
        [downLoader resume];
        return;
    }
    
    // 下载任务不存在 创建
    downLoader = [YPDownLoader new];
    
    // 保存
    self.downLoadInfo[urlMD5] = downLoader;
    
    __weak typeof(self) weakSelf = self;
    // 开始下载
    [downLoader downLoadWithURL:url downloadProgress:downloadProgressBlock success:^(NSString * _Nonnull cacheFilePath) {
        // 下载完成 从信息字典中移除任务
        [weakSelf.downLoadInfo removeObjectForKey:urlMD5];
        if (successBlock) {
            successBlock(cacheFilePath);
        }
    } failure:^(NSError * _Nonnull error) {
        // 下载失败 从信息字典中移除任务
        [weakSelf.downLoadInfo removeObjectForKey:urlMD5];
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}


/**
 暂停指定url下载
 */
- (void)pauseWithURL: (NSURL *)url
{
    NSString *urlMD5 = [url.absoluteString yp_MD5Str];
    YPDownLoader *downLoader = self.downLoadInfo[urlMD5];
    [downLoader pause];
}


/**
 取消指定url下载
 */
- (void)cancelWithURL: (NSURL *)url
{
    NSString *urlMD5 = [url.absoluteString yp_MD5Str];
    YPDownLoader *downLoader = self.downLoadInfo[urlMD5];
    [downLoader cancelAndClearCache];
}


/**
 取消所有
 */
- (void)pauseAll
{
    [[self.downLoadInfo allValues] makeObjectsPerformSelector:@selector(pause)];
}

#pragma mark - Lazy

- (NSMutableDictionary<NSString *,YPDownLoader *> *)downLoadInfo
{
    if (!_downLoadInfo) {
        _downLoadInfo = [NSMutableDictionary dictionary];
    }
    return _downLoadInfo;
}

@end
