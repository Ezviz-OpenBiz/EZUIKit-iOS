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

    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *sdkVersion = [EZOpenSDK getVersion];
    self.versionLabel.text = [NSString stringWithFormat:@"v%@(SDK %@)",version,sdkVersion];
}

- (void) initParamsWithCache
{
    NSString *appKey = [self readStringWithKey:EZUIKitAppKey];
    NSString *accessToken = [self readStringWithKey:EZUIKitAccessToken];
    NSString *urlStr = [self readStringWithKey:EZUIKitUrlStr];
    
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
    [QRCodeScanViewController showQRCodeScanFrom:self resultBlock:^(NSString *appKey, NSString *accessToken, NSString *urlStr) {
        
        NSLog(@"=====appkey:%@,token:%@,url:%@.",appKey,accessToken,urlStr);
        
        [self stroeAppke:appKey accessToken:accessToken url:urlStr];
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
    }];
}

- (void) showPlayerControllerWithAppKey:(NSString *) appKey access:(NSString *) accessToken url:(NSString *) urlStr
{
    NSString *alertMsg = nil;
    if (!appKey || appKey.length == 0)
    {
        alertMsg = @"AppKey不能为空";
    }
    
    if (!accessToken || accessToken.length == 0)
    {
        if (!alertMsg)
        {
            alertMsg = @"accessToken不能为空";
        }
    }
    
    if (!urlStr || urlStr.length == 0)
    {
        if (!alertMsg)
        {
            alertMsg = @"播放url不能为空";
        }
    }
    
    if (alertMsg)
    {
        [self.view makeToast:alertMsg duration:1.5 position:@"center"];
        return;
    }

    [self stroeAppke:appKey accessToken:accessToken url:urlStr];

    if (self.playerSwitch.on && [EZUIPlayer getPlayModeWithUrl:urlStr] == EZUIKIT_PLAYMODE_REC)
    {
        EZUIKitPlaybackViewController *vc = [[EZUIKitPlaybackViewController alloc] init];
        vc.appKey = appKey;
        vc.accessToken = accessToken;
        vc.urlStr = urlStr;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        EZUIKitViewController *vc = [[EZUIKitViewController alloc] init];
        vc.appKey = appKey;
        vc.accessToken = accessToken;
        vc.urlStr = urlStr;
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
}

- (void) stroeAppke:(NSString *) appKey accessToken:(NSString *) token url:(NSString *) urlStr
{
    [self storeString:appKey key:EZUIKitAppKey];
    [self storeString:token key:EZUIKitAccessToken];
    [self storeString:urlStr key:EZUIKitUrlStr];
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"摄像头访问受限"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];

        [self presentViewController:alert animated:YES completion:nil];
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"知道了"
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
    CGFloat offset = CGRectGetMaxY(self.urlInput.frame) + 10 - (CGRectGetMaxY(self.view.bounds) - height);
    
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
                                     url:self.urlInput.text];
}

- (IBAction)clearBtnClick:(id)sender
{
    self.appKeyInput.text = nil;
    self.accessTokenInput.text = nil;
    self.urlInput.text = nil;
    
    [self clearCache];
}

#pragma mark - delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentInput = textField;
}



@end
