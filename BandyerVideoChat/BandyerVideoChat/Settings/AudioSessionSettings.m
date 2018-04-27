//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <BandyerFoundation/BandyerFoundation.h>
#import "AudioSessionSettings.h"

#define MANUAL_KEY @"manual"
#define OVERRIDE_TO_SPEAKER_KEY @"overrideToSpeaker"
#define OPTIONS_KEY @"options"

@implementation AudioSessionSettings

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _options = AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionAllowBluetoothA2DP | AVAudioSessionCategoryOptionAllowAirPlay;
        _manual = NO;
        _overrideToSpeaker = NO;
    }

    return self;
}

//-------------------------------------------------------------------------------------------
#pragma mark - NSCoding
//-------------------------------------------------------------------------------------------


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        self.options = (AVAudioSessionCategoryOptions) [coder decodeIntForKey:OPTIONS_KEY];
        self.manual = [coder decodeBoolForKey:MANUAL_KEY];
        self.overrideToSpeaker = [coder decodeBoolForKey:OVERRIDE_TO_SPEAKER_KEY];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:self.options forKey:OPTIONS_KEY];
    [coder encodeBool:self.manual forKey:MANUAL_KEY];
    [coder encodeBool:self.overrideToSpeaker forKey:OVERRIDE_TO_SPEAKER_KEY];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Public Interface
//-------------------------------------------------------------------------------------------

- (BOOL)hasOption:(AVAudioSessionCategoryOptions)option
{
    if(option == AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers)
        return (self.options & AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers) == AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers;
    else
        return self.options & option;
}

- (void)turnOnOption:(AVAudioSessionCategoryOptions)option
{
    self.options |= option;
}

- (void)turnOffOption:(AVAudioSessionCategoryOptions)option
{
    self.options &= ~option;
}

- (void)flipOption:(AVAudioSessionCategoryOptions)option
{
    self.options ^= option;
}

- (void)toggleOption:(AVAudioSessionCategoryOptions)option
{
    switch (option)
    {
        case AVAudioSessionCategoryOptionAllowBluetooth:
        case AVAudioSessionCategoryOptionAllowBluetoothA2DP:
        case AVAudioSessionCategoryOptionAllowAirPlay:
        case AVAudioSessionCategoryOptionDefaultToSpeaker:
            [self flipOption:option];
            break;
        case AVAudioSessionCategoryOptionMixWithOthers:
            [self flipOption:option];

            if(![self hasOption:AVAudioSessionCategoryOptionMixWithOthers])
            {
                [self turnOffOption:AVAudioSessionCategoryOptionDuckOthers];
                [self turnOffOption:AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers];
            }

            break;
        case AVAudioSessionCategoryOptionDuckOthers:
            [self flipOption:option];

            if([self hasOption:AVAudioSessionCategoryOptionDuckOthers])
                [self turnOnOption:AVAudioSessionCategoryOptionMixWithOthers];

            break;
        case AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers:

            if([self hasOption:AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers])
                [self turnOffOption:AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers];
            else
                [self turnOnOption:AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers];

            if([self hasOption:AVAudioSessionCategoryOptionDuckOthers] && ![self hasOption:AVAudioSessionCategoryOptionMixWithOthers])
                [self flipOption:AVAudioSessionCategoryOptionDuckOthers];

            break;
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Description
//-------------------------------------------------------------------------------------------

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"Options: %d", self.options];
    [description appendFormat:@", Manual: %@", BDFBoolToNSString(self.manual)];
    [description appendFormat:@", Override To Speaker: %@", BDFBoolToNSString(self.overrideToSpeaker)];
    [description appendString:@">"];
    return description;
}


@end
