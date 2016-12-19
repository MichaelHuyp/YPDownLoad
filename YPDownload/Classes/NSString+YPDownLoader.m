//
//  NSString+YPDownLoader.m
//  YPDownLoader
//
//  Created by 胡云鹏 on 2016/12/16.
//  Copyright © 2016年 yongche. All rights reserved.
//

#import "NSString+YPDownLoader.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (YPDownLoader)

- (NSString *)yp_MD5Str
{
    const char *data = self.UTF8String;
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(data, (CC_LONG)strlen(data), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}

@end
