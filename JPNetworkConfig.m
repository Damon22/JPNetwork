//
//  JPNetworkConfig.m
//  JPCertificationKit
//
//  Created by Damon Gao on 2018/4/26.
//  Copyright © 2018年 Damon. All rights reserved.
//

#import "JPNetworkConfig.h"

@implementation JPNetworkConfig

#pragma mark - Public
+ (JPNetworkConfig *)sharedConfig {
    static JPNetworkConfig *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

/**
 text/html  ：HTML格式
 text/plain ：纯文本格式
 text/xml   ：XML格式
 image/gif  ：gif图片格式
 image/jpeg ：jpg图片格式
 image/png  ：png图片格式
 */

/**
 application/xhtml+xml  ：   XHTML格式
 application/xml        ：   XML数据格式
 application/atom+xml   ：   Atom XML聚合格式
 application/json       ：   JSON数据格式
 application/pdf        ：   pdf格式
 application/msword     ：   Word文档格式
 application/octet-stream ： 二进制流数据（如常见的文件下载）
 application/x-www-form-urlencoded ： <form encType=””>中默认的encType，form表单数据被编码为key/value格式发送到服务器（表单默认的提交数据的格式）
 */

/**
 multipart/form-data ： 需要在表单中进行文件上传时，就需要使用该格式
 */

- (instancetype)init {
    if (self = [super init]) {
        _baseUrl = @"";
        _sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionConfiguration.timeoutIntervalForRequest = 30;
        _timeoutInterval = 30;
        // 忽略请求缓存
        _sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        NSMutableDictionary *mutableRequestHeaders = [NSMutableDictionary dictionary];
        //application/x-www-form-urlencoded
        [mutableRequestHeaders setObject:@"text/plain;charset=UTF-8, application/json;charset=UTF-8" forKey:@"Content-Type"];
        [mutableRequestHeaders setObject:@"application/json,application/xml,application/xhtml+xml,text/html;q=0.9,image/webp,*/*;q=0.8" forKey:@"Accept"];
        // 语言
        NSMutableArray *acceptLanguagesComponents = [NSMutableArray array];
        [[NSLocale preferredLanguages] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            float q = 1.0f - (idx * 0.1f);
            [acceptLanguagesComponents addObject:[NSString stringWithFormat:@"%@;q=%0.1g", obj, q]];
            *stop = q <= 0.5f;
        }];
        [mutableRequestHeaders setObject:[acceptLanguagesComponents componentsJoinedByString:@", "] forKey:@"Accept-Language"];
        // 机型
        NSString *userAgent = nil;
#if TARGET_OS_IOS
        // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
        userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
#elif TARGET_OS_WATCH
        // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
        userAgent = [NSString stringWithFormat:@"%@/%@ (%@; watchOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[WKInterfaceDevice currentDevice] model], [[WKInterfaceDevice currentDevice] systemVersion], [[WKInterfaceDevice currentDevice] screenScale]];
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
        userAgent = [NSString stringWithFormat:@"%@/%@ (Mac OS X %@)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[NSProcessInfo processInfo] operatingSystemVersionString]];
#endif
        if (userAgent) {
            if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
                NSMutableString *mutableUserAgent = [userAgent mutableCopy];
                if (CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false)) {
                    userAgent = mutableUserAgent;
                }
            }
            [mutableRequestHeaders setObject:userAgent forKey:@"User-Agent"];
        }
        _sessionConfiguration.HTTPAdditionalHeaders = mutableRequestHeaders;
    }
    return self;
}

#pragma mark - Lazy
- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
    _timeoutInterval = timeoutInterval;
    _sessionConfiguration.timeoutIntervalForRequest = timeoutInterval;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p>{ baseURL: %@ }", NSStringFromClass([self class]), self, self.baseUrl];;
}

@end
