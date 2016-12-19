//
//  XMGDownLoadManager.h
//  XMGDownLoadLib
//
//  Created by 小码哥 on 2016/11/27.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMGDownLoader.h"

@interface XMGDownLoadManager : NSObject

+ (instancetype)shareInstance;

- (XMGDownLoader *)downLoadWithURL: (NSURL *)url;

- (void)downLoadWithURL: (NSURL *)url withSuccess: (DownLoadSuccessType)successBlock failed: (DownLoadFailType)failedBlock;

- (void)pauseWithURL: (NSURL *)url;

- (void)cancelWithURL: (NSURL *)url;

- (void)pauseAll;

@end
