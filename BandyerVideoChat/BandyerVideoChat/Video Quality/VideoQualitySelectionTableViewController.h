//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <UIKit/UIKit.h>
#import <BandyerCoreAV/BAVVideoQuality.h>

@class VideoQualitySelectionTableViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol VideoQualitySelectionTableViewControllerDelegate <NSObject>

- (void)videoQualitySelectionController:(VideoQualitySelectionTableViewController *)controller didSelectQuality:(BAVVideoQuality *)quality;

@end

@interface VideoQualitySelectionTableViewController : UITableViewController

@property (nonatomic, weak, nullable) id<VideoQualitySelectionTableViewControllerDelegate> delegate;
@property (nonatomic, strong) BAVVideoQuality *quality;

@end

NS_ASSUME_NONNULL_END
