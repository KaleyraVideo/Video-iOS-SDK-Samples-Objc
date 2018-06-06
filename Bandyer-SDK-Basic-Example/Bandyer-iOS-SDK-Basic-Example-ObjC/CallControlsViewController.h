// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

#import <UIKit/UIKit.h>
#import <BandyerCommunicationCenter/BandyerCommunicationCenter.h>

NS_ASSUME_NONNULL_BEGIN

@interface CallControlsViewController : UIViewController

@property (nonatomic, strong) id<BCXCall> call;

@end

NS_ASSUME_NONNULL_END
