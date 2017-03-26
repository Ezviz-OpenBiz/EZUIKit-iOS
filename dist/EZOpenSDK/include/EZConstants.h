//
//  EZConstants.h
//  EzvizOpenSDK
//
//  Created by DeJohn Dong on 16/7/20.
//  Copyright © 2016年 Hikvision. All rights reserved.
//

#import <Foundation/Foundation.h>

/* EZOpenSDK的错误定义 */
typedef NS_ENUM(NSInteger, EZErrorCode) {
    EZ_DEVICE_TTS_TALKING_TIMEOUT = 360002,           //对讲发起超时
    EZ_DEVICE_TTS_TALKING = 360010,                   //设备正在对讲中
    EZ_DEVICE_IS_PRIVACY_PROTECTING = 380011,         //设备隐私保护中
    EZ_DEVICE_CONNECT_COUNT_LIMIT = 380045,           //设备直连取流连接数量过大
    EZ_DEVICE_COMMAND_NOT_SUPPORT = 380047,           //设备不支持该命令
    EZ_DEVICE_CAS_TALKING = 380077,                   //设备正在对讲中
    EZ_DEVICE_CAS_PARSE_ERROR = 380205,               //设备检测入参异常
    EZ_PLAY_TIMEOUT = 380209,                         //网络连接超时
    EZ_DEVICE_TIMEOUT = 380212,                       //设备端网络连接超时
    EZ_STREAM_CLIENT_TIMEOUT = 390038,                //同时`390037`手机网络引起的取流超时
    EZ_STREAM_CLIENT_OFFLINE = 395404,                //设备不在线
    EZ_STREAM_CLIENT_DEVICE_COUNT_LIMIT = 395410,     //设备连接数过大
    EZ_STREAM_CLIENT_NOT_FIND_FILE = 395402,          //回放找不到录像文件，检查传入的回放文件是否正确
    EZ_STREAM_CLIENT_TOKEN_INVALID = 395406,          //取流token验证失效
    EZ_STREAM_CLIENT_CAMERANO_ERROR = 395415,         //设备通道错
    EZ_STREAM_CLIENT_LIMIT = 395546,                  //设备取流受到限制
    /**
     *  HTTP 错误码
     */
    EZ_HTTPS_PARAM_ERROR = 110001,                    //请求参数错误
    EZ_HTTPS_ACCESS_TOKEN_INVALID = 110002,           //AccessToken无效
    EZ_HTTPS_REGIST_USER_NOT_EXSIT = 110004,          //注册用户不存在
    EZ_HTTPS_USER_BINDED = 110012,                    //第三方账户与萤石账号已经绑定
    EZ_HTTPS_APPKEY_IS_NULL = 110017,                 //AppKey不存在
    EZ_HTTPS_APPKEY_NOT_MATCHED = 110018,             //AppKey不匹配，请检查服务端设置的appKey是否和SDK使用的appKey一致
    EZ_HTTPS_CAMERA_NOT_EXISTS = 120001,              //通道不存在，请检查摄像头设备是否重新添加过
    EZ_HTTPS_DEVICE_NOT_EXISTS = 120002,              //设备不存在
    EZ_HTTPS_DEVICE_NETWORK_ANOMALY = 120006,         //网络异常
    EZ_HTTPS_DEVICE_OFFLINE = 120007,                 //设备不在线
    EZ_HTTPS_DEIVCE_RESPONSE_TIMEOUT = 120008,        //设备请求响应超时异常
    EZ_HTTPS_ILLEGAL_DEVICE_SERIAL = 120014,          //不合法的序列号
    EZ_HTTPS_DEVICE_STORAGE_FORMATTING = 120016,      //设备正在格式化磁盘
    EZ_HTTPS_DEVICE_ADDED_MYSELF = 120017,            //同时`120020`设备已经被自己添加
    EZ_HTTPS_USER_NOT_OWN_THIS_DEVICE = 120018,       //该用户不拥有该设备
    EZ_HTTPS_DEVICE_ONLINE_NOT_ADDED = 120021,        //设备在线，未被用户添加
    EZ_HTTPS_DEVICE_ONLINE_IS_ADDED = 120022,         //设备在线，已经被别的用户添加
    EZ_HTTPS_DEVICE_OFFLINE_NOT_ADDED = 120023,       //设备不在线，未被用户添加
    EZ_HTTPS_DEVICE_OFFLINE_IS_ADDED = 120024,        //设备不在线，已经被别的用户添加
    EZ_HTTPS_DEVICE_OFFLINE_IS_ADDED_MYSELF = 120029, //设备不在线，但是已经被自己添加
    EZ_HTTPS_OPERATE_LEAVE_MSG_FAIL = 120202,         //操作留言消息失败
    EZ_HTTPS_DEVICE_BUNDEL_STATUS_ON = 120031,        //同时`106002`错误码也是，设备开启了终端绑定，请到萤石云客户端关闭终端绑定
    EZ_HTTPS_SERVER_DATA_ERROR = 149999,              //数据异常
    EZ_HTTPS_SERVER_ERROR = 150000,                   //服务器异常
    EZ_HTTPS_DEVICE_PTZ_NOT_SUPPORT = 160000,         //设备不支持云台控制
    EZ_HTTPS_DEVICE_PTZ_NO_PERMISSION = 160001,       //用户没有权限操作云台控制
    EZ_HTTPS_DEVICE_PTZ_UPPER_LIMIT = 160002,         //云台达到上限位（顶部）
    EZ_HTTPS_DEVICE_PTZ_FLOOR_LIMIT = 160003,         //云台达到下限位（底部）
    EZ_HTTPS_DEVICE_PTZ_LEFT_LIMIT = 160004,          //云台达到左限位（最左边）
    EZ_HTTPS_DEVICE_PTZ_RIGHT_LIMIT = 160005,         //云台达到右限位（最右边）
    EZ_HTTPS_DEVICE_PTZ_FAILED = 160006,              //云台操作失败
    EZ_HTTPS_DEVICE_PTZ_RESETING = 160009,            //云台正在调用预置点
    EZ_HTTPS_DEVICE_COMMAND_NOT_SUPPORT = 160020,     //设备不支持该命令
    
    /**
     *  接口 错误码(SDK本地校验)
     */
    EZ_SDK_PARAM_ERROR = 400002,                      //接口参数错误
    EZ_SDK_NOT_SUPPORT_TALK = 400025,                 //设备不支持对讲
    EZ_SDK_TIMEOUT = 400034,                          //无播放token，请stop再start播放器
    EZ_SDK_NEED_VALIDATECODE = 400035,                //需要设备验证码
    EZ_SDK_VALIDATECODE_NOT_MATCH = 400036,           //设备验证码不匹配
    EZ_SDK_DECODE_TIMEOUT = 400041,                   //解码超时，可能是验证码错误
    EZ_SDK_STREAM_TIMEOUT = 400015,                   //取流超时,请检查手机网络
    EZ_SDK_PLAYBACK_STREAM_TIMEOUT = 400409,          //回放取流超时,请检查手机网络
};

