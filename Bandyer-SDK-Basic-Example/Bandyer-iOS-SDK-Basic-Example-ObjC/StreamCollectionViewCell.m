// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

#import <BandyerCoreAV/BandyerCoreAV.h>

#import "StreamCollectionViewCell.h"


@implementation StreamCollectionViewCell

- (void)prepareForReuse
{
    [super prepareForReuse];

    [self.videoView stopRendering];
}


@end
