//
//  EZOpenSDK.h
//  EzvizOpenSDK
//
//  Created by DeJohn Dong on 15/9/10.
//  Copyright (c) 2015年 Hikvision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZConstants.h"

@class EZPlayer;
@class EZDeviceInfo;
@class EZAccessToken;
@class EZCameraInfo;
@class EZDeviceVersion;
@class EZUserInfo;
@class EZProbeDeviceInfo;
@class EZDeviceUpgradeStatus;
@class EZLeaveMessage;

/// 此类为EZOpenSDK接口类 特别说明：110001（参数错误）、110002（AccessToken过期）、149999、150000（服务端异常）是所有http接口（返回值是NSOperation对象的大部分是http接口）都会返回的通用错误码，400002为接口参数错误的通用错误码
@interface EZOpenSDK : NSObject

/**
 *  @since 3.0.0
 *  实例EZOpenSDK接口
 *
 *  @param appKey 传入申请的appKey
 *
 *  @return YES/NO
 */
+ (BOOL)initLibWithAppKey:(NSString *)appKey;

/**
 *  @since 3.0.0
 *  销毁EZOpenSDK接口
 *
 *  @return YES/NO
 */
+ (BOOL)destoryLib;

/**
 *  @since 3.0.0
 *  获取SDK版本号接口
 *
 *  @return 版本号
 */
+ (NSString *)getVersion;

/**
 *  @since 3.0.0
 *  打开授权登录中间页面接口
 *
 *  @param block 回调block
 */
+ (void)openLoginPage:(void (^)(EZAccessToken *accessToken))block;

/**
 *  @since 3.0.0
 *  授权登录以后给EZOpenSDK设置accessToken接口
 *
 *  @param accessToken 授权登录获取的accessToken
 */
+ (void)setAccessToken:(NSString *)accessToken;

/**
 *  @since 3.0.0
 *  账户注销接口
 *
 *  @param completion 回调block，error为空表示登出成功
 *  @exception 错误码类型：待补充
 */
+ (void)logout:(void (^)(NSError *error))completion;

/**
 *  @since 3.0.0
 *  根据alarmId删除报警信息接口
 *
 *  @param alarmIds   报警信息Id数组(可以只有一个Id)，最多为10个Id，否则会报错
 *  @param completion 回调block，error为空时表示删除成功
 *  @exception 错误码类型：110004、120202，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)deleteAlarm:(NSArray *)alarmIds
                  completion:(void (^)(NSError *error))completion;

/**
 *  @since 3.0.0
 *  设置报警信息为已读接口
 *
 *  @param alarmIds   报警信息Id数组(可以只有一个Id)，最多为10个id,否则会报错
 *  @param status     报警消息状态
 *  @param completion 回调block，error为空时表示设置成功
 *  @exception 错误码类型：110004、120202，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)setAlarmStatus:(NSArray *)alarmIds
                    alarmStatus:(EZMessageStatus)status
                     completion:(void (^)(NSError *error))completion;


/**
 *  @since 3.0.0
 *  根据设备序列号删除当前账号的设备接口
 *
 *  @param deviceSerial 设备序列号
 *  @param completion   回调block，error为空时表示删除成功
 *  @exception 错误码类型：106002，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *  @see 该接口与终端绑定功能相关，会遇到删除时报106002的错误，请关闭终端绑定以后再试
 *
 *  @return operation
 */
+ (NSOperation *)deleteDevice:(NSString *)deviceSerial
                   completion:(void (^)(NSError *error))completion;

/**
 *  @since 3.0.0
 *  WiFi配置开始接口
 *
 *  @param ssid         连接WiFi SSID
 *  @param password     连接WiFi 密码
 *  @param deviceSerial 连接WiFi的设备的设备序列号
 *  @param statusBlock  返回连接设备的WiFi配置状态
 *
 *  @return YES/NO
 */
+ (BOOL)startConfigWifi:(NSString *)ssid
               password:(NSString *)password
           deviceSerial:(NSString *)deviceSerial
           deviceStatus:(void (^)(EZWifiConfigStatus status))statusBlock;

/**
 *  @since 3.0.0
 *  Wifi配置停止接口
 *
 *  @return YES/NO
 */
+ (BOOL)stopConfigWifi;