/* 播放器EZPlayer的状态消息定义 */
typedef NS_ENUM(NSInteger, EZMessageCode) {
    PLAYER_REALPLAY_START = 1,        //直播开始
    PLAYER_VIDEOLEVEL_CHANGE = 2,     //直播流清晰度切换中
    PLAYER_STREAM_RECONNECT = 3,      //直播流取流正在重连
    PLAYER_VOICE_TALK_START = 4,      //对讲开始
    PLAYER_VOICE_TALK_END = 5,        //对讲结束
    PLAYER_STREAM_START = 10,         //录像取流开始
    PLAYER_PLAYBACK_START = 11,       //录像回放开始播放
    PLAYER_PLAYBACK_STOP = 12,        //录像回放结束播放
    PLAYER_PLAYBACK_FINISHED = 13,    //录像回放被用户强制中断
    PLAYER_PLAYBACK_PAUSE = 14,       //录像回放暂停
};

/* WiFi配置设备状态 */
typedef NS_ENUM(NSInteger, EZWifiConfigStatus) {
    DEVICE_WIFI_CONNECTING = 1,   //设备正在连接WiFi
    DEVICE_WIFI_CONNECTED = 2,    //设备连接WiFi成功
    DEVICE_PLATFORM_REGISTED = 3, //设备注册平台成功
    DEVICE_ACCOUNT_BINDED = 4     //设备已经绑定账户
};

/* 设备ptz命令 */
typedef NS_OPTIONS(NSUInteger, EZPTZCommand) {
    EZPTZCommandLeft            = 1 << 0, //向左旋转
    EZPTZCommandRight           = 1 << 1, //向右旋转
    EZPTZCommandUp              = 1 << 2, //向上旋转
    EZPTZCommandDown            = 1 << 3, //向下旋转
    EZPTZCommandZoomIn          = 1 << 4, //镜头拉进
    EZPTZCommandZoomOut         = 1 << 5, //镜头拉远
};

/*
 * 设备显示命令
 */
typedef NS_OPTIONS(NSUInteger, EZDisplayCommand) {
    EZDisplayCommandCenter          = 1 << 0, //显示中间
};

/**
 *  设备ptz动作命令
 */
typedef NS_ENUM(NSInteger, EZPTZAction) {
    EZPTZActionStart = 1, //ptz开始
    EZPTZActionStop = 2   //ptz停止
};

/* 消息状态 */
typedef NS_ENUM(NSInteger, EZMessageStatus) {
    EZMessageStatusRead = 1,    //已读
};

/* 消息类型 */
typedef NS_ENUM(NSInteger, EZMessageType)
{
    EZMessageTypeAlarm = 1,   //报警类型
    EZMessageTypeLeave,       //留言类型
};

/* 留言消息类型 */
typedef NS_ENUM(NSInteger, EZLeaveMessageType)
{
    EZLeaveMessageTypeAll,    //全部
    EZLeaveMessageTypeVoice,  //语音类
    EZLeaveMessageTypeVideo,  //视频类
};

/* 设备布防状态枚举类型 */
typedef NS_ENUM(NSInteger, EZDefenceStatus) {
    EZDefenceStatusOffOrSleep     = 0,  //A1设备睡眠模式或者非A1设备的撤防状态
    EZDefenceStatusOn             = 1,  //非A1设备的布防状态
    EZDefenceStatusAtHome         = 8,  //A1在家模式
    EZDefenceStatusOuter          = 16, //A1外出模式
};

/* 通道清晰度，请注意不是所有设备都有这些清晰度的，请根据实际场景使用 */
typedef NS_ENUM(NSInteger, EZVideoLevelType)
{
    EZVideoLevelLow       = 0,  //流畅
    EZVideoLevelMiddle    = 1,  //均衡
    EZVideoLevelHigh      = 2,  //高清
    EZVideoLevelSuperHigh = 3   //超清
};

/// 开放平台常量类
@interface EZConstants : NSObject

@end
