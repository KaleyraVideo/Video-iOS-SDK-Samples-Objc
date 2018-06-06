//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class BAVVideoFormat;
@class PublishSettings;
@class SubscribeSettings;
@class RoomSettings;
@class AudioSessionSettings;

NS_ASSUME_NONNULL_BEGIN

@interface SettingsRepository : NSObject

- (void)storeCameraPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevicePosition)retrieveCameraPosition;

- (void)storeRoomSettings:(RoomSettings *)settings;
- (RoomSettings*)retrieveRoomSettings;

- (void)storePublishSettings:(PublishSettings *)settings;
- (PublishSettings *)retrievePublishSettings;

- (void)storeSubscribeSettings:(SubscribeSettings *)settings;
- (SubscribeSettings *)retrieveSubscribeSettings;

- (void)storeAudioSessionSettings:(AudioSessionSettings *)settings;
- (AudioSessionSettings *)retrieveAudioSessionSettings;

- (void)storeVideoFormat:(BAVVideoFormat *)format;
- (nullable BAVVideoFormat *)retrieveVideoFormat;
- (void)flush;
- (void)registerDefaults;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
