//
//  EZProbeDeviceInfo.h
//  EzvizOpenSDK
//
//  Created by DeJohn Dong on 15/12/11.
//  Copyright © 2015年 Hikvision. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 此类为查询设备信息对象（设备添加前使用）
@interface EZProbeDeviceInfo : NSObject

/// 展示名称
@property (nonatomic, copy) NSString *displayName;
/// 设备短序列号
@property (nonatomic, copy) NSString *subSerial;
/// 设备长序列号
@property (nonatomic, copy) NSString *fullSerial;
/// 设备在线状态，1-在线，其他-不在线
@property (nonatomic) NSInteger status;
/// 设备图片
@property (nonatomic, copy) NSString *defaultPicPath;
/// 是否支持wifi，0-不支持，1-支持，2-支持带userId的新的wifi配置方式，3-支持smartwifi
@property (nonatomic) NSInteger supportWifi;
/// 设备协议版本
@property (nonatomic, copy) NSString *releaseVersion;
/// 可用于添加的通道数
@property (nonatomic) NSInteger availiableChannelCount;
/// N1，R1，A1等设备关联的设备数
@property (nonatomic) NSInteger relatedDeviceCount;
/// 能力集
@property (nonatomic, copy) NSString *supportExt;

@end
