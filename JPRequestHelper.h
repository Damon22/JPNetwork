//
//  JPRequestHelper.h
//  JPCertificationKit
//
//  Created by Damon Gao on 2018/4/27.
//  Copyright © 2018年 Damon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPError : NSObject

/** error */
@property (nonatomic, strong) NSError *error;
/** 状态码 */
@property (nonatomic, strong) NSNumber *status;
/** 提示信息 */
@property (nonatomic, strong) NSString *info;
/** 错误data */
@property (nonatomic, strong) NSDictionary *data;

@end



#pragma mark -

typedef void(^JPResponeSuccess)(id response, NSInteger code);
typedef void(^JPResponeFailure)(NSString *failReason, NSString *result, NSInteger code);

@interface JPRequestHelper : NSObject

/** 处理返回的数据 */
+ (void)responseData:(id)responseData
      responseHeader:(NSHTTPURLResponse *)response
                with:(JPResponeSuccess)success
                 and:(JPResponeFailure)failure;

/** 处理text/html错误信息 */
+ (NSString *)requestErrorMessageWithCode:(NSInteger)code;

/** 处理错误信息 */
+ (void)handleError:(id)error
               with:(JPResponeFailure)failure;

/** 检测网络是否联通 */
+ (BOOL)isConnectionAvailable;

@end
