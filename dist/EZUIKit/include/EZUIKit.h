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
 国内版初始化EZUIKit,适用于国内和全球统一

 @param appKey appkey
 */
+ (void) initWithAppKey:(NSString *) appKey;

/**
 国际版初始化EZUIKit，只适用于国际版
 
 @param appKey appkey
 @param apiUrl 对应区域服务器地址
 */
+ (void) initGlobalWithAppKey:(NSString *) appKey apiUrl:(NSString *) apiUrl;

/**
 设置是否开启调试信息打印，建议在初始化之前调用

 @param debugOn 是否开启
 */
+ (void) setDebug:(BOOL) debugOn;

/**
 设置accsess token

 @param token access token
 */
+ (void) setAccessToken:(NSString *) token;

/**
 获取EZUIKit版本号

 @return EZUIKit版本号
 */
+ (NSString *) getVersion;

@end
