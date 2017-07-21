//
//  EZPlaybackProgressBar.h
//  EZUIKit
//
//  Created by linyong on 2017/4/24.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EZPlaybackInfo : NSObject

@property (nonatomic,strong) NSDate *beginTime;
@property (nonatomic,strong) NSDate *endTime;
@property (nonatomic,assign) NSInteger recType;//1:云存储，2:本地录像

@end


@protocol EZPlaybackProgressDelegate <NSObject>

/**
 bar滚动到特定时间点

 @param time 时间点
 */
- (void) EZPlaybackProgressBarScrollToTime:(NSDate *) time;

@optional



@end

@interface EZPlaybackProgressBar : UIView

@property (nonatomic,weak) id<EZPlaybackProgressDelegate> delegate;//代理
@property (nonatomic,readonly) NSArray *dataList;//EZPlaybackInfo对象的数组

/**
 创建bar对象

 @param frame bar展示区域
 @param dataList EZPlaybackInfo对象的数组
 @return bar实例
 */
- (instancetype) initWithFrame:(CGRect)frame dataList:(NSArray *) dataList;

/**
 根据数据重新绘制bar

 @param dataList EZPlaybackInfo对象的数组
 */
- (void) updateWithDataList:(NSArray *) dataList;

/**
 滚动到指定时间点

 @param dateTime 时间点
 */
- (void) scrollToDate:(NSDate *) dateTime;

@end
