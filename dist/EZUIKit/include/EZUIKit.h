//
//  EZUIKit.h
//  EZUIKit
//
//  Created by linyong on 2017/2/7.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Kit
@interface EZUIKit : NSObject

/**
 初始化EZUIKit

 @param appKey appkey
 */
+ (void) initWithAppKey:(NSString *) appKey;

/**
 设置accsess token

 @param token access token
 */
+ (void) setAccessToken:(NSString *) token;

@end
