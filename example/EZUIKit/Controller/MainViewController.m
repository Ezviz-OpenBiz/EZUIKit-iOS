//
//  MainViewController.m
//  EZUIKit
//
//  Created by linyong on 2017/2/17.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MainViewController.h"
#import "EZUIKitViewController.h"
#import "EZUIKitPlaybackViewController.h"
#import "QRCodeScanViewController.h"
#import "EZOpenSDK.h"
#import "EZUIPlayer.h"
#import "Toast+UIView.h"

#define EZUIKitAppKey           @"EZUIKitAppKey"
#define EZUIKitAccessToken      @"EZUIKitAccessToken"
#define EZUIKitUrlStr           @"EZUIKitUrlStr"
#define EZUIKitApiUrl           @"EZUIKitApiUrl"

#define MAIN_TITLE @"EZUIKit Demo"

@implementation MainNavigationController

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

@end

@interface MainViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITextField *appKeyInput;
@property (weak, nonatomic) IBOutlet UITextField *accessTokenInput;
@property (weak, nonatomic) IBOutlet UITextField *urlInput;
@property (weak, nonatomic) IBOutlet UISwitch *playerSwitch;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *playBarLabel;
@property (weak, nonatomic) IBOutlet UILabel *globalLabel;
@property (weak, nonatomic) IBOutlet UILabel *ezopenUrlLabel;
@property (weak, nonatomic) IBOutlet UILabel *globalApiUrlLabel;
@property (weak, nonatomic) IBOutlet UITextField *apiInput;
@property (weak,nonatomic) UITextField *currentInput;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = MAIN_TITLE;
    
    [self initViews];
    [self addTouch];
    [self addNotification];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initParamsWithCache];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self requestCamera];
}

- (void) initViews
{
    self.appKeyInput.delegate = self;
    self.accessTokenInput.delegate = self;
    self.urlInput.delegate = self;
    self.apiInput.delegate = self;

    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *sdkVersion = [EZOpenSDK getVersion];
    self.versionLabel.text = [NSString stringWithFormat:@"v%@(SDK %@)",version,sdkVersion];
    
    [self.clearBtn setTitle:NSLocalizedString(@"clear_data", @"清除参数") forState:UIControlStateNormal];
    [self.scanBtn setTitle:NSLocalizedString(@"scan", @"扫一扫") forState:UIControlStateNormal];
    [self.playBtn setTitle:NSLocalizedString(@"start_play", @"开始播放") forState:UIControlStateNormal];
    self.playBarLabel.text = NSLocalizedString(@"playback_bar_switch", @"回放进度条开关");
    self.globalLabel.text = NSLocalizedString(@"global_switch", @"海外版");
    self.ezopenUrlLabel.text = NSLocalizedString(@"url_ezopen_protocal", @"3.Url (ezopen协议):");
    self.apiInput.hidden = !self.globalMode;
    self.globalApiUrlLabel.hidden = !self.globalMode;
}

- (void) initParamsWithCache
{
    NSString *appKey = [self readStringWithKey:EZUIKitAppKey];
    NSString *accessToken = [self readStringWithKey:EZUIKitAccessToken];
    NSString *urlStr = [self readStringWithKey:EZUIKitUrlStr];
    NSString *apiUrl = [self readStringWithKey:EZUIKitApiUrl];
    
    if (appKey)
    {
        self.appKeyInput.text = appKey;
    }
    
    if (accessToken)
    {
        self.accessTokenInput.text = accessToken;
    }
    
    if (urlStr)
    {
        self.urlInput.text = urlStr;
    }
    
    self.apiInput.text = apiUrl;
}

- (void) addTouch
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchCallback:)];
    
    [self.view addGestureRecognizer:tap];
}

