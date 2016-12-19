//
//  XMGDownLoader.h
//  XMGDownLoadLib
//
//  Created by 小码哥 on 2016/11/26.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    XMGDownLoaderStateUnKnown,
    /** 下载暂停 */
    XMGDownLoaderStatePause,
    /** 正在下载 */
    XMGDownLoaderStateDowning,
    /** 已经下载 */
    XMGDownLoaderStateSuccess,
    /** 下载失败 */
    XMGDownLoaderStateFailed
} XMGDownLoaderState;


typedef void(^DownLoadInfoType)(long long fileSize);
typedef void(^DownLoadSuccessType)(NSString *cacheFilePath);
typedef void(^DownLoadFailType)();

@interface XMGDownLoader : NSObject

// 如果当前已经下载, 继续下载, 如果没有下载, 从头开始下载
- (void)downLoadWithURL: (NSURL *)url;

- (void)downLoadWithURL: (NSURL *)url downLoadInfo: (DownLoadInfoType)downLoadBlock success: (DownLoadSuccessType)successBlock failed: (DownLoadFailType)failBlock;

// 恢复下载
- (void)resume;

// 暂停, 暂停任务, 可以恢复, 缓存没有删除
- (void)pause;


// 取消, 这次任务已经被取消,
- (void)cancel;

// 缓存删除
- (void)cancelAndClearCache;

// kvo , 通知, 代理, block
@property (nonatomic, assign) XMGDownLoaderState state;
@property (nonatomic, assign) float progress;


@property (nonatomic, copy) void(^downLoadProgress)(float progress);

// 文件下载信息 (下载的大小)
@property (nonatomic, copy) DownLoadInfoType downLoadInfo;

// 状态的改变 ()
@property (nonatomic, copy) void(^downLoadStateChange)(XMGDownLoaderState state);

// 下载成功 (成功路径)
@property (nonatomic, copy) DownLoadSuccessType downLoadSuccess;

// 失败 (错误信息)
@property (nonatomic, copy) DownLoadFailType downLoadError;


@end
