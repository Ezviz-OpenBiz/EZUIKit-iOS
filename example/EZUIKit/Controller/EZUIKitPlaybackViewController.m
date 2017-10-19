//
//  EZUIKitPlaybackViewController.m
//  EZUIKit
//
//  Created by linyong on 2017/2/17.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EZUIKitPlaybackViewController.h"
#import "EZUIKit.h"
#import "EZUIPlayer.h"
#import "EZUIError.h"
#import "Toast+UIView.h"
#import "EZPlaybackProgressBar.h"
#import "EZDeviceRecordFile.h"
#import "EZCloudRecordFile.h"

@interface EZUIKitPlaybackViewController () <EZUIPlayerDelegate,EZPlaybackProgressDelegate>

@property (nonatomic,strong) EZUIPlayer *mPlayer;
@property (nonatomic,strong) UIButton *playBtn;
@property (nonatomic,strong) EZPlaybackProgressBar *playProgressBar;

@end

@implementation EZUIKitPlaybackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.playBtn setTitle:NSLocalizedString(@"play", @"播放") forState:UIControlStateNormal];
    [self.playBtn setTitle:NSLocalizedString(@"stop", @"停止") forState:UIControlStateSelected];
    self.playBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-80)/2, 350, 80, 40);
    [self.playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playBtn];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.appKey || self.appKey.length == 0 ||
        !self.accessToken || self.accessToken.length == 0 ||
        !self.urlStr || self.urlStr == 0)
    {
        return;
    }
    
    if (self.apiUrl)
    {
        [EZUIKit initGlobalWithAppKey:self.appKey apiUrl:self.apiUrl];
    }
    else
    {
        [EZUIKit initWithAppKey:self.appKey];
    }
    [EZUIKit setAccessToken:self.accessToken];
    [self play];
    self.playBtn.selected = YES;
}

- (void)dealloc
{
    [self releasePlayer];
}

#pragma mark - play bar delegate

- (void) EZPlaybackProgressBarScrollToTime:(NSDate *)time
{
    if (!self.mPlayer)
    {
        return;
    }
    
    self.playBtn.selected = YES;
    [self.mPlayer seekToTime:time];
}

#pragma mark - player delegate

- (void) EZUIPlayerPlayTime:(NSDate *)osdTime
{
    [self.playProgressBar scrollToDate:osdTime];
}

- (void) EZUIPlayerFinished
{
    [self stop];
    self.playBtn.selected = NO;
}

- (void) EZUIPlayerPrepared
{
    if ([EZUIPlayer getPlayModeWithUrl:self.urlStr] ==  EZUIKIT_PLAYMODE_REC)
    {
        [self createProgressBarWithList:self.mPlayer.recordList];
    }
    [self play];
}

- (void) EZUIPlayerPlaySucceed:(EZUIPlayer *)player
{
    self.playBtn.selected = YES;
}

- (void) EZUIPlayer:(EZUIPlayer *)player didPlayFailed:(EZUIError *) error
{
    [self stop];
    self.playBtn.selected = NO;
    
    if ([error.errorString isEqualToString:UE_ERROR_INNER_VERIFYCODE_ERROR])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"verify_code_wrong", @"验证码错误"),error.errorString] duration:1.5 position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_TRANSF_DEVICE_OFFLINE])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"device_offline", @"设备不在线"),error.errorString] duration:1.5 position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_CAMERA_NOT_EXIST] ||
             [error.errorString isEqualToString:UE_ERROR_DEVICE_NOT_EXIST])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"camera_not_exist", @"通道不存在"),error.errorString] duration:1.5 position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_INNER_STREAM_TIMEOUT])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"connect_out_time", @"连接超时"),error.errorString] duration:1.5 position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_CAS_MSG_PU_NO_RESOURCE])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"connect_device_limit", @"设备连接数过大"),error.errorString] duration:1.5 position:@"center"];
    }
    else
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"play_fail", @"播放失败"),error.errorString] duration:1.5 position:@"center"];
    }
    
    NSLog(@"play error:%@(%d)",error.errorString,error.internalErrorCode);
}

- (void) EZUIPlayer:(EZUIPlayer *)player previewWidth:(CGFloat)pWidth previewHeight:(CGFloat)pHeight
{
    CGFloat ratio = pWidth/pHeight;
    
    CGFloat destWidth = CGRectGetWidth(self.view.bounds);
    CGFloat destHeight = destWidth/ratio;
    
    [player setPreviewFrame:CGRectMake(0, CGRectGetMinY(player.previewView.frame), destWidth, destHeight)];
}


#pragma mark - actions

- (void) playBtnClick:(UIButton *) btn
{
    if(btn.selected)
    {
        [self stop];
    }
    else
    {
        [self play];
    }
    btn.selected = !btn.selected;
}


#pragma mark - support

- (void) createProgressBarWithList:(NSArray *) list
{    
    NSMutableArray *destList = [NSMutableArray array];
    for (id fileInfo in list)
    {
        EZPlaybackInfo *info = [[EZPlaybackInfo alloc] init];
        
        if  ([fileInfo isKindOfClass:[EZDeviceRecordFile class]])
        {
            info.beginTime = ((EZDeviceRecordFile*)fileInfo).startTime;
            info.endTime = ((EZDeviceRecordFile*)fileInfo).stopTime;
            info.recType = 2;
        }
        else
        {
            info.beginTime = ((EZCloudRecordFile*)fileInfo).startTime;
            info.endTime = ((EZCloudRecordFile*)fileInfo).stopTime;
            info.recType = 1;
        }
        
        [destList addObject:info];
    }
    
    if (self.playProgressBar)
    {
        [self.playProgressBar updateWithDataList:destList];
        [self.playProgressBar scrollToDate:((EZPlaybackInfo*)[destList firstObject]).beginTime];
        return;
    }
    
    self.playProgressBar = [[EZPlaybackProgressBar alloc] initWithFrame:CGRectMake(0, 430,
                                                                                   [UIScreen mainScreen].bounds.size.width,
                                                                                   100)
                                                               dataList:destList];
    self.playProgressBar.delegate = self;
    self.playProgressBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.playProgressBar];
}

#pragma mark - player

- (void) play
{
    if (self.mPlayer)
    {
        [self.mPlayer startPlay];
        return;
    }
    
    self.mPlayer = [EZUIPlayer createPlayerWithUrl:self.urlStr];
    self.mPlayer.mDelegate = self;
//    self.mPlayer.customIndicatorView = nil;//设置为nil则去除加载动画
    self.mPlayer.previewView.frame = CGRectMake(0, 64,
                                                CGRectGetWidth(self.mPlayer.previewView.frame),
                                                CGRectGetHeight(self.mPlayer.previewView.frame));
    
    [self.view addSubview:self.mPlayer.previewView];
}

- (void) stop
{
    if (!self.mPlayer)
    {
        return;
    }
    
    [self.mPlayer stopPlay];
}

- (void) releasePlayer
{
    if (!self.mPlayer)
    {
        return;
    }
    
    [self.mPlayer.previewView removeFromSuperview];
    [self.mPlayer releasePlayer];
    self.mPlayer = nil;
}

#pragma mark - orientation

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    CGRect frame = CGRectZero;
    if (size.height > size.width)
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        frame = CGRectMake(0, 64,size.width,size.width*9/16);
    }
    else
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        frame = CGRectMake(0, 0,size.width,size.height);
    }
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.mPlayer setPreviewFrame:frame];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}


@end
