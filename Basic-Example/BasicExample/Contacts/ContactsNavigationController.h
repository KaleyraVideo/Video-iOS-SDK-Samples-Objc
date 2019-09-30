// Copyright © 2019 Bandyer. All rights reserved.
// See LICENSE for licensing information

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactsNavigationController : UINavigationController

- (void)setStatusBarAppearance:(UIStatusBarStyle)style;

- (void)restoreStatusBarAppearance;

@end

NS_ASSUME_NONNULL_END
