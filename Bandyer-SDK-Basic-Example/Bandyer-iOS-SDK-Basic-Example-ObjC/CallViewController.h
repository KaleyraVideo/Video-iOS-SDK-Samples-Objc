// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

#import <UIKit/UIKit.h>
#import <BandyerCommunicationCenter/BandyerCommunicationCenter.h>

@class CallViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol CallViewControllerDelegate <NSObject>

- (void)callControllerDidEnd:(CallViewController *)controller;

@end

@interface CallViewController : UIViewController

@property (nonatomic, strong) id<BCXCall> call;
@property (nonatomic, weak) id<CallViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
