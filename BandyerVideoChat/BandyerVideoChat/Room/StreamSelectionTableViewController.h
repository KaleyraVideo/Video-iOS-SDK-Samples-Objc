//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <UIKit/UIKit.h>
#import <BandyerCoreAV/BAVStream.h>

@class StreamSelectionTableViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol StreamSelectionTableViewControllerDelegate <NSObject>

- (void)streamSelectionController:(StreamSelectionTableViewController *)controller didSelectInfoForStream:(BAVStream *)stream;
- (void)streamSelectionController:(StreamSelectionTableViewController *)controller didSelectStream:(BAVStream *)stream;
- (void)streamSelectionController:(StreamSelectionTableViewController *)controller didDeselectStream:(BAVStream *)stream;

@end

@interface StreamSelectionTableViewController : UITableViewController

@property (nonatomic, weak) id<StreamSelectionTableViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray<BAVStream*> *streams;

@end

NS_ASSUME_NONNULL_END