/**
 *  @since 3.0.0
 *  PTZ 控制接口
 *
 *  @param deviceSerial 设备序列号
 *  @param cameraNo     通道号
 *  @param command      ptz控制命令
 *  @param action       控制启动/停止
 *  @param speed        云台速度：0-慢，1-适中，2-快
 *  @param resultBlock  回调block，当error为空时表示操作成功
 *  @exception 错误码类型：160000、160001~160006、160009等错误码，具体参考EZOpenSDK头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)controlPTZ:(NSString *)deviceSerial
                   cameraNo:(NSInteger)cameraNo
                    command:(EZPTZCommand)command
                     action:(EZPTZAction)action
                      speed:(NSInteger)speed
                     result:(void (^)(NSError *error))resultBlock;

/**
 *  @since 3.0.0
 *  摄像头显示控制接口
 *
 *  @param deviceSerial 设备序列号
 *  @param cameraNo     通道号
 *  @param command      显示控制命令
 *  @param resultBlock  回调block，当error为空时表示操作成功
 *  @exception 错误码类型：160000、160001、160006、160009等错误码，具体参考EZOpenSDK头文件中的EZErrorCode错误码注释
 */
+ (void)controlVideoFlip:(NSString *)deviceSerial
                cameraNo:(NSInteger)cameraNo
                 command:(EZDisplayCommand)command
                  result:(void (^)(NSError *error))resultBlock;

/**
 *  @since 3.0.0
 *  根据cameraId构造EZPlayer对象
 *
 *  @param deviceSerial 设备序列号
 *  @param cameraNo     通道号
 *
 *  @return EZPlayer对象
 */
+ (EZPlayer *)createPlayerWithDeviceSerial:(NSString *)deviceSerial
                                  cameraNo:(NSInteger)cameraNo;


/**
 *  @since 3.0.0
 *  根据url构造EZPlayer对象 （主要用来处理视频广场的播放）
 *
 *  @param url 播放url，目前只支持该协议：ysproto://vtm.ys7.com:8554/live?dev=531993276&chn=1&stream=1&cln=1&isp=0&biz=3
 *
 *  @return EZPlayer对象
 */
+ (EZPlayer *)createPlayerWithUrl:(NSString *)url;


/**
 *  @since 3.0.0
 *  释放EZPlayer对象
 *
 *  @param player EZPlayer对象
 *
 *  @return YES/NO
 */
+ (BOOL)releasePlayer:(EZPlayer *)player;

#pragma mark - V3.1 新增加接口

/**
 *  @since 3.1.0
 *  数据解密
 *
 *  @param data       需要解密的数据
 *  @param verifyCode 设备验证码
 *
 *  @return 解密的NSData对象，如果返回的数据是空的，请检查密码是否正确或者传入的数据是否正确。
 */
+ (NSData *)decryptData:(NSData *)data verifyCode:(NSString *)verifyCode;


#pragma mark - V3.2 新增加接口

