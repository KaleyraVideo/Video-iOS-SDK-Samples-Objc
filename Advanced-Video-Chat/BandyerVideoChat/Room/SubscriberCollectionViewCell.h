//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <UIKit/UIKit.h>
#import <BandyerCoreAV/BAVVideoView.h>

@class BAVStream;
@class SubscriberCollectionViewCell;

@protocol SubscriberCollectionViewCellDelegate <NSObject>

@optional
- (void)subscriberCellDidTouchUnSubscribe:(SubscriberCollectionViewCell *)cell;
- (void)subscriberCellDidTouchVideoQuality:(SubscriberCollectionViewCell *)cell;
- (void)subscriberCellDidTouchVideoFittingMode:(SubscriberCollectionViewCell *)cell;
- (void)subscriberCellDidTouchInfo:(SubscriberCollectionViewCell *)cell;

@end

NS_ASSUME_NONNULL_BEGIN

@interface SubscriberCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) BAVStream *stream;
@property (nonatomic, assign) BAVVideoSizeFittingMode videoFittingMode;
@property (nonatomic, weak, nullable) id<SubscriberCollectionViewCellDelegate> delegate;

- (void)startRendering;
- (void)stopRendering;

@end

NS_ASSUME_NONNULL_END
