//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <UIKit/UIKit.h>
#import <BandyerCoreAV/BAVSubscribeOptions.h>

@class SubscribeOptionsSelectionTableViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol SubscribeOptionsSelectionTableViewControllerDelegate <NSObject>

- (void)subscribeOptionsSelectionController:(SubscribeOptionsSelectionTableViewController *)controller didChangeOptions:(BAVSubscribeOptions *)options;

@end

@interface SubscribeOptionsSelectionTableViewController : UITableViewController

@property (nonatomic, weak) id <SubscribeOptionsSelectionTableViewControllerDelegate> delegate;
@property (nonatomic, strong) BAVSubscribeOptions *options;

@end

NS_ASSUME_NONNULL_END
