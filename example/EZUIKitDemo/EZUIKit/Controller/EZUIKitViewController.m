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
@property (nonatomic,strong) UIButton *playBtn;

@end

@implementation EZUIKitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [self.playBtn setTitle:@"停止" forState:UIControlStateSelected];
    self.playBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-80)/2, 400, 80, 40);
    [self.playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playBtn];
    
//    UIButton *releaseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    [releaseBtn setTitle:@"释放" forState:UIControlStateNormal];
//    releaseBtn.frame = CGRectMake(100, 400, 80, 40);
//    [releaseBtn addTarget:self action:@selector(releaseBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:releaseBtn];
    
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
    
    [EZUIKit initWithAppKey:self.appKey];
    [EZUIKit setAccessToken:self.accessToken];
    [self play];
    self.playBtn.selected = YES;
}

- (void)dealloc
{
    [self releasePlayer];
}

#pragma mark - player delegate

- (void) EZUIPlayerPlaySucceed:(EZUIPlayer *)player
{
    
}

- (void) EZUIPlayer:(EZUIPlayer *)player didPlayFailed:(EZUIError *) error
{
    [self stop];
    self.playBtn.selected = NO;
    
    if ([error.errorString isEqualToString:UE_ERROR_INNER_VERIFYCODE_ERROR])
    {
        [self.view makeToast:@"验证码错误" duration:1.5 position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_TRANSF_DEVICE_OFFLINE])
    {
        [self.view makeToast:@"设备不在线" duration:1.5 position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_CAMERA_NOT_EXIST] ||
             [error.errorString isEqualToString:UE_ERROR_DEVICE_NOT_EXIST])
    {
        [self.view makeToast:@"通道不存在" duration:1.5 position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_INNER_STREAM_TIMEOUT])
    {
        [self.view makeToast:@"连接超时" duration:1.5 position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_CAS_MSG_PU_NO_RESOURCE])
    {
        [self.view makeToast:@"设备连接数过大" duration:1.5 position:@"center"];
    }
    else
    {
        [self.view makeToast:@"播放失败" duration:1.5 position:@"center"];
    }
    
    NSLog(@"play error:%@(%ld)",error.errorString,error.internalErrorCode);
}

- (void) EZUIPlayer:(EZUIPlayer *)player previewWidth:(CGFloat)pWidth previewHeight:(CGFloat)pHeight
{
    CGFloat ratio = pWidth/pHeight;
    
    CGFloat destWidth = CGRectGetWidth(self.view.bounds);
    CGFloat destHeight = destWidth/ratio;
    
    [player setPreviewFrame:CGRectMake(0, 64, destWidth, destHeight)];
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

- (void) releaseBtnClick
{
    self.playBtn.selected = NO;
    [self releasePlayer];
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
//    self.mPlayer.customIndicatorView = nil;//去除加载动画
    self.mPlayer.previewView.frame = CGRectMake(0, 64,
                                                CGRectGetWidth(self.mPlayer.previewView.frame),
                                                CGRectGetHeight(self.mPlayer.previewView.frame));
    
    [self.view addSubview:self.mPlayer.previewView];
    
    [self.mPlayer startPlay];
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
