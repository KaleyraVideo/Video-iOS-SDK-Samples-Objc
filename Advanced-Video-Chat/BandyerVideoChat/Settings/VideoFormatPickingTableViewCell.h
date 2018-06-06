//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <UIKit/UIKit.h>
#import <BandyerCoreAV/BAVVideoFormat.h>

@class VideoFormatPickingTableViewCell;

NS_ASSUME_NONNULL_BEGIN

@protocol VideoFormatPickingTableViewCellDelegate <NSObject>

- (void)cell:(VideoFormatPickingTableViewCell *)cell didSelectVideoFormat:(BAVVideoFormat *)format;

@end

@interface VideoFormatPickingTableViewCell : UITableViewCell

@property (nonatomic, weak, nullable) id<VideoFormatPickingTableViewCellDelegate> delegate;
@property (nonatomic, strong) BAVVideoFormat *videoFormat;

@end

NS_ASSUME_NONNULL_END
