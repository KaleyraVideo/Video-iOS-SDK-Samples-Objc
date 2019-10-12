//
//
//  Copyright © 2019 Bandyer. All rights reserved.
//

#import "ContactTableViewCell.h"

@implementation ContactTableViewCell

//-------------------------------------------------------------------------------------------
#pragma mark - IBActions
//-------------------------------------------------------------------------------------------

- (IBAction)didTouchChatButton:(UIButton *)sender
{
    if (self.subtitleLabel.text) {
        [self.delegate contactTableViewCell:self didTouch:sender withCounterpart:self.subtitleLabel.text];
    }
}

@end
