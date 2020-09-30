//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE.txt for licensing information
//

#import <UIKit/UIKit.h>

@class CallOptionsTableViewController;
@class CallOptionsItem;

NS_ASSUME_NONNULL_BEGIN

@protocol CallOptionsTableViewControllerDelegate <NSObject>

- (void)controllerDidUpdateOptions:(CallOptionsTableViewController *)controller;

@end

@interface CallOptionsTableViewController : UITableViewController

@property (nonatomic, weak, nullable) IBOutlet id <CallOptionsTableViewControllerDelegate> delegate;
@property (nonatomic, copy) CallOptionsItem *options;

@end

NS_ASSUME_NONNULL_END
