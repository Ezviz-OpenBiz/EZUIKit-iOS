//
//  EZUISelectViewController.m
//  EZUIKit
//
//  Created by linyong on 2017/9/15.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EZUISelectViewController.h"
#import "MainViewController.h"

@interface EZUISelectViewController ()
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *localBtn;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *internationalBtn;

@end

@implementation EZUISelectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.localBtn setTitle:NSLocalizedString(@"local_btn", @"国内版") forState:UIControlStateNormal];
    [self.internationalBtn setTitle:NSLocalizedString(@"global_btn", @"国际版") forState:UIControlStateNormal];

    // Do any additional setup after loading the view from its nib.
}

- (IBAction)localBtnClick:(id)sender
{
    [self showMainViewWithGlobalMode:NO];
}

- (IBAction)internationalBtnClick:(id)sender
{
    [self showMainViewWithGlobalMode:YES];
}

- (void) showMainViewWithGlobalMode:(BOOL) mode
{
    MainViewController *vc = [[MainViewController alloc] init];
    vc.globalMode = mode;
    MainNavigationController *nav = [[MainNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
