//
//  JPNetworkConfig.h
//  JPCertificationKit
//
//  Created by Damon Gao on 2018/4/26.
//  Copyright © 2018年 Damon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JPNetworkConfig : NSObject

/** 通用域名(有需要再写) */
@property (nonatomic, strong) NSString *baseUrl;
/** 请求的配置 */
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
/** 超时时间 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

+ (JPNetworkConfig *)sharedConfig;

@end
