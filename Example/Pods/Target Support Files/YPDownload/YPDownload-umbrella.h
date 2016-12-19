#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSString+YPDownLoader.h"
#import "YPDownLoader.h"
#import "YPDownLoaderFileManager.h"
#import "YPDownLoadManager.h"

FOUNDATION_EXPORT double YPDownloadVersionNumber;
FOUNDATION_EXPORT const unsigned char YPDownloadVersionString[];

