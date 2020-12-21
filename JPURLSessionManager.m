//
//  JPURLSessionManager.m
//  JPCertificationKit
//
//  Created by Damon Gao on 2018/4/23.
//  Copyright © 2018年 Damon. All rights reserved.
//

#import "JPURLSessionManager.h"
#import "JPNetworkConfig.h"
#import "JPDebugMacro.h"
#import <UIKit/UIKit.h>
#import "JPBasicUtil.h"

@implementation JPUploadImageModel

@end


#pragma mark -
@interface JPURLSessionManager () <NSURLSessionDelegate>

/** 接受到的数据Data */
@property (nonatomic, strong) JPNetworkConfig *requestConfig;

@end

@implementation JPURLSessionManager

#pragma mark - Public Methods
+ (instancetype)sharedClient {
    static JPURLSessionManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [JPURLSessionManager client];
    });
    return sharedManager;
}

+ (instancetype)client {
    JPURLSessionManager *client = [[JPURLSessionManager alloc] init];
    client.requestConfig = [JPNetworkConfig sharedConfig];
    return client;
}

#pragma mark - Get
/// 无缓存 默认超时时间30s 可以设置。
- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response))failure
{
    return [self requestMethod:JPHTTPClientRequestTypeGET urlString:URLString parameters:parameters timeoutInterval:30 success:success failure:failure];
}

/// 可以自由设置超时时间。
- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
              timeoutInterval:(NSTimeInterval)timeoutInterval
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response))failure
{
    NSString *url = nil;
    if ([parameters isKindOfClass:[NSString class]]) {
        url = [NSString stringWithFormat:@"%@?%@", URLString, parameters];
    } else {
        NSMutableString *str = [NSMutableString stringWithString:@""];
        for (NSString *key in (NSDictionary *)parameters) {
            [str appendFormat:@"%@=%@&",key,[parameters objectForKey:key]];
        }
        if ([str length] > 1) {
            [str deleteCharactersInRange:NSMakeRange((str.length-1), 1)];
        }
        url = [NSString stringWithFormat:@"%@?%@", URLString, [str copy]];
    }
    return [self requestMethod:JPHTTPClientRequestTypeGET urlString:url parameters:parameters timeoutInterval:timeoutInterval success:success failure:failure];
}


#pragma mark - Post
/// 无缓存 默认超时时间30s 可以设置。
- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response))failure
{
    return [self requestMethod:JPHTTPClientRequestTypePOST urlString:URLString parameters:parameters timeoutInterval:30 success:success failure:failure];
}

/// 可以自由设置超时时间，缓存方式。
- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
               timeoutInterval:(NSTimeInterval)timeoutInterval
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response))failure
{
    return [self requestMethod:JPHTTPClientRequestTypePOST urlString:URLString parameters:parameters timeoutInterval:timeoutInterval success:success failure:failure];
}


#pragma mark - Custom
/// 默认 自定义请求方式 默认超时时间30s
- (NSURLSessionDataTask *)customHTTPMethod:(JPHTTPClientRequestType)requestType
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters
                                   success:(void (^)(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response))success
                                   failure:(void (^)(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response))failure
{
    return [self requestMethod:requestType urlString:URLString parameters:parameters timeoutInterval:30 success:success failure:failure];
}

/// 默认 可以自由设置超时时间。
- (NSURLSessionDataTask *)customHTTPMethod:(JPHTTPClientRequestType)requestType
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters
                           timeoutInterval:(NSTimeInterval)timeoutInterval
                                   success:(void (^)(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response))success
                                   failure:(void (^)(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response))failure
{
    return [self requestMethod:requestType urlString:URLString parameters:parameters timeoutInterval:timeoutInterval success:success failure:failure];
}


#pragma mark - Private
- (NSURLSessionDataTask *)requestMethod:(JPHTTPClientRequestType)requestType
                              urlString:(NSString *)URLString
                             parameters:(id)parameters
                        timeoutInterval:(NSTimeInterval)timeoutInterval
                                success:(void (^)(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response))success
                                failure:(void (^)(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response))failure
{
    URLString = URLString.length >= 1 ? URLString : @"";
    if (URLString.length == 0) return nil;
    
    if (parameters) {
        if ([parameters isKindOfClass:[NSString class]] && [JPBasicUtil idFromJsonString:parameters]) {
            id params = [JPBasicUtil idFromJsonString:parameters];
            if (![NSJSONSerialization isValidJSONObject:params]) return nil;//参数不是json类型
            return [self dataTaskWith:requestType urlString:URLString parameters:params timeoutInterval:timeoutInterval success:success failure:failure];
        }
    } else {
        parameters = @{};
    }
    return [self dataTaskWith:requestType urlString:URLString parameters:parameters timeoutInterval:timeoutInterval success:success failure:failure];
}

- (NSURLSessionDataTask *)dataTaskWith:(JPHTTPClientRequestType)requestType
                             urlString:(NSString *)URLString
                            parameters:(id)parameters
                       timeoutInterval:(NSTimeInterval)timeoutInterval
                               success:(void (^)(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse * response))success
                               failure:(void (^)(NSURLSessionDataTask *task, NSError *error, NSURLResponse * response))failure
{
    [self.requestConfig setTimeoutInterval:timeoutInterval];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [request setHTTPMethod:[self method][requestType]];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    [request setHTTPBody:jsonData];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.requestConfig.sessionConfiguration delegate:[JPURLSessionManager new] delegateQueue:[NSOperationQueue mainQueue]];
    __block NSURLSessionDataTask *dataTask = [session uploadTaskWithRequest:request fromData:jsonData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        JPLog(@"JPSDK -> Request.Result:%@\n%@\n%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], res.allHeaderFields,[response MIMEType]);
        if (error) {
            if (failure) {
                failure(dataTask, error, response);
            }
        } else {
            if (success) {
                success(dataTask, data, res);
            }
        }
    }];
    [dataTask resume];
    return dataTask;
}

