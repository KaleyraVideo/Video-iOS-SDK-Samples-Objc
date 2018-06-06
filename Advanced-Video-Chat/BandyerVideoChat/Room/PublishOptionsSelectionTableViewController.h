//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <UIKit/UIKit.h>
#import <BandyerCoreAV/BAVPublishOptions.h>

@class PublishOptionsSelectionTableViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol PublishOptionsSelectionTableViewControllerDelegate <NSObject>

- (void)publishOptionsSelectionController:(PublishOptionsSelectionTableViewController *)controller didChangeOptions:(BAVPublishOptions *)options;

@end

@interface PublishOptionsSelectionTableViewController : UITableViewController

@property (nonatomic, weak) id <PublishOptionsSelectionTableViewControllerDelegate> delegate;
@property (nonatomic, strong) BAVPublishOptions *options;

@end

NS_ASSUME_NONNULL_END
