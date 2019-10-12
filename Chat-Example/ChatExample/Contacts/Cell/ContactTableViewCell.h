//
//
//  Copyright © 2019 Bandyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContactTableViewCell;

NS_ASSUME_NONNULL_BEGIN

@protocol ContactTableViewCellDelegate <NSObject>

- (void)contactTableViewCell:(ContactTableViewCell * _Nonnull)cell didTouch:(UIButton * _Nonnull)chatButton withCounterpart:(NSString * _Nonnull)aliasId;

@end

@interface ContactTableViewCell : UITableViewCell

@property (nonatomic, weak, nullable) id <ContactTableViewCellDelegate> delegate;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, weak) IBOutlet UIButton *chatButton;

@end

NS_ASSUME_NONNULL_END
