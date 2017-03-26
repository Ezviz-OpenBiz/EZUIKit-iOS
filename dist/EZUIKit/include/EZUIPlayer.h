//
//  EZUIPlayer.h
//  EZUIKit
//
//  Created by linyong on 2017/2/7.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZUIPlayer;
@class EZUIError;

@protocol EZUIPlayerDelegate <NSObject>

@optional

/**
 播放失败

 @param player 播放器对象
 @param error 错误码对象
 */
- (void) EZUIPlayer:(EZUIPlayer *) player didPlayFailed:(EZUIError *) error;

/**
 播放成功

 @param player 播放器对象
 */
- (void) EZUIPlayerPlaySucceed:(EZUIPlayer *) player;

/**
 播放器回调返回视频宽高

 @param player 播放器对象
 @param pWidth 视频宽度
 @param pHeight 视频高度
 */
- (void) EZUIPlayer:(EZUIPlayer *) player previewWidth:(CGFloat) pWidth previewHeight:(CGFloat) pHeight;

@end

/// 播放器类
@interface EZUIPlayer : NSObject

@property (nonatomic,readonly) UIView *previewView; /// 展示画面的视图
@property (nonatomic,weak) id<EZUIPlayerDelegate> mDelegate; /// 代理
@property (nonatomic,strong) UIView *customIndicatorView; /// 默认为系统自带加载动画，如用户自定义需自行控制动画，设置为nil则无加载动画

/**
 创建播放器实例

 @param url 视频源url地址
 @return 播放器实例
 */
+ (EZUIPlayer *) createPlayerWithUrl:(NSString *) url;


/**
 创建播放器实例

 @param serial 设备序列号
 @param camerNo 通道号
 @param verifyCode 验证码，未开启视频加密，则为nil
 @param isHd 是否高清
 @return 创建播放器实例
 */
+ (EZUIPlayer *) createPlayerWithSerial:(NSString *) serial
                                camerNo:(NSUInteger) camerNo
                             verifyCode:(NSString *) verifyCode
                                     hd:(BOOL) isHd;

/**
 开始播放
 */
- (void) startPlay;

/**
 停止播放
 */
- (void) stopPlay;

/**
 释放播放器资源
 */
- (void) releasePlayer;

/**
 音频开关,默认开启音频

 @param on YES:打开音频，NO:关闭音频
 */
- (void) setAudioOn:(BOOL) on;

/**
 设置预览界面的frame，会自动调节画面等比居中

 @param frame 预览界面frame
 */
- (void) setPreviewFrame:(CGRect) frame;

@end
