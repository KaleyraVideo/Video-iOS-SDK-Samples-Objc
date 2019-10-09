// Copyright © 2019 Bandyer. All rights reserved.
// See LICENSE for licensing information

#import "ContactsNavigationController.h"

//Here we subclass UINavigationController class in order to change preferredStatusBarStyle when the CallBannerView is showed.

@interface ContactsNavigationController ()

@property (nonatomic, assign) UIStatusBarStyle statusBarStyleBackup;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@end

@implementation ContactsNavigationController
{
    UIStatusBarStyle _statusBarStyle;
}

- (UIStatusBarStyle) statusBarStyle {
    return _statusBarStyle;
}

- (void)setStatusBarStyle:(UIStatusBarStyle)updatedStatusBarStyle {
    if (_statusBarStyle == updatedStatusBarStyle) return;
    _statusBarStyle = updatedStatusBarStyle;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (!self.statusBarStyle)
    {
        return super.preferredStatusBarStyle;
    }
    
    return self.statusBarStyle;
}

- (void)setStatusBarAppearance:(UIStatusBarStyle)style
{
    if (!self.statusBarStyleBackup) {
        self.statusBarStyleBackup = self.preferredStatusBarStyle;
    }
    
    self.statusBarStyle = style;
}

- (void)restoreStatusBarAppearance
{
    self.statusBarStyle = self.statusBarStyleBackup;
}

@end
