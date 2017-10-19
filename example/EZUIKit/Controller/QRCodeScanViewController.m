//
//  QRCodeScanViewController.m
//  EZUIKit
//
//  Created by linyong on 2017/2/17.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "QRCodeScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "EZQRView.h"

@interface QRCodeScanViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong,nonatomic) AVCaptureDevice * device;
@property (strong,nonatomic) AVCaptureDeviceInput * input;
@property (strong,nonatomic) AVCaptureMetadataOutput * output;
@property (strong,nonatomic) AVCaptureSession * session;
@property (strong,nonatomic) AVCaptureVideoPreviewLayer * preview;
@property (copy,nonatomic)  QRCodeResult resultBlock;
@property (assign,nonatomic) AVAuthorizationStatus authStatus;
@property (weak, nonatomic) IBOutlet EZQRView *qrView;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;
@property (weak, nonatomic) IBOutlet UILabel *scanLabel;

@end

@implementation QRCodeScanViewController

+ (void) showQRCodeScanFrom:(UIViewController *) fromVc
                resultBlock:(QRCodeResult) resultBlock
{
    
    if (!fromVc.navigationController)
    {
        NSLog(@"error need navigation controller");
        return;
    }
    
    QRCodeScanViewController *vc = [[QRCodeScanViewController alloc] init];
    vc.resultBlock = resultBlock;
    [fromVc.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"scan_qr", @"扫描二维码");
    
    self.scanLabel.text = NSLocalizedString(@"scan_qr", @"扫描二维码");
    
    _authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (_authStatus == AVAuthorizationStatusAuthorized)
    {
        [self qrSetup];
    }
    else if (_authStatus == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                 completionHandler:^(BOOL granted) {
                                     if (granted)
                                     {
                                         [self qrSetup];
                                         [self qrStart];
                                     }
                                 }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", @"提示")
                                                        message:NSLocalizedString(@"allow_camera_tip", @"请在设备的`设置-隐私-相机`中允许访问相机。")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"done", @"确定")
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    self.qrView.hidden = YES;
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_authStatus == AVAuthorizationStatusDenied ||
        _authStatus == AVAuthorizationStatusRestricted) {
        return;
    }
    
    [self qrStart];
}

- (void) qrSetup
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity =AVLayerVideoGravityResizeAspectFill;
    _preview.frame = [UIScreen mainScreen].bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
}

- (void) qrStart
{
    if (_authStatus == AVAuthorizationStatusDenied ||
        _authStatus == AVAuthorizationStatusRestricted) {
        return;
    }
    [_session startRunning];
    
    _preview.frame = CGRectMake(0, 64, self.qrView.bounds.size.width, self.qrView.bounds.size.height);
    
    //修正扫描区域
    CGFloat screenHeight = self.qrView.frame.size.height;
    CGFloat screenWidth = self.qrView.frame.size.width;
    CGRect cropRect = CGRectMake((screenWidth - 240.0)/2, (screenHeight - 240.0)/3, 240.0, 240.0);
    
    [_output setRectOfInterest:CGRectMake(cropRect.origin.y/screenHeight,
                                          cropRect.origin.x/screenWidth,
                                          cropRect.size.height/screenHeight,
                                          cropRect.size.width/screenWidth)];
    
    [self addLineAnimation];
    self.qrView.hidden = NO;
}

- (void) addLineAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64.0;
    animation.fromValue = @(height/3.0 - 240);
    animation.toValue = @(height/3.0 - 80);
    animation.duration = 3.0f;
    animation.repeatCount = HUGE_VALF;
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    
    [_lineImageView.layer addAnimation:animation forKey:nil];
}

- (IBAction)torchButtonClicked:(id)sender
{
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    UIButton *btn = (UIButton*) sender;
    if ([captureDevice hasTorch]) {
        int nTorchMode = captureDevice.torchMode;
        nTorchMode ++;
        nTorchMode = nTorchMode > 1 ? 0 : nTorchMode;
        
        [captureDevice lockForConfiguration:nil];
        captureDevice.torchMode = nTorchMode;
        [captureDevice unlockForConfiguration];
        
        switch (nTorchMode)
        {
            case 0:
            {
                btn.selected = NO;
            }
            break;
            
            case 1:
            {
                btn.selected = YES;
            }
            break;
            default:
            break;
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] > 0)
    {
        //停止扫描
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[stringValue dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:kNilOptions
                                                                  error:nil];
        
        [self.navigationController popViewControllerAnimated:YES];

        if (self.resultBlock && jsonDic)
        {
            self.resultBlock(jsonDic[@"AppKey"],jsonDic[@"AccessToken"],jsonDic[@"Url"],jsonDic[@"apiUrl"]);
        }
    }
}

#pragma mark - override

//只支持竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
