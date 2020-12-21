//
//  JPURLSessionManager.h
//  JPCertificationKit
//
//  Created by Damon Gao on 2018/4/23.
//  Copyright © 2018年 Damon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPUploadImageModel : NSObject

@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fileName;

@end



#pragma mark -

/** 请求类型 */
typedef NS_ENUM(NSUInteger, JPHTTPClientRequestType) {
    JPHTTPClientRequestTypeGET = 0,
    JPHTTPClientRequestTypePOST,
    JPHTTPClientRequestTypePUT,
    JPHTTPClientRequestTypeHEAD,
    JPHTTPClientRequestTypeDELETE,
    JPHTTPClientRequestTypePATCH
};

/** 上传单张/多张图片类型 */
typedef NS_ENUM(NSUInteger, JPHTTPClientUploadImageType) {
    /** 不确定是上传单张或多张图片(按图片张数自动选择) */
    JPHTTPClientUploadImageTypeNone = 0,
    /** 固定上传单张图片 */
    JPHTTPClientUploadImageTypeSingle,
    /** 固定上传多张图片 */
    JPHTTPClientUploadImageTypeMulti
};

@interface JPURLSessionManager : NSObject <NSURLSessionDelegate>

+ (instancetype)sharedClient;

#pragma mark - Get
/// 无缓存 默认超时时间30s 可以设置。
- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response))failure;

/// 可以自由设置超时时间。
- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
              timeoutInterval:(NSTimeInterval)timeoutInterval
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response))failure;


#pragma mark - Post
/// 无缓存 默认超时时间30s 可以设置。
- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response))failure;

/// 可以自由设置超时时间，缓存方式。
- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
               timeoutInterval:(NSTimeInterval)timeoutInterval
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response))failure;

/// 图片
/// 上传图片
- (NSURLSessionDataTask *)POST:(NSString *)URLString
              uploadImagesType:(JPHTTPClientUploadImageType)uploadType
                    parameters:(id)parameters
                      imageArr:(NSArray <JPUploadImageModel *>*)imageArr
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response))failure;


#pragma mark - Custom
/// 默认 自定义请求方式 默认超时时间30s
- (NSURLSessionDataTask *)customHTTPMethod:(JPHTTPClientRequestType)requestType
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters
                                   success:(void (^)(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response))success
                                   failure:(void (^)(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response))failure;

/// 默认 可以自由设置超时时间。
- (NSURLSessionDataTask *)customHTTPMethod:(JPHTTPClientRequestType)requestType
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters
                           timeoutInterval:(NSTimeInterval)timeoutInterval
                                   success:(void (^)(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response))success
                                   failure:(void (^)(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response))failure;


@end
