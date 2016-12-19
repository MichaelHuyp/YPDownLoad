//
//  YPDownLoader.m
//  YPDownLoader
//
//  Created by 胡云鹏 on 2016/12/6.
//  Copyright © 2016年 yongche. All rights reserved.
//

#import "YPDownLoader.h"
#import "NSString+YPDownLoader.h"
#import "YPDownLoaderFileManager.h"

#define kTemp NSTemporaryDirectory()
#define kCache NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject

@interface YPDownLoader () <NSURLSessionDataDelegate>
{
    // 文件的总大小
    long long _totalFileSize;
 
    // 临时文件大小
    long long _tempFileSize;
}

/** 下载会话 */
@property (nonatomic, strong) NSURLSession *session;

/** 下载任务 */
@property (nonatomic, weak) NSURLSessionDataTask *task;

/** 文件输出流 */
@property (nonatomic, strong) NSOutputStream *outputStream;

/** 临时文件路径 */
@property (nonatomic, copy) NSString *tempFilePath;

/** 文件的缓存路径 */
@property (nonatomic, copy) NSString *cacheFilePath;

/** 下载进度 */
@property (nonatomic, strong) NSProgress *downloadProgress;

@property (nonatomic, copy) void(^successBlock)(NSString *cacheFilePath);

@property (nonatomic, copy) void(^failureBlock)(NSError *error);

@property (nonatomic, copy) void (^downloadProgressBlock)(NSProgress *downloadProgress);

@end

@implementation YPDownLoader

#pragma mark - Public
- (void)resume
{
    if (self.state == YPDownLoaderStatePause) {
        [self.task resume];
        self.state = YPDownLoaderStateDowning;
    }
}

- (void)pause {
    if (self.state == YPDownLoaderStateDowning)
    {
        [self.task suspend];
        self.state = YPDownLoaderStatePause;
    }
}

- (void)cancelAndClearCache
{
    [self cancel];
    
    [YPDownLoaderFileManager removeFileAtPath:self.tempFilePath];
}




- (void)downLoadWithURL:(NSURL *)url downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock success:(nullable void(^)(NSString *cacheFilePath))successBlock failure:(nullable void(^)(NSError *error))failureBlock
{
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    self.downloadProgressBlock = downloadProgressBlock;
    
    [self downLoadWithURL:url];
}


#pragma mark - Life Cycle
- (void)dealloc {
    // 移除下载,上传进度的监听
    [self.downloadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
}

#pragma mark - NSProgress Tracking

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([object isEqual:self.downloadProgress]) {
        if (self.downloadProgressBlock) {
            // 回调下载进度block
            self.downloadProgressBlock(object);
        }
    }
}

#pragma mark - Private

- (void)downLoadWithURL:(NSURL *)url
{
    self.tempFilePath = [kTemp stringByAppendingPathComponent:[url.absoluteString yp_MD5Str]];
    self.cacheFilePath = [kCache stringByAppendingPathComponent:url.lastPathComponent];
    self.downloadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    
    [self.downloadProgress addObserver:self
                            forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                               options:NSKeyValueObservingOptionNew
                               context:NULL];
    
    
    // 1.首先判断本地有没有下载好,如果下载好了 直接返回文件信息
    if ([YPDownLoaderFileManager isFileExists:self.cacheFilePath]) {
        NSLog(@"文件已经下载完毕,需要返回文件路径,文件的信息");
        self.state = YPDownLoaderStateSuccess;
        
        return;
    }
    
    // 2.如果没有下载好,判断当前任务是否存在
    if ([url isEqual:self.task.originalRequest.URL]) {
        // 2.1 任务存在 -> 判断当前下载状态
        if (self.state == YPDownLoaderStateDowning) {
            // 2.1.1 当前正在下载-> 直接return
            return;
        }
        
        if (self.state == YPDownLoaderStatePause) {
            // 2.1.2 当前处于暂停状态 -> 恢复下载任务
            [self resume];
            return;
        }
        
        // 其他状态,如下载失败
    }
    
    
    // 2.2 任务不存在或下载失败,取消当前session,然后读取本地缓存的文件的大小,从缓存大小的进度开始下载
    [self cancel];
    
    // 读取本地缓存大小
    _tempFileSize = [YPDownLoaderFileManager fileSizeWithPath:self.tempFilePath];
    
    
    // 开始下载
    [self downLoadWithURL:url offset:_tempFileSize];
}


