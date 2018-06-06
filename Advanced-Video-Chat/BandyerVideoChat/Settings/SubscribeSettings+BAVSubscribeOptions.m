//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import "SubscribeSettings+BAVSubscribeOptions.h"


@implementation SubscribeSettings (BAVSubscribeOptions)

- (BAVSubscribeOptions *)subscribeOptions
{
    BAVSubscribeOptions *options = [BAVSubscribeOptions new];

    options.audio = self.hasAudio;
    options.video = self.hasVideo;
    options.audioEnabled = self.hasAudioEnabled;
    options.videoEnabled = self.hasVideoEnabled;

    return options;
}

@end
