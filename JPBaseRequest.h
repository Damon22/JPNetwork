//
//  JPBaseRequest.h
//  JPCertificationKit
//
//  Created by Damon Gao on 2018/4/27.
//  Copyright © 2018年 Damon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPRequestHelper.h"

typedef void(^RequestResponse)(BOOL isSuccess, id responseObject, NSInteger code, JPError *error);

typedef NS_ENUM(NSInteger, JPRequestUploadImageType) {
    JPRequestUploadImageTypeNone = 0,
    JPRequestUploadImageTypeSingle,
    JPRequestUploadImageTypeMulti
};

@interface JPBaseRequest : NSObject

@property (nonatomic, copy) RequestResponse requestResponse;

// POST
- (void)basePostRequest:(NSString *)apiURL args:(id)args;
- (void)basePostRequest:(NSString *)apiURL args:(id)args requestResponse:(RequestResponse)requestResponse;

// GET
- (void)baseGetRequest:(NSString *)apiURL args:(id)args;
- (void)baseGetRequest:(NSString *)apiURL args:(id)args requestResponse:(RequestResponse)requestResponse;

// Upload Image
/**
 上传图片(单张)

 @param apiURL      url
 @param uploadType  单张/多张类型
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
                 imageData:(NSArray <NSData *>*)imageDataArr;
- (void)uploadImageRequest:(NSString *)apiURL
          uploadImagesType:(JPRequestUploadImageType)uploadType
                      args:(id)args
                  pathName:(NSArray <NSString *>*)pathNameArr
                 imageName:(NSArray <NSString *>*)imageNameArr
                 imageData:(NSArray <NSData *>*)imageDataArr
           requestResponse:(RequestResponse)requestResponse;

@end
