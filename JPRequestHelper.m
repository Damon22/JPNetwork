//
//  JPRequestHelper.m
//  JPCertificationKit
//
//  Created by Damon Gao on 2018/4/27.
//  Copyright © 2018年 Damon. All rights reserved.
//

#import "JPRequestHelper.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import "JPDebugMacro.h"

@implementation JPError

@synthesize status = _status;
- (void)setStatus:(NSNumber *)status
{
    _status = status;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ : %p>{code:%@ msg:%@ data:%@}", NSStringFromClass([self class]), self, self.status, self.info, self.data];
}

@end



#pragma mark -

@interface JPRequestHelper ()

@end

@implementation JPRequestHelper

+ (instancetype)shareInstance {
    static JPRequestHelper *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [[JPRequestHelper alloc] init];
        }
    });
    return _instance;
}

/** 处理返回的数据 */
+ (void)responseData:(id)responseData
      responseHeader:(NSHTTPURLResponse *)response
                with:(JPResponeSuccess)success
                 and:(JPResponeFailure)failure
{
    // 判断请求返回
    if (response.statusCode != 200) {
        NSString *errorMsg;
        NSString *errorInfo = responseData;
        if ([errorInfo isKindOfClass:[NSString class]] &&
            [errorInfo containsString:@"{"]) {
            errorMsg = @"原始数据";
        } else {
            errorInfo = @"";
            errorMsg = [self requestErrorMessageWithCode:response.statusCode];
        }
        
        if (failure) {
            failure(errorMsg, errorInfo, 2);
        }
        return;
    }
    
    
    NSString *msg = [[responseData objectForKey:@"msg"] isKindOfClass:[NSNull class]] ? @"" : [responseData objectForKey:@"msg"];
    id data = [responseData objectForKey:@"result"];
    if (data == nil) {
        data = [responseData objectForKey:@"data"];
    }
    if ([data isEqual:[NSNull null]]) {
        if (msg) {
            data = msg;
        } else {
            data = @"";
        }
    }
    if (!data) {
        data = @"服务器数据异常";
    }
    id codeOrigin = [responseData objectForKey:@"code"];
    NSInteger code;
    if ([codeOrigin isEqual:[NSNull null]]) {
        code = 1005;
    } else {
        code = [codeOrigin integerValue];
    }
    
    switch (code) {
        case 200:   // 成功(图片)
        case 0000:  // 成功(总线)
        {
            if (success) {
                success(data, 1);
            }
            return;
        }
            break;
        case 403:   // 无权限
        case 500:   // 服务器错误/token失效
        {
            if (failure) {
                failure(msg, data, code);
            }
            return;
        }
            break;
            
        default:
            if (failure) {
                failure(msg, data, 0);
            }
            break;
    }
}

+ (NSString *)requestErrorMessageWithCode:(NSInteger)code
{
    NSString *errorMsg = @"";
    switch (code) {
        case 403:
            errorMsg = @"无访问服务器权限 403 ";
            break;
        case 404:
            errorMsg = @"无法访问服务器 404 ";
            break;
        case 500:
            errorMsg = @"服务器内部错误 500 ";
            break;
        case 503:
            errorMsg = @"后台服务不可用 503 ";
            break;
        case 504:
            errorMsg = @"服务器异常 504 ";
            break;
        default:
            errorMsg = @"服务器异常";
            break;
    }
    return errorMsg;
}

/** 处理错误信息 */
+ (void)handleError:(id)error with:(JPResponeFailure)failure
{
    if ([error isKindOfClass:[NSError class]]) {
        NSInteger code = ((NSError *)error).code;
        if (code == 404) {
            if (failure) {
                failure(@"页面错误", @"", code);
            }
            return;
        }
        if (failure) {
            failure(((NSError *)error).description, @"", code);
        }
    }
}

// 检测网络是否联通
+ (BOOL)isConnectionAvailable {
    /**
     //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
     struct sockaddr_in zeroAddress;
     bzero(&zeroAddress, sizeof(zeroAddress));
     zeroAddress.sin_len = sizeof(zeroAddress);
     zeroAddress.sin_family = AF_INET;
     
     // Recover reachability flags
     SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
     */
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithName(NULL, [@"www.apple.com" UTF8String]);
    SCNetworkReachabilityFlags flags;
    //获得连接的标志
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    //如果不能获取连接标志，则不能连接网络，直接返回
    if (!didRetrieveFlags)
    {
        JPLog(@"JPSDK -> JPError. Could not recover network reachability flags");
        return NO;
    }
    //根据获得的连接标志进行判断
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}

@end
