//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <BandyerFoundation/BandyerFoundationMacro.h>

#import "SubscribeSettings.h"


#define SUBSCRIBE_MODE_KEY @"mode"
#define AUDIO_KEY @"audio"
#define VIDEO_KEY @"video"
#define AUDIO_ENABLED_KEY @"audioEnabled"
#define VIDEO_ENABLED_KEY @"videoEnabled"

NSString *NSStringFromSubscribeMode(SubscribeMode mode) {
    switch (mode)
    {
        case SubscribeModeAuto:
            return @"Auto";
        case SubscribeModeManual:
            return @"Manual";
    }
    return @"Unknown";
}

@implementation SubscribeSettings

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _mode = SubscribeModeAuto;
        _audio = YES;
        _video = YES;
        _audioEnabled = YES;
        _videoEnabled = YES;
    }

    return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        self.mode = (SubscribeMode) [coder decodeIntForKey:SUBSCRIBE_MODE_KEY];
        self.audio = [coder decodeBoolForKey:AUDIO_KEY];
        self.video = [coder decodeBoolForKey:VIDEO_KEY];
        self.audioEnabled = [coder decodeBoolForKey:AUDIO_ENABLED_KEY];
        self.videoEnabled = [coder decodeBoolForKey:VIDEO_ENABLED_KEY];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:self.mode forKey:SUBSCRIBE_MODE_KEY];
    [coder encodeBool:self.audio forKey:AUDIO_KEY];
    [coder encodeBool:self.video forKey:VIDEO_KEY];
    [coder encodeBool:self.audioEnabled forKey:AUDIO_ENABLED_KEY];
    [coder encodeBool:self.videoEnabled forKey:VIDEO_ENABLED_KEY];
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"mode: %@", NSStringFromSubscribeMode(self.mode)];
    [description appendFormat:@", audio: %@", BDFBoolToNSString(self.audio)];
    [description appendFormat:@", video: %@", BDFBoolToNSString(self.video)];
    [description appendFormat:@", audioEnabled: %@", BDFBoolToNSString(self.audioEnabled)];
    [description appendFormat:@", videoEnabled: %@", BDFBoolToNSString(self.videoEnabled)];
    [description appendString:@">"];
    return description;
}


@end