/**
 *  @since 3.2.0
 *  获取设备的版本信息接口
 *
 *  @param deviceSerial 设备序列号
 *  @param completion   回调block，正常时返回EZDeviceVersion的对象信息，错误时返回错误码
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)getDeviceVersion:(NSString *)deviceSerial
                       completion:(void (^)(EZDeviceVersion *version, NSError *error))completion;


/**
 *  @since 4.2.0
 *  通过设备验证码开关视频图片加密接口
 *
 *  @param isEncrypt    是否加密，只有NO(关闭)的时候需要设备验证码的相关参数(vaildateCode)
 *  @param deviceSerial 设备序列号
 *  @param verifyCode 设备验证码
 *  @param completion   回调block，error为空时表示操作成功
 *  @exception 错误码类型：110004、120002、120006、120007、120008、120014、120018，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)setDeviceEncryptStatus:(NSString *)deviceSerial
                             verifyCode:(NSString *)verifyCode
                                encrypt:(BOOL)isEncrypt
                             completion:(void (^)(NSError *error))completion;

/**
 *  @since 3.2.0
 *  根据设备序列号修改设备名称接口
 *
 *  @param deviceSerial 设备序列号
 *  @param deviceName   设备名称
 *  @param completion   回调block，error为空时表示修改成功
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)setDeviceName:(NSString *)deviceName
                  deviceSerial:(NSString *)deviceSerial
                    completion:(void (^)(NSError *error))completion;

/**
 *  @since 3.2.0
 *  获取用户基本信息的接口
 *
 *  @param completion 回调block， 正常时返回EZUserInfo的对象，错误时返回错误码
 *  @exception 错误码类型：110004，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)getUserInfo:(void (^)(EZUserInfo *userInfo, NSError *error))completion;

/**
 *  @since 3.2.0
 *  根据设备序列号获取未读消息数，设备序列号为空时获取所有设备的未读消息数
 *
 *  @param deviceSerial 需要获取的设备序列号，为空时返回账户下所有设备的未读消息数
 *  @param type         消息类型：EZMessageTypeAlarm 报警消息（1），EZMessageTypeLeave 留言消息（2）
 *  @param completion   回调block，正常时返回未读数量，错误时返回错误码
 *  @exception 错误码类型：110004、120002、120014、120018、120202，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)getUnreadMessageCount:(NSString *)deviceSerial
                           messageType:(EZMessageType)type
                            completion:(void (^)(NSInteger count, NSError *error))completion;

/**
 *  @since 3.2.0
 *  根据设备序列号获取设备的留言消息列表
 *
 *  @param deviceSerial 需要获取的设备序列号
 *  @param beginTime    开始时间
 *  @param endTime      结束时间
 *  @param pageIndex    分页页码
 *  @param pageSize     分页单页数量
 *  @param completion   回调block，正常时返回EZLeaveMessage的对象数组，错误时返回错误码
 *  @exception 错误码类型：110004、120002、120014、120018、120202，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)getLeaveMessageList:(NSString *)deviceSerial
                           pageIndex:(NSInteger)pageIndex
                            pageSize:(NSInteger)pageSize
                           beginTime:(NSDate *)beginTime
                             endTime:(NSDate *)endTime
                          completion:(void (^)(NSArray *leaveMessageList, NSInteger totalCount, NSError *error))completion;

/**
 *  @since 3.2.0
 *  根据leaveId设置留言消息状态
 *
 *  @param leaveIds   留言消息Id数组(最大数量为10，允许只有1个)
 *  @param status     需要设置的留言状态，目前只支持 EZMessageStatusRead(已读)
 *  @param completion 回调block，error为空表示设置成功
 *  @exception 错误码类型：110004、120202，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)setLeaveMessageStatus:(NSArray *)leaveIds
                         messageStatus:(EZMessageStatus)status
                            completion:(void (^)(NSError *error))completion;

/**
 *  @since 3.2.0
 *  根据leaveId删除留言消息
 *
 *  @param leaveIds   留言消息Id数组(最大数量为10，允许只有1个)
 *  @param completion 回调block，error为空表示删除成功
 *  @exception 错误码类型：110004、120202，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)deleteLeaveMessage:(NSArray *)leaveIds
                         completion:(void (^)(NSError *error))completion;

/**
 *  @since 3.2.0
 *  根据设备序列号获取存储介质状态(如是否初始化，格式化进度等)
 *
 *  @param deviceSerial 设备序列号
 *  @param completion   回调block，正常时返回EZStorageInfo的对象数组，错误时返回错误码
 *  @exception 错误码类型：110004、120002、120006、120007、120008、120014、120018，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)getStorageStatus:(NSString *)deviceSerial
                       completion:(void (^)(NSArray *storageStatus, NSError *error))completion;

/**
 *  @since 3.2.0
 *  根据设备序列号和分区编号格式化分区（SD卡）
 *
 *  @param deviceSerial 设备序列号
 *  @param storageIndex 查询返回的分区号，0表示全部格式化，可能会有几块硬盘的情况
 *  @param completion   回调block，error为空表示设置成功
 *  @exception 错误码类型：110004、120002、120006、120007、120008、120014、120016、120018，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)formatStorage:(NSString *)deviceSerial
                  storageIndex:(NSInteger)storageIndex
                    completion:(void (^)(NSError *error))completion;
/**
 *  @since 3.2.0
 *  尝试查询设备信息，设备Wifi配置前查询一次设备的信息
 *
 *  @param deviceSerial 设备序列号
 *  @param completion   回调block，正常时返回EZProbeDeviceInfo对象，错误码返回错误码
 *  @exception 错误码类型：110004、120002、120014、120020、120021、120022、120023、120024、120029，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *  @see 全新的设备是没有注册到平台的，所以会出现设备不存在的情况，设备wifi配置成功以后会上报数据到萤石云平台，以后每次查询就不会出现设备不存在的情况了。
 *
 *  @return operation
 */
+ (NSOperation *)probeDeviceInfo:(NSString *)deviceSerial
                      completion:(void (^)(EZProbeDeviceInfo *deviceInfo, NSError *error))completion;

