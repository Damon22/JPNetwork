//
//  JPBaseRequest.m
//  JPCertificationKit
//
//  Created by Damon Gao on 2018/4/27.
//  Copyright © 2018年 Damon. All rights reserved.
//

#import "JPBaseRequest.h"
#import "JPURLSessionManager.h"
#import "JPNotificationMacro.h"

@implementation JPBaseRequest

// POST
- (void)basePostRequest:(NSString *)apiURL args:(id)args
{
    [[JPURLSessionManager sharedClient] POST:apiURL parameters:args success:^(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSError * __autoreleasing serializationError = nil;
            NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&serializationError];
            if (serializationError) {
                JPError *jpError = [[JPError alloc] init];
                jpError.error = serializationError;
                jpError.status = [NSNumber numberWithInteger:serializationError.code];
                jpError.data = serializationError.userInfo;
                jpError.info = serializationError.localizedDescription;
                id responseError = nil;
                if (result != nil && [result isKindOfClass:[NSString class]]) {
                    responseError = result;
                } else {
                    responseError = serializationError.userInfo;
                }
                NSInteger code = response.statusCode == 200 ? 0 : 2;
                if ([response.MIMEType isEqualToString:@"text/html"]) {
                    jpError.info = [JPRequestHelper requestErrorMessageWithCode:response.statusCode];
                }
                if (self.requestResponse) {
                    self.requestResponse(NO, responseError, code, jpError);
                }
            } else {
                [JPRequestHelper responseData:responseObject responseHeader:response with:^(id response, NSInteger code) {
                    if (self.requestResponse) {
                        self.requestResponse(YES, response, code, nil);
                    }
                } and:^(NSString *failReason, NSString *result, NSInteger code) {
                    JPError *jpError = [[JPError alloc] init];
                    jpError.status = [NSNumber numberWithInteger:code];
                    jpError.info = failReason;
                    if (self.requestResponse) {
                        self.requestResponse(NO, failReason, code, jpError);
                    }
                }];
            }
        } else {
            [JPRequestHelper responseData:responseObject responseHeader:response with:^(id response, NSInteger code) {
                if (self.requestResponse) {
                    self.requestResponse(YES, response, code, nil);
                }
            } and:^(NSString *failReason, NSString *result, NSInteger code) {
                JPError *jpError = [[JPError alloc] init];
                jpError.status = [NSNumber numberWithInteger:code];
                jpError.info = failReason;
                if (self.requestResponse) {
                    self.requestResponse(NO, failReason, code, jpError);
                }
            }];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response) {
        JPError *jpError = [[JPError alloc] init];
        jpError.error = error;
        jpError.status = [NSNumber numberWithInteger:error.code];
        jpError.data = error.userInfo;
        jpError.info = error.localizedDescription;
        if (self.requestResponse) {
            self.requestResponse(NO, error.userInfo, 2, jpError);
        }
    }];
}

- (void)basePostRequest:(NSString *)apiURL args:(id)args requestResponse:(RequestResponse)requestResponse
{
    [[JPURLSessionManager sharedClient] POST:apiURL parameters:args success:^(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSError * __autoreleasing serializationError = nil;
            NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&serializationError];
            if (serializationError) {
                JPError *jpError = [[JPError alloc] init];
                jpError.error = serializationError;
                jpError.status = [NSNumber numberWithInteger:serializationError.code];
                jpError.data = serializationError.userInfo;
                jpError.info = serializationError.localizedDescription;
                id responseError = nil;
                if (result != nil && [result isKindOfClass:[NSString class]]) {
                    responseError = result;
                } else {
                    responseError = serializationError.userInfo;
                }
                NSInteger code = response.statusCode == 200 ? 0 : 2;
                if ([response.MIMEType isEqualToString:@"text/html"]) {
                    jpError.info = [JPRequestHelper requestErrorMessageWithCode:response.statusCode];
                }
                if (requestResponse) {
                    requestResponse(NO, responseError, code, jpError);
                }
            } else {
                [JPRequestHelper responseData:responseObject responseHeader:response with:^(id response, NSInteger code) {
                    if (requestResponse) {
                        requestResponse(YES, response, code, nil);
                    }
                } and:^(NSString *failReason, NSString *result, NSInteger code) {
                    JPError *jpError = [[JPError alloc] init];
                    jpError.status = [NSNumber numberWithInteger:code];
                    jpError.info = failReason;
                    if (requestResponse) {
                        requestResponse(NO, failReason, code, jpError);
                    }
                }];
            }
        } else {
            [JPRequestHelper responseData:responseObject responseHeader:response with:^(id response, NSInteger code) {
                if (requestResponse) {
                    requestResponse(YES, response, code, nil);
                }
            } and:^(NSString *failReason, NSString *result, NSInteger code) {
                JPError *jpError = [[JPError alloc] init];
                jpError.status = [NSNumber numberWithInteger:code];
                jpError.info = failReason;
                if (requestResponse) {
                    requestResponse(NO, failReason, code, jpError);
                }
            }];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response) {
        JPError *jpError = [[JPError alloc] init];
        jpError.error = error;
        jpError.status = [NSNumber numberWithInteger:error.code];
        jpError.data = error.userInfo;
        jpError.info = error.localizedDescription;
        if (error.code < -1000 && error.code >= -1021) {
            // 无网络 发送广播
            [[NSNotificationCenter defaultCenter] postNotificationName:kJPNoConnectErrorNotification object:error];
        }
        if (requestResponse) {
            requestResponse(NO, error.userInfo, 2, jpError);
        }
    }];
}