- (void) addNotification
{
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
- (void) showQRCodeScanController
{
    [QRCodeScanViewController showQRCodeScanFrom:self resultBlock:^(NSString *appKey, NSString *accessToken, NSString *urlStr,NSString *apiUrl) {
        
        NSLog(@"=====appkey:%@,token:%@,url:%@,apiUrl:%@.",appKey,accessToken,urlStr,apiUrl);
        
        [self stroeAppke:appKey accessToken:accessToken url:urlStr apiUrl:apiUrl];
        if (appKey)
        {
            self.appKeyInput.text = appKey;
        }
        
        if (accessToken)
        {
            self.accessTokenInput.text = accessToken;
        }
        
        if (urlStr)
        {
            self.urlInput.text = urlStr;
        }
        
        self.apiInput.text = apiUrl;
    }];
}

- (void) showPlayerControllerWithAppKey:(NSString *) appKey access:(NSString *) accessToken url:(NSString *) urlStr apiUrl:(NSString *) apiUrl
{
    NSString *alertMsg = nil;
    if (!appKey || appKey.length == 0)
    {
        alertMsg = NSLocalizedString(@"app_key_msg", @"AppKey不能为空");
    }
    
    if (!accessToken || accessToken.length == 0)
    {
        if (!alertMsg)
        {
            alertMsg =NSLocalizedString(@"access_token_msg", @"accessToken不能为空");
        }
    }
    
    if (!urlStr || urlStr.length == 0)
    {
        if (!alertMsg)
        {
            alertMsg = NSLocalizedString(@"url_msg", @"播放url不能为空");
        }
    }
    
    if (self.globalMode &&(!apiUrl || apiUrl.length == 0))
    {
        if (!alertMsg)
        {
            alertMsg = NSLocalizedString(@"api_url_msg", @"服务器地址不能为空");
        }
    }
    
    if (alertMsg)
    {
        [self.view makeToast:alertMsg duration:1.5 position:@"center"];
        return;
    }

    [self stroeAppke:appKey accessToken:accessToken url:urlStr apiUrl:apiUrl];

    if (self.playerSwitch.on && [EZUIPlayer getPlayModeWithUrl:urlStr] == EZUIKIT_PLAYMODE_REC)
    {
        EZUIKitPlaybackViewController *vc = [[EZUIKitPlaybackViewController alloc] init];
        vc.appKey = appKey;
        vc.accessToken = accessToken;
        vc.urlStr = urlStr;
        if (self.globalMode)
        {
            vc.apiUrl = apiUrl;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        EZUIKitViewController *vc = [[EZUIKitViewController alloc] init];
        vc.appKey = appKey;
        vc.accessToken = accessToken;
        vc.urlStr = urlStr;
        if (self.globalMode)
        {
            vc.apiUrl = apiUrl;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSString *) readStringWithKey:(NSString *) key
{
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return value;
}

- (void) storeString:(NSString *) value key:(NSString *) key
{
    if (!value || !key || key.length <= 0)
    {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

- (void) clearCache
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:EZUIKitAppKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:EZUIKitAccessToken];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:EZUIKitUrlStr];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:EZUIKitApiUrl];
}

- (void) stroeAppke:(NSString *) appKey accessToken:(NSString *) token url:(NSString *) urlStr apiUrl:(NSString *) apiUrl
{
    [self storeString:appKey key:EZUIKitAppKey];
    [self storeString:token key:EZUIKitAccessToken];
    [self storeString:urlStr key:EZUIKitUrlStr];
    if (apiUrl)
    {
        [self storeString:apiUrl key:EZUIKitApiUrl];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:EZUIKitApiUrl];
    }
}

- (void) requestCamera
{
    NSString * mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    //摄像头已授权
    if (authorizationStatus == AVAuthorizationStatusAuthorized)
    {
        return;
    }
    
    //摄像头未授权
    if (authorizationStatus == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:nil];
        return;
    }
    
    //摄像头受限
    if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"allow_phone_camera", @"摄像头访问受限")
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];

        [self presentViewController:alert animated:YES completion:nil];
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:NSLocalizedString(@"know", @"知道了")
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction *action) {
                                                            [self dismissViewControllerAnimated:YES completion:nil];
                                                        }];
        [alert addAction:action];
    }
}

#pragma mark - notifications

//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.size.height;
    CGFloat offset = CGRectGetMaxY(self.apiInput.frame) + 10 - (CGRectGetMaxY(self.view.bounds) - height);
    
    NSNumber *durationNum = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGFloat duration = [durationNum floatValue];
    
    if (offset > 0)
    {
        [UIView animateWithDuration:duration animations:^{
            self.view.frame = CGRectMake(0,-offset, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        }];
    }
}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSNumber *durationNum = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGFloat duration = [durationNum floatValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    }];
}

#pragma mark - override

//只支持竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - actions

- (void) touchCallback:(id) sender
{
    if (!self.currentInput)
    {
        return;
    }
    
    [self.currentInput resignFirstResponder];
    self.currentInput = nil;
}

- (IBAction)scanBtnClick:(id)sender
{
    [self showQRCodeScanController];
}

- (IBAction)playBtnClick:(id)sender
{
    [self showPlayerControllerWithAppKey:self.appKeyInput.text
                                  access:self.accessTokenInput.text
                                     url:self.urlInput.text
                                  apiUrl:self.apiInput.text];
}

- (IBAction)clearBtnClick:(id)sender
{
    self.appKeyInput.text = nil;
    self.accessTokenInput.text = nil;
    self.urlInput.text = nil;
    self.apiInput.text = nil;
    
    [self clearCache];
}

#pragma mark - delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentInput = textField;
}



@end