/**
 *  @since 3.2.0
 *  根据设备序列号获取设备升级时的进度状态
 *
 *  @param deviceSerial 设备序列号
 *  @param completion   回调block，正常时返回EZDeviceUpgradeStatus对象，错误时返回错误码
 *  @exception 错误码类型：120002、120006、120007、120008、120014，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)getDeviceUpgradeStatus:(NSString *)deviceSerial
                             completion:(void (^)(EZDeviceUpgradeStatus *status, NSError *error))completion;

/**
 *  @since 3.2.0
 *  通过设备序列号对设备进行升级操作，前提是该设备有更新软件的提示
 *
 *  @param deviceSerial 设备序列号
 *  @param completion   回调block，error为空表示操作成功
 *  @exception 错误码类型：120002、120006、120007、120008、120014，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)upgradeDevice:(NSString *)deviceSerial
                    completion:(void (^)(NSError *error))completion;


/**
 *  @since 3.2.0
 *  根据EZLeaveMessage对象信息获取语音留言消息数据接口
 *  @param message    留言消息对象
 *  @param completion 回调block （resultCode = 1 表示语音下载成功，-1表示下载失败）
 *
 *  @return operation
 */
+ (NSOperation *)getLeaveMessageData:(EZLeaveMessage *)message
                          completion:(void (^)(NSData *data, NSInteger resultCode))completion;

/**
 *  @since 3.2.0
 *  打开云存储中间页
 *
 *  @param deviceSerial 设备序列号
 */
+ (void)openCloudPage:(NSString *)deviceSerial;

#pragma mark - V3.3 新增加接口

/**
 *  @since 3.3.0
 *  打开修改密码中间页
 *
 *  @param completion 回调block resultCode为0时表示修改密码成功
 */
+ (void)openChangePasswordPage:(void (^)(NSInteger resultCode))completion;

#pragma mark - V4.0 新增加接口

/**
 *  @since 4.0.0
 *  设置p2p功能是否开启接口，默认不开启p2p，用户自己选择是否开启
 *
 *  @param enable p2p是否开启
 */
+ (void)enableP2P:(BOOL)enable;

/**
 *  @since 4.0.0
 *  设置是否打印debug日志
 *
 *  @param enable 是否打印日志，默认关闭
 *
 *  @return YES/NO
 */
+ (BOOL)setDebugLogEnable:(BOOL)enable;

#pragma mark - V4.2 新增加接口

/**
 *  @since 4.2.0
 *  获取用户所有的设备列表
 *
 *  @param pageIndex  分页当前页码（从0开始）
 *  @param pageSize   分页每页数量（建议20以内）
 *  @param completion 回调block，正常时返回EZDeviceInfo的对象数组和设备总数，错误时返回错误码
 *  @exception 错误码类型：110004，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)getDeviceList:(NSInteger)pageIndex
                      pageSize:(NSInteger)pageSize
                    completion:(void (^)(NSArray *deviceList, NSInteger totalCount, NSError *error))completion;

/**
 *  @since 4.2.0
 *  获取分享给用户的设备列表接口
 *
 *  @param pageIndex  分页当前页码（从0开始）
 *  @param pageSize   分页每页数量（建议20以内）
 *  @param completion 回调block，正常时返回EZDeviceInfo的对象数组和设备总数，错误时返回错误码
 *  @exception 错误码类型：110004，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)getSharedDeviceList:(NSInteger)pageIndex
                            pageSize:(NSInteger)pageSize
                          completion:(void (^)(NSArray *deviceList, NSInteger totalCount, NSError *error))completion;

/**
 *  @since 4.2.0
 *  查询云存储录像信息列表接口
 *
 *  @param deviceSerial 设备序列号
 *  @param cameraNo     通道号
 *  @param beginTime    查询时间范围开始时间
 *  @param endTime      查询时间范围结束时间
 *  @param completion   回调block，正常时返回EZCloudRecordFile的对象数组，错误时返回错误码
 *  @exception 错误码类型：110004，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)searchRecordFileFromCloud:(NSString *)deviceSerial
                                  cameraNo:(NSInteger)cameraNo
                                 beginTime:(NSDate *)beginTime
                                   endTime:(NSDate *)endTime
                                completion:(void (^)(NSArray *couldRecords, NSError *error))completion;

/**
 *  @since 4.2.0
 *  查询远程SD卡存储录像信息列表接口
 *
 *  @param deviceSerial 设备序列号
 *  @param cameraNo     通道号
 *  @param beginTime    查询时间范围开始时间
 *  @param endTime      查询时间范围结束时间
 *  @param completion   回调block，正常时返回EZDeviceRecordFile的对象数组，错误时返回错误码
 *  @exception 错误码类型：110004，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)searchRecordFileFromDevice:(NSString *)deviceSerial
                                   cameraNo:(NSInteger)cameraNo
                                  beginTime:(NSDate *)beginTime
                                    endTime:(NSDate *)endTime
                                 completion:(void (^)(NSArray *deviceRecords, NSError *error))completion;

/**
 *  @since 4.2.0
 *  根据设备序列号获取报警信息列表，设备序列号为nil时查询整个账户下的报警信息列表
 *
 *  @param deviceSerial 设备序列号
 *  @param pageIndex    分页当前页码（从0开始）
 *  @param pageSize     分页每页数量（建议20以内）
 *  @param beginTime    搜索时间范围开始时间
 *  @param endTime      搜索时间范围结束时间
 *  @param completion   回调block，正常时返回EZAlarmInfo的对象数据和查询时间范围内的报警个数的总数，错误时返回错误码
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)getAlarmList:(NSString *)deviceSerial
                    pageIndex:(NSInteger)pageIndex
                     pageSize:(NSInteger)pageSize
                    beginTime:(NSDate *)beginTime
                      endTime:(NSDate *)endTime
                   completion:(void (^)(NSArray *alarmList, NSInteger totalCount, NSError *error))completion;

/**
 *  @since 4.2.0
 *  根据设备序列号和设备验证码添加设备接口
 *
 *  @param deviceSerial 设备序列号
 *  @param verifyCode   设备验证码
 *  @param completion   回调block，error为空时表示添加成功
 *  @exception 错误码类型：120002、120006、120007、120008、120014，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)addDevice:(NSString *)deviceSerial
                verifyCode:(NSString *)verifyCode
                completion:(void (^)(NSError *error))completion;

/**
 *  @since 4.2.0
 *  获取抓取摄像头图片的url接口
 *
 *  @param deviceSerial 设备序列号
 *  @param cameraNo     通道号
 *  @param completion   回调block，正常时返回url地址信息，错误时返回错误码
 *  @exception 错误码类型：120001、120002、120006、120008，具体参考EZConstants头文件中的EZErrorCode错误码注释
 *  @see 该接口比较耗时，不建议进行批量设备抓图，SDK内部只支持6个http请求并发，该接口会持续占用http请求资源，如果遇到http请求延时巨大问题，优先考虑抓图接口并发造成的问题,
 *  抓图将在服务器端保留2个小时
 *
 *  @return operation
 */
