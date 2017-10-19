//
//  QRCodeScanViewController.h
//  EZUIKit
//
//  Created by linyong on 2017/2/17.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef  void (^QRCodeResult)(NSString *appKey,NSString *accessToken,NSString *urlStr,NSString *apiUrl);

@interface QRCodeScanViewController : UIViewController

+ (void) showQRCodeScanFrom:(UIViewController *) fromVc
                resultBlock:(QRCodeResult) resultBlock;


@end
