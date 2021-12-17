//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import "CallOptionsItem.h"


@implementation CallOptionsItem

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _type = BDKCallTypeAudioVideo;
        _record = NO;
        _maximumDuration = 0;
    }

    return self;
}


- (id)copyWithZone:(nullable NSZone *)zone
{
    CallOptionsItem *copy = (CallOptionsItem *) [[[self class] allocWithZone:zone] init];

    if (copy != nil)
    {
        copy.type = self.type;
        copy.record = self.record;
        copy.maximumDuration = self.maximumDuration;
    }

    return copy;
}

@end
