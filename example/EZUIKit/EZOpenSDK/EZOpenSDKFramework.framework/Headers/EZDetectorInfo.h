//
//  EZDetectorInfo.h
//  EzvizOpenSDK
//
//  Created by DeJohn Dong on 16/1/12.
//  Copyright © 2016年 Hikvision. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 此类为探测器信息对象
@interface EZDetectorInfo : NSObject

/// 探测器序列号
@property (nonatomic, copy) NSString *detectorSerial;
/// 探测器状态，探测器与A1是否连通：0-非联通，1-联通
@property (nonatomic) NSInteger state;
/// 探测器类型
@property (nonatomic, copy) NSString *type;
/// 探测器名称
/*  V("V", "视频设备"), I("I", "报警输入设备"), O("O", "报警输出设备"), PIR("PIR", "红外探测器"), FIRE("FIRE", "烟感探测器"),MAGNETOMETER("MAGNETOMETER", "门磁传感器"), GAS("GAS", "可燃气体"), WATERLOGGING("WATERLOGGING", "水浸"),CALLHELP("CALLHELP", "紧急按钮"), TELECONTROL("TELECONTROL", "遥控器"), ALERTOR("ALERTOR", "报警器"),KEYBOARD("KEYBOARD", "键盘"),CURTAIN("CURTAIN","幕帘"), MOVE_MAGNETOMETER("MOVE_MAGNETOMETER","单体门磁")
 */
@property (nonatomic, copy) NSString *typeName;
/// 防区故障状态，0恢复，1产生
@property (nonatomic) NSInteger faultZoneStatus;
/// 电池欠压状态，0恢复，1产生
@property (nonatomic) NSInteger underVoltageStatus;
/// 无线干扰状态，0恢复，1产生
@property (nonatomic) NSInteger wirelessInterferenceStatus;
/// 设备离线状态，0恢复，1产生
@property (nonatomic) NSInteger offlineStatus;
/// 在家模式是否开启
@property (nonatomic) BOOL atHomeEnable;
/// 外出模式是否开启
@property (nonatomic) BOOL outerEnable;
/// 睡眠模式是否开启
@property (nonatomic) BOOL sleepEnable;

@end
