//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioSessionSettings : NSObject <NSCoding>

@property (nonatomic, assign) AVAudioSessionCategoryOptions options;
@property (nonatomic, assign, getter=isManual) BOOL manual;
@property (nonatomic, assign, getter=overridesToSpeaker) BOOL overrideToSpeaker;

- (BOOL)hasOption:(AVAudioSessionCategoryOptions)option;
- (void)turnOnOption:(AVAudioSessionCategoryOptions)option;
- (void)turnOffOption:(AVAudioSessionCategoryOptions)option;
- (void)toggleOption:(AVAudioSessionCategoryOptions)option;

@end

NS_ASSUME_NONNULL_END
