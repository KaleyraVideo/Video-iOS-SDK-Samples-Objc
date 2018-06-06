//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailedStreamTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *streamIdLabel;
@property (nonatomic, weak) IBOutlet UILabel *publisherDetailLabel;
@property (nonatomic, weak) IBOutlet UIStackView *mediaStackView;
@property (nonatomic, weak) IBOutlet UIImageView *audioImageView;
@property (nonatomic, weak) IBOutlet UIImageView *videoImageView;
@end

NS_ASSUME_NONNULL_END
