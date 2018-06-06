// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

#import "RoundedButton.h"

@implementation RoundedButton


- (void)layoutSubviews
{
    [super layoutSubviews];

    self.layer.cornerRadius = (CGFloat) (MIN(self.bounds.size.width, self.bounds.size.height) / 2.0);
}


@end
