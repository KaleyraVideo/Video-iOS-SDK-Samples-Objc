//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import "PublishSettings+BAVPublishOptions.h"


@implementation PublishSettings (BAVPublishOptions)

- (BAVPublishOptions *)publishOptions
{
    BAVPublishOptions *options = [BAVPublishOptions new];

    options.audio = self.hasAudio;
    options.video = self.hasVideo;
    options.audioEnabled = self.hasAudioEnabled;
    options.videoEnabled = self.hasVideoEnabled;

    return options;
}

@end
