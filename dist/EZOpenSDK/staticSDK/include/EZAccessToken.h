//
//  EZAccessToken.h
//  EzvizOpenSDK
//
//  Created by DeJohn Dong on 15/10/19.
//  Copyright © 2015年 Hikvision. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 此类为萤石开放平台授权登录以后的凭证信息
@interface EZAccessToken : NSObject

/// accessToken 登录凭证
@property (nonatomic, copy) NSString *accessToken;
/// accessToken距离过期的秒数，用当前时间加上expire的秒数为过期时间
@property (nonatomic, assign) NSInteger expire;

@end