+ (NSOperation *)captureCamera:(NSString *)deviceSerial
                      cameraNo:(NSInteger)cameraNo
                    completion:(void (^)(NSString *url, NSError *error))completion;

/**
 *  @since 4.2.0
 *  设置设备通道的清晰度
 *
 *  @param deviceSerial 设备序列号
 *  @param cameraNo     通道号
 *  @param videoLevel   通道清晰度，0-流畅，1-均衡，2-高清，3-超清
 *  @param completion   回调block，无error表示设置成功
 *  @see 如果是正在播放时调用该接口，设置清晰度成功以后必须让EZPlayer调用stopRealPlay再调用startRealPlay重新取流才成完成画面清晰度的切换。
 *
 *  @return operation
 */
+ (NSOperation *)setVideoLevel:(NSString *)deviceSerial
                      cameraNo:(NSInteger)cameraNo
                    videoLevel:(EZVideoLevelType)videoLevel
                    completion:(void (^)(NSError *error))completion;


/**
 *  @since 4.2.0
 *  设备设置布防状态，兼容A1和IPC设备的布防
 *
 *  @param defence      布防状态, IPC布防状态只有0和1，A1有0:睡眠 8:在家 16:外出
 *  @param deviceSerial 设备序列号
 *  @param completion   回调block，error为空表示设置成功
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考EZOpenSDK头文件中的EZErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperation *)setDefence:(EZDefenceStatus)defence
               deviceSerial:(NSString *)deviceSerial
                 completion:(void (^)(NSError *error))completion;

#pragma mark - V4.3 新增加接口

/**
 *  @since 4.3.0
 *  根据序列号获取设备信息
 *
 *  @param deviceSerial 设备序列号
 *  @param completion 回调block，正常时返回EZDeviceInfo的对象，错误时返回错误码
 *
 *  @return operation
 */
+ (NSOperation *)getDeviceInfo:(NSString *)deviceSerial
                    completion:(void (^)(EZDeviceInfo *deviceInfo, NSError *error))completion;

/**
 *  @since 4.3.0
 *  获取终端（手机等）唯一识别码
 *
 *  @return 终端唯一识别码
 */
+ (NSString *) getTerminalId;

#pragma mark - V4.4 新增加接口

/**
 *  @since 4.4.0
 *  push初始化接口，不需要push服务则无需调用
 */
+ (void) initPushService;

#pragma mark - V4.5 新增加接口

/**
 清除取流时的缓存数据
 */
+ (void) clearStreamInfoCache;

@end
