//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <UIKit/UIKit.h>

#import <BandyerCoreAV/BAVVideoView.h>

@class VideoModeSelectionTableViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol VideoModeSelectionTableViewControllerDelegate <NSObject>

- (void)videoModeSelectionController:(VideoModeSelectionTableViewController *)controller didChangeVideoFittingMode:(BAVVideoSizeFittingMode)mode;

@end

@interface VideoModeSelectionTableViewController : UITableViewController

@property (nonatomic, weak, nullable) id<VideoModeSelectionTableViewControllerDelegate> delegate;
@property (nonatomic, assign) BAVVideoSizeFittingMode videoFittingMode;

@end

NS_ASSUME_NONNULL_END
