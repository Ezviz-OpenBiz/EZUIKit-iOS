//
//  EZUIKitViewController.m
//  EZUIKit
//
//  Created by linyong on 2017/2/17.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EZUIKitViewController.h"
#import "EZUIKit.h"
#import "EZUIPlayer.h"
#import "EZUIError.h"
#import "Toast+UIView.h"

@interface EZUIKitViewController () <EZUIPlayerDelegate>

@property (nonatomic,strong) EZUIPlayer *mPlayer;
@property (nonatomic,strong) EZUIPlayer *mPlayerOther;
@property (nonatomic,strong) UIButton *playBtn;
@property (nonatomic,strong) UIButton *switchBtn;

@end

@implementation EZUIKitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.playBtn setTitle:NSLocalizedString(@"play", @"播放") forState:UIControlStateNormal];
    [self.playBtn setTitle:NSLocalizedString(@"stop", @"停止") forState:UIControlStateSelected];
    self.playBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-80)/2, [UIScreen mainScreen].bounds.size.height - 100, 80, 40);
    [self.playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playBtn];
    
    self.switchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.switchBtn setTitle:NSLocalizedString(@"switch", @"切换") forState:UIControlStateNormal];
    self.switchBtn.frame = CGRectMake(CGRectGetMinX(self.playBtn.frame),
                                      CGRectGetMaxY(self.playBtn.frame)+10,
                                      CGRectGetWidth(self.playBtn.frame),
                                      CGRectGetHeight(self.playBtn.frame));
    [self.switchBtn addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.switchBtn.hidden = self.urlStrOhter?NO:YES;
    [self.view addSubview:self.switchBtn];
    
    if (self.urlStrOhter)
    {
        self.playBtn.hidden = YES;
    }
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

#pragma mark - player delegate

- (void) EZUIPlayerFinished:(EZUIPlayer*) player
{
    [player stopPlay];
    self.playBtn.selected = NO;
}

- (void) EZUIPlayerPrepared:(EZUIPlayer*) player
{
    [player startPlay];
}

- (void) EZUIPlayerPlaySucceed:(EZUIPlayer *)player
{
    self.playBtn.selected = YES;
}

- (void) EZUIPlayer:(EZUIPlayer *)player didPlayFailed:(EZUIError *) error
{
    [player stopPlay];
    self.playBtn.selected = NO;
    
    if ([error.errorString isEqualToString:UE_ERROR_INNER_VERIFYCODE_ERROR])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",NSLocalizedString(@"verify_code_wrong", @"验证码错误"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_TRANSF_DEVICE_OFFLINE])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"device_offline", @"设备不在线"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_DEVICE_NOT_EXIST])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"device_not_exist", @"设备不存在"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_CAMERA_NOT_EXIST])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"camera_not_exist", @"通道不存在"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_INNER_STREAM_TIMEOUT])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"connect_out_time", @"连接超时"),
                              error.errorString,error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_CAS_MSG_PU_NO_RESOURCE])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"connect_device_limit", @"设备连接数过大"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_NOT_FOUND_RECORD_FILES])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"not_find_file", @"未找到录像文件"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_PARAM_ERROR])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"param_error", @"参数错误"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_URL_FORMAT_ERROR])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"play_url_format_wrong", @"播放url格式错误"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"play_fail", @"播放失败"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    
    NSLog(@"play error:%@(%ld)",error.errorString,(long)error.internalErrorCode);
}

- (void) EZUIPlayer:(EZUIPlayer *)player previewWidth:(CGFloat)pWidth previewHeight:(CGFloat)pHeight
{
    if (self.urlStrOhter)
    {
        CGFloat ratio = pWidth/pHeight;
        CGFloat destWidth = 0,destHeight = 0,px = 0,py = 0;
        if (ratio < 3/4)
        {
            destWidth = [UIScreen mainScreen].bounds.size.width;
            destHeight = destWidth/ratio;
            px = 0;
            py = ([UIScreen mainScreen].bounds.size.width/3*4-destHeight)/2;
        }
        else
        {
            destHeight = [UIScreen mainScreen].bounds.size.width/3*4;
            destWidth = destHeight*ratio;
            px = ([UIScreen mainScreen].bounds.size.width - destWidth)/2;
            py = 0;
        }
        
        [player setPreviewFrame:CGRectMake(px, py, destWidth, destHeight)];
    }
    else
    {
        CGFloat ratio = pWidth/pHeight;
        
        CGFloat destWidth = CGRectGetWidth(self.view.bounds);
        CGFloat destHeight = destWidth/ratio;
        
        [player setPreviewFrame:CGRectMake(0, CGRectGetMinY(player.previewView.frame), destWidth, destHeight)];
    }
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

- (void) switchBtnClick:(UIButton *) btn
{
    if (self.mPlayer && self.mPlayerOther)
    {
        self.mPlayer.previewView.hidden = !self.mPlayer.previewView.hidden;
        self.mPlayerOther.previewView.hidden = !self.mPlayerOther.previewView.hidden;
    }
}

#pragma mark - player

- (void) play
{
    if (self.mPlayer)
    {
        [self.mPlayer startPlay];
        
        if (self.mPlayerOther)
        {
            [self.mPlayerOther startPlay];
        }
        
        return;
    }
    
    self.mPlayer = [EZUIPlayer createPlayerWithUrl:self.urlStr];
    self.mPlayer.mDelegate = self;
//    self.mPlayer.customIndicatorView = nil;//去除加载动画
    self.mPlayer.previewView.frame = CGRectMake(0, 64,
                                                CGRectGetWidth(self.mPlayer.previewView.frame),
                                                CGRectGetHeight(self.mPlayer.previewView.frame));
    
    [self.view addSubview:self.mPlayer.previewView];
    
    //该处去除，调整到prepared回调中执行，如为预览模式也可直接调用startPlay
//    [self.mPlayer startPlay];
    
    if (self.urlStrOhter)
    {
        self.mPlayerOther = [EZUIPlayer createPlayerWithUrl:self.urlStrOhter];
        self.mPlayerOther.mDelegate = self;
        self.mPlayerOther.previewView.frame = CGRectMake(0, 64,
                                                         CGRectGetWidth(self.mPlayerOther.previewView.frame),
                                                         CGRectGetHeight(self.mPlayerOther.previewView.frame));
        self.mPlayerOther.previewView.hidden = YES;
        [self.view addSubview:self.mPlayerOther.previewView];
    }
}

- (void) stop
{
    if (self.mPlayer)
    {
        [self.mPlayer stopPlay];
    }
    
    if (self.mPlayerOther)
    {
        [self.mPlayerOther stopPlay];
    }
}

- (void) releasePlayer
{
    if (self.mPlayer)
    {
        [self.mPlayer.previewView removeFromSuperview];
        [self.mPlayer releasePlayer];
        self.mPlayer = nil;
    }
    
    if (self.mPlayerOther)
    {
        [self.mPlayerOther.previewView removeFromSuperview];
        [self.mPlayerOther releasePlayer];
        self.mPlayerOther = nil;
    }
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
        [self.mPlayerOther setPreviewFrame:frame];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
    
}


@end
