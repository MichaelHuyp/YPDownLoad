//
//  XMGDownLoadManager.m
//  XMGDownLoadLib
//
//  Created by 小码哥 on 2016/11/27.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "XMGDownLoadManager.h"
#import "NSString+XMGDownLoader.h"

@interface XMGDownLoadManager()

@property (nonatomic, strong) NSMutableDictionary <NSString *, XMGDownLoader *>*downLoadInfo;

@end


@implementation XMGDownLoadManager

// 绝对的单例: 无论通过什么样的方式, 创建, 都是一个对象
// 非绝对的单例
static XMGDownLoadManager *_shareInstance;
+ (instancetype)shareInstance {
    
    if (!_shareInstance) {
        _shareInstance = [[XMGDownLoadManager alloc] init];
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}


- (NSMutableDictionary *)downLoadInfo {
    if (!_downLoadInfo) {
        _downLoadInfo = [NSMutableDictionary dictionary];
    }
    return _downLoadInfo;
}

- (void)downLoadWithURL: (NSURL *)url withSuccess: (DownLoadSuccessType)successBlock failed: (DownLoadFailType)failedBlock {
    
    NSString *md5 = [url.absoluteString md5Str];
    
    XMGDownLoader *downLoader = self.downLoadInfo[md5];
    if (downLoader) {
        [downLoader resume];
        return ;
    }
    downLoader = [[XMGDownLoader alloc] init];
    [self.downLoadInfo setValue:downLoader forKey:md5];
    
    __weak typeof(self) weakSelf = self;
    [downLoader downLoadWithURL:url downLoadInfo:nil success:^(NSString *cacheFilePath) {
        [weakSelf.downLoadInfo removeObjectForKey:md5];
        if(successBlock) {
            successBlock(cacheFilePath);
        }
    } failed:^{
        [weakSelf.downLoadInfo removeObjectForKey:md5];
        if (failedBlock) {
            failedBlock();
        }
    }];
    
    return ;

    
    
}

- (XMGDownLoader *)downLoadWithURL: (NSURL *)url
{
    
    // 文件名称  aaa/a.x  bb/a.x
    
    NSString *md5 = [url.absoluteString md5Str];
    
    XMGDownLoader *downLoader = self.downLoadInfo[md5];
    if (downLoader) {
        [downLoader resume];
        return downLoader;
    }
    downLoader = [[XMGDownLoader alloc] init];
    [self.downLoadInfo setValue:downLoader forKey:md5];
    
    __weak typeof(self) weakSelf = self;
    [downLoader downLoadWithURL:url downLoadInfo:nil success:^(NSString *cacheFilePath) {
        [weakSelf.downLoadInfo removeObjectForKey:md5];
    } failed:^{
        [weakSelf.downLoadInfo removeObjectForKey:md5];
    }];
    
    return downLoader;
    
}


- (void)pauseWithURL: (NSURL *)url {
    
    NSString *md5 = [url.absoluteString md5Str];
    XMGDownLoader *downLoader = self.downLoadInfo[md5];
    [downLoader pause];
    
}

- (void)cancelWithURL: (NSURL *)url {
    NSString *md5 = [url.absoluteString md5Str];
    XMGDownLoader *downLoader = self.downLoadInfo[md5];
    [downLoader cancel];
}

- (void)pauseAll {
    
    [[self.downLoadInfo allValues] makeObjectsPerformSelector:@selector(pause)];

}



@end