/// 上传图片
- (NSURLSessionDataTask *)POST:(NSString *)URLString
              uploadImagesType:(JPHTTPClientUploadImageType)uploadType
                    parameters:(id)parameters
                      imageArr:(NSArray <JPUploadImageModel *>*)imageArr
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse * response))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error, NSURLResponse * response))failure
{
    [self.requestConfig setTimeoutInterval:30];
    
    NSString *uploadImageBoundary = JPCreateUploadImageBoundary();
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:URLString]];
    [request setHTTPMethod:@"POST"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    [request setHTTPBody:jsonData];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data;charset=utf-8; boundary=%@", uploadImageBoundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *requestBody = [[NSMutableData alloc] init];
    if ([parameters count] > 0) {
        NSDictionary *paraDic = (NSDictionary *)parameters;
        [requestBody appendData:[[NSString stringWithFormat:@"--%@\r\n", uploadImageBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        for (int i=0; i<[paraDic.allKeys count]; i++) {
            NSString *key = paraDic.allKeys[i];
            NSString *value = paraDic.allValues[i];
            // Image File Data
            [requestBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [requestBody appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
            [requestBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [requestBody appendData:[[NSString stringWithFormat:@"--%@\r\n", uploadImageBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    } else {
        requestBody = nil;
    }
    
    NSData *fromData = [self getFormalImageData:imageArr uploadImagesType:uploadType paramData:requestBody boundary:uploadImageBoundary];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.requestConfig.sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    __block NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:fromData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        if (error) {
            if (failure) {
                failure(task, error, response);
            }
        } else {
            if (success) {
                success(task, data, res);
            }
        }
    }];
    
    [task resume];
    
    return task;
}

static NSString * JPCreateUploadImageBoundary() {
    return [NSString stringWithFormat:@"Boundary+%08X%08X", arc4random(), arc4random()];
}

- (NSData *)getFormalImageData:(NSArray <JPUploadImageModel *>*)imageArr
              uploadImagesType:(JPHTTPClientUploadImageType)uploadType
                     paramData:(NSData *)paramData
                      boundary:(NSString *)uploadImageBoundary
{
    NSMutableData *requestBody = [[NSMutableData alloc] init];
    if (paramData && paramData.length > 0) {
        [requestBody appendData:paramData];
    } else {
        [requestBody appendData:[[NSString stringWithFormat:@"--%@\r\n", uploadImageBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    for (int i=0; i<[imageArr count]; i++) {
        JPUploadImageModel *model = imageArr[i];
        NSString *contentName;
        if (uploadType == JPHTTPClientUploadImageTypeNone) {
            // 根据数量判断
            contentName = [imageArr count] > 1 ? @"imgFileList" : @"imgFile";
        } else if (uploadType == JPHTTPClientUploadImageTypeSingle) {
            // 单张类型
            contentName = @"imgFile";
        } else {
            // 多张类型
            contentName = @"imgFileList";
        }
        // Image File Data
        [requestBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n", contentName, model.name] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [requestBody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [requestBody appendData:[NSData dataWithData:model.imageData]];
        [requestBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        if (i == [imageArr count]-1) {
            [requestBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", uploadImageBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            [requestBody appendData:[[NSString stringWithFormat:@"--%@\r\n", uploadImageBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    return requestBody;
}


#pragma mark NSURLSessionDelegate
// 域名更改时查看证书是否授权
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
{
    if (!challenge) {
        return;
    }
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;
    
    /*
     * Gets the host name
     */
    
    NSString * host = [[task.currentRequest allHTTPHeaderFields] objectForKey:@"Host"];
    if (!host) {
        host = task.currentRequest.URL.host;
    }
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([self evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:host]) {
            disposition = NSURLSessionAuthChallengeUseCredential;
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        }
    } else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    // Uses the default evaluation for other challenges.
    completionHandler(disposition,credential);
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    
}


#pragma mark - Private Methods
// 在更改域名时,证书是否信任 (可以默认为NO,即不处理)
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain {
    /*
     * Creates the policies for certificate verification.
     */
    NSMutableArray *policies = [NSMutableArray array];
    if (domain) {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
    } else {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
    }
    
    /*
     * Sets the policies to server's certificate
     */
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
    
    
    /*
     * Evaulates if the current serverTrust is trustable.
     * It's officially suggested that the serverTrust could be passed when result = kSecTrustResultUnspecified or kSecTrustResultProceed.
     * For more information checks out https://developer.apple.com/library/ios/technotes/tn2232/_index.html
     * For detail information about SecTrustResultType, checks out SecTrust.h
     */
    SecTrustResultType result;
    SecTrustEvaluate(serverTrust, &result);
    
    return (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
}

- (NSArray *)method {
    /**
     DMHTTPClientRequestTypeGET = 0,
     DMHTTPClientRequestTypePOST,
     DMHTTPClientRequestTypePUT,
     DMHTTPClientRequestTypeHEAD,
     DMHTTPClientRequestTypeDELETE,
     DMHTTPClientRequestTypePATCH
     */
    return @[@"GET",@"POST",@"PUT",@"HEAD",@"DELETE",@"PATCH"];
}

@end