- (void)downLoadWithURL:(NSURL *)url offset:(long long)offset
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    [task resume];
    self.task = task;
}

- (void)cancel
{
    [self.session invalidateAndCancel];
    self.session = nil;
}

#pragma mark - NSURLSessionDataDelegate
/**
 当发送的请求, 第一次接受到响应的时候调用,
 
 @param completionHandler 系统传递给我们的一个回调代码块, 我们可以通过这个代码块, 来告诉系统,如何处理, 接下来的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSLog(@"接受到响应");
    
    // 拿到文件总大小
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    _totalFileSize = [httpResponse.allHeaderFields[@"Content-Length"] longLongValue];
    if (httpResponse.allHeaderFields[@"Content-Range"]) {
        // bytes 0-21574061/21574062
        NSString *rangeStr = httpResponse.allHeaderFields[@"Content-Range"];
        _totalFileSize = [[[rangeStr componentsSeparatedByString:@"/"] lastObject] longLongValue];
    }
    
    self.downloadProgress.totalUnitCount = _totalFileSize;
    
    
    // 对比本地缓存大小和文件总大小
    
    // 如果本地缓存大小 == 文件总大小 说明下载完成 -> 将临时路径下的文件移动到cache路径下
    if (_tempFileSize == _totalFileSize) {
        NSLog(@"文件已经下载完成,移动数据");
        [YPDownLoaderFileManager moveFile:self.tempFilePath toPath:self.cacheFilePath];
        self.state = YPDownLoaderStateSuccess;
        // 取消请求
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    
    
    // 临时文件大小大于文件总大小 说明下载出错了
    if (_tempFileSize > _totalFileSize) {
        NSLog(@"缓存有问题,删除缓存,重新下载");
        // 删除缓存
        [YPDownLoaderFileManager removeFileAtPath:self.tempFilePath];
        
        // 取消请求
        completionHandler(NSURLSessionResponseCancel);
        
        // 重新发送请求 从0 开始
        [self downLoadWithURL:response.URL offset:0];
        
        return;
    }
    
    // 来到这里 继续接收数据
    self.state = YPDownLoaderStateDowning;
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tempFilePath append:YES];
    [self.outputStream open];
    
    completionHandler(NSURLSessionResponseAllow);
}

/**
 *  接收数据的时候调用
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    // 进度 = 当前下载的文件大小 / 总大小
    _tempFileSize += data.length;
    self.downloadProgress.completedUnitCount = _tempFileSize;
    [self.outputStream write:data.bytes maxLength:data.length];
}


/**
 *  下载完成的时候调用
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self.outputStream close];
    self.outputStream = nil;
    
    if (!error) {
        NSLog(@"下载完毕,成功");
        [YPDownLoaderFileManager moveFile:self.tempFilePath toPath:self.cacheFilePath];
        self.state = YPDownLoaderStateSuccess;
    } else {
        NSLog(@"有错误");
        self.state = YPDownLoaderStateFailed;
        if(self.failureBlock) {
            self.failureBlock(error);
        }
    }

}

#pragma mark - Lazy

- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}


- (void)setState:(YPDownLoaderState)state
{
    if (_state == state) return;
    
    _state = state;
    
    if (state == YPDownLoaderStateSuccess && self.successBlock) {
        self.successBlock(self.cacheFilePath);
    }
    
}

@end







































































