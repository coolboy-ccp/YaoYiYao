//
//  YaoYiYaoBaseRequest.h
//  YaoYiYao
//
//  Created by liqunfei on 15/10/13.
//  Copyright © 2015年 chuchengpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YaoYiYaoBaseRequest : NSObject

- (void)serviceRequestWithPostURL:(NSString *)requestURL parameters:(NSDictionary *)paraDic successBlock:(void (^)(id response))successBlock failureBlock:(void (^)(NSString *errInfo))failureBlock;

@end