// GET
- (void)baseGetRequest:(NSString *)apiURL args:(id)args
{
    [[JPURLSessionManager sharedClient] GET:apiURL parameters:args success:^(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response) {
        [JPRequestHelper responseData:responseObject responseHeader:response with:^(id response, NSInteger code) {
            if (self.requestResponse) {
                self.requestResponse(YES, response, code, nil);
            }
        } and:^(NSString *failReason, NSString *result, NSInteger code) {
            JPError *jpError = [[JPError alloc] init];
            jpError.status = [NSNumber numberWithInteger:code];
            jpError.info = failReason;
            if (self.requestResponse) {
                self.requestResponse(NO, failReason, code, jpError);
            }
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response) {
        JPError *jpError = [[JPError alloc] init];
        jpError.error = error;
        jpError.status = [NSNumber numberWithInteger:error.code];
        jpError.data = error.userInfo;
        jpError.info = error.localizedDescription;
        if (self.requestResponse) {
            self.requestResponse(NO, error.userInfo, 2, jpError);
        }
    }];
}

- (void)baseGetRequest:(NSString *)apiURL args:(id)args requestResponse:(RequestResponse)requestResponse
{
    [[JPURLSessionManager sharedClient] GET:apiURL parameters:args success:^(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response) {
        [JPRequestHelper responseData:responseObject responseHeader:response with:^(id response, NSInteger code) {
            if (requestResponse) {
                requestResponse(YES, response, code, nil);
            }
        } and:^(NSString *failReason, NSString *result, NSInteger code) {
            JPError *jpError = [[JPError alloc] init];
            jpError.status = [NSNumber numberWithInteger:code];
            jpError.info = failReason;
            if (requestResponse) {
                requestResponse(NO, failReason, code, jpError);
            }
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response) {
        JPError *jpError = [[JPError alloc] init];
        jpError.error = error;
        jpError.status = [NSNumber numberWithInteger:error.code];
        jpError.data = error.userInfo;
        jpError.info = error.localizedDescription;
        if (requestResponse) {
            requestResponse(NO, error.userInfo, 2, jpError);
        }
    }];
}

// Upload Image
/**
 上传图片(单张)
 
 @param apiURL      url
 @param args        参数
 @param pathNameArr    图片名及路径(服务器路径可不写)
 @param imageNameArr   图片名
 @param imageDataArr   图片流
 */
- (void)uploadImageRequest:(NSString *)apiURL
          uploadImagesType:(JPRequestUploadImageType)uploadType
                      args:(id)args
                  pathName:(NSArray <NSString *>*)pathNameArr
                 imageName:(NSArray <NSString *>*)imageNameArr
                 imageData:(NSArray <NSData *>*)imageDataArr
{
    NSMutableArray *imageArr = [NSMutableArray array];
    for (int i = 0; i < [imageDataArr count]; i++) {
        NSData *imageData = imageDataArr[i];
        NSString *imageName = imageNameArr[i];
        NSString *pathName = pathNameArr[i];
        JPUploadImageModel *imageModel = [[JPUploadImageModel alloc] init];
        imageModel.imageData = imageData;
        imageModel.name = imageName;
        imageModel.fileName = pathName;
        [imageArr addObject:imageModel];
    }
    
    [[JPURLSessionManager sharedClient] POST:apiURL uploadImagesType:(JPHTTPClientUploadImageType)uploadType parameters:args imageArr:imageArr success:^(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSError * __autoreleasing serializationError = nil;
            NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&serializationError];
            if (serializationError) {
                JPError *jpError = [[JPError alloc] init];
                jpError.error = serializationError;
                jpError.status = [NSNumber numberWithInteger:serializationError.code];
                jpError.data = serializationError.userInfo;
                jpError.info = serializationError.localizedDescription;
                id responseError = nil;
                if (result != nil && [result isKindOfClass:[NSString class]]) {
                    responseError = result;
                } else {
                    responseError = serializationError.userInfo;
                }
                NSInteger code = response.statusCode == 200 ? 0 : 2;
                if ([response.MIMEType isEqualToString:@"text/html"]) {
                    jpError.info = [JPRequestHelper requestErrorMessageWithCode:response.statusCode];
                }
                if (self.requestResponse) {
                    self.requestResponse(NO, responseError, code, jpError);
                }
            } else {
                [JPRequestHelper responseData:responseObject responseHeader:response with:^(id response, NSInteger code) {
                    if (self.requestResponse) {
                        self.requestResponse(YES, response, code, nil);
                    }
                } and:^(NSString *failReason, NSString *result, NSInteger code) {
                    JPError *jpError = [[JPError alloc] init];
                    jpError.status = [NSNumber numberWithInteger:code];
                    jpError.info = failReason;
                    if (self.requestResponse) {
                        self.requestResponse(NO, failReason, code, jpError);
                    }
                }];
            }
        } else {
            [JPRequestHelper responseData:responseObject responseHeader:response with:^(id response, NSInteger code) {
                if (self.requestResponse) {
                    self.requestResponse(YES, response, code, nil);
                }
            } and:^(NSString *failReason, NSString *result, NSInteger code) {
                JPError *jpError = [[JPError alloc] init];
                jpError.status = [NSNumber numberWithInteger:code];
                jpError.info = failReason;
                if (self.requestResponse) {
                    self.requestResponse(NO, failReason, code, jpError);
                }
            }];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response) {
        JPError *jpError = [[JPError alloc] init];
        jpError.error = error;
        jpError.status = [NSNumber numberWithInteger:error.code];
        jpError.data = error.userInfo;
        jpError.info = error.localizedDescription;
        if (self.requestResponse) {
            self.requestResponse(NO, error.userInfo, 2, jpError);
        }
    }];
}

- (void)uploadImageRequest:(NSString *)apiURL
          uploadImagesType:(JPRequestUploadImageType)uploadType
                      args:(id)args
                  pathName:(NSArray <NSString *>*)pathNameArr
                 imageName:(NSArray <NSString *>*)imageNameArr
                 imageData:(NSArray <NSData *>*)imageDataArr
           requestResponse:(RequestResponse)requestResponse
{
    NSMutableArray *imageArr = [NSMutableArray array];
    for (int i = 0; i < [imageDataArr count]; i++) {
        NSData *imageData = imageDataArr[i];
        NSString *imageName = imageNameArr[i];
        NSString *pathName = pathNameArr[i];
        JPUploadImageModel *imageModel = [[JPUploadImageModel alloc] init];
        imageModel.imageData = imageData;
        imageModel.name = imageName;
        imageModel.fileName = pathName;
        [imageArr addObject:imageModel];
    }
    
    [[JPURLSessionManager sharedClient] POST:apiURL uploadImagesType:(JPHTTPClientUploadImageType)uploadType parameters:args imageArr:imageArr success:^(NSURLSessionDataTask *task, id responseObject, NSHTTPURLResponse *response) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSError * __autoreleasing serializationError = nil;
            NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&serializationError];
            if (serializationError) {
                JPError *jpError = [[JPError alloc] init];
                jpError.error = serializationError;
                jpError.status = [NSNumber numberWithInteger:serializationError.code];
                jpError.data = serializationError.userInfo;
                jpError.info = serializationError.localizedDescription;
                id responseError = nil;
                if (result != nil && [result isKindOfClass:[NSString class]]) {
                    responseError = result;
                } else {
                    responseError = serializationError.userInfo;
                }
                NSInteger code = response.statusCode == 200 ? 0 : 2;
                if ([response.MIMEType isEqualToString:@"text/html"]) {
                    jpError.info = [JPRequestHelper requestErrorMessageWithCode:response.statusCode];
                }
                if (requestResponse) {
                    requestResponse(NO, responseError, code, jpError);
                }
            } else {
                [JPRequestHelper responseData:responseObject responseHeader:response with:^(id response, NSInteger code) {
                    if (requestResponse) {
                        requestResponse(YES, response, code, nil);
                    }
                } and:^(NSString *failReason, NSString *result, NSInteger code) {
                    JPError *jpError = [[JPError alloc] init];
                    jpError.status = [NSNumber numberWithInteger:code];
                    jpError.info = failReason;
                    if (requestResponse) {
                        requestResponse(NO, failReason, code, jpError);
                    }
                }];
            }
        } else {
            [JPRequestHelper responseData:responseObject responseHeader:response with:^(id response, NSInteger code) {
                if (requestResponse) {
                    requestResponse(YES, response, code, nil);
                }
            } and:^(NSString *failReason, NSString *result, NSInteger code) {
                JPError *jpError = [[JPError alloc] init];
                jpError.status = [NSNumber numberWithInteger:code];
                jpError.info = failReason;
                if (requestResponse) {
                    requestResponse(NO, failReason, code, jpError);
                }
            }];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error, NSURLResponse *response) {
        JPError *jpError = [[JPError alloc] init];
        jpError.error = error;
        jpError.status = [NSNumber numberWithInteger:error.code];
        jpError.data = error.userInfo;
        jpError.info = error.localizedDescription;
        if (requestResponse) {
            requestResponse(NO, error.userInfo, 2, jpError);
        }
    }];
}

@end
