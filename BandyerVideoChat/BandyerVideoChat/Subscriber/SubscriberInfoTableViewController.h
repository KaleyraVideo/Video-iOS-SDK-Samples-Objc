//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <UIKit/UIKit.h>
#import <BandyerCoreAV/BAVSubscriber.h>

NS_ASSUME_NONNULL_BEGIN

@interface SubscriberInfoTableViewController : UITableViewController

@property (nonatomic, strong, nullable) BAVSubscriber *subscriber;

@end

NS_ASSUME_NONNULL_END
