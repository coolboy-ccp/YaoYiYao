//
//  YaoYiYaoBaseRequest.m
//  YaoYiYao
//
//  Created by liqunfei on 15/10/13.
//  Copyright © 2015年 chuchengpeng. All rights reserved.
//

#import "YaoYiYaoBaseRequest.h"

@implementation YaoYiYaoBaseRequest


- (void)serviceRequestWithPostURL:(NSString *)requestURL parameters:(NSDictionary *)paraDic successBlock:(void (^)(id response))successBlock failureBlock:(void (^)(NSString *errInfo))failureBlock {
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [operationManager POST:requestURL parameters:paraDic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSError * error;
       // NSData *jsData = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        successBlock(dic);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        failureBlock([error localizedDescription]);
    }];
}

@end
