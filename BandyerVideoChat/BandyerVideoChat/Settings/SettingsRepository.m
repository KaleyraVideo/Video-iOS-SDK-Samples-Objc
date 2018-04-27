//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <BandyerCoreAV/BAVVideoFormat.h>

#import "SettingsRepository.h"
#import "PublishSettings.h"
#import "SubscribeSettings.h"
#import "RoomSettings.h"
#import "AudioSessionSettings.h"

#define ROOM_SETTINGS_KEY @"RoomSettings"
#define PUBLISH_SETTINGS_KEY @"PublishSettings"
#define SUBSCRIBE_SETTINGS_KEY @"SubscribeSettings"
#define AUDIO_SESSION_SETTINGS_KEY @"AudioSessionSettings"
#define CAMERA_POSITION_SETTING_KEY @"CameraPositionSetting"
#define VIDEO_FORMAT_SETTINGS_KEY @"VideoFormatSetting"
#define VIDEO_FORMAT_WIDTH_KEY @"VideoFormatWidth"
#define VIDEO_FORMAT_HEIGHT_KEY @"VideoFormatHeight"
#define VIDEO_FORMAT_FPS_KEY @"VideoFormatFPS"

@interface SettingsRepository()

@property (nonatomic, strong) NSUserDefaults * userDefaults;

@end

@implementation SettingsRepository


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }

    return self;
}


- (void)storeCameraPosition:(AVCaptureDevicePosition)position
{
    [self.userDefaults setValue:@(position) forKey:CAMERA_POSITION_SETTING_KEY];
}

- (AVCaptureDevicePosition)retrieveCameraPosition
{
    return  (AVCaptureDevicePosition) [[self.userDefaults valueForKey:CAMERA_POSITION_SETTING_KEY] integerValue];
}

- (void)storeRoomSettings:(RoomSettings *)settings
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:settings];
    [self.userDefaults setObject:data forKey:ROOM_SETTINGS_KEY];
}

- (RoomSettings *)retrieveRoomSettings
{
    id data = [self.userDefaults objectForKey:ROOM_SETTINGS_KEY];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)storePublishSettings:(PublishSettings *)settings
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:settings];
    [self.userDefaults setObject:data forKey:PUBLISH_SETTINGS_KEY];
}

- (PublishSettings *)retrievePublishSettings
{
    id data = [self.userDefaults objectForKey:PUBLISH_SETTINGS_KEY];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)storeSubscribeSettings:(SubscribeSettings *)settings
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:settings];
    [self.userDefaults setObject:data forKey:SUBSCRIBE_SETTINGS_KEY];
}

- (SubscribeSettings *)retrieveSubscribeSettings
{
    id data = [self.userDefaults objectForKey:SUBSCRIBE_SETTINGS_KEY];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)storeAudioSessionSettings:(AudioSessionSettings *)settings
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:settings];
    [self.userDefaults setObject:data forKey:AUDIO_SESSION_SETTINGS_KEY];
}

- (AudioSessionSettings *)retrieveAudioSessionSettings
{
    id data = [self.userDefaults objectForKey:AUDIO_SESSION_SETTINGS_KEY];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}


- (BAVVideoFormat *)retrieveVideoFormat
{
    NSDictionary *formatSetting = [self.userDefaults valueForKey:VIDEO_FORMAT_SETTINGS_KEY];

    if(!formatSetting)
        return nil;

    NSUInteger width = [formatSetting[VIDEO_FORMAT_WIDTH_KEY] unsignedIntegerValue];
    NSUInteger height = [formatSetting[VIDEO_FORMAT_HEIGHT_KEY] unsignedIntegerValue];
    NSUInteger frameRate = [formatSetting[VIDEO_FORMAT_FPS_KEY] unsignedIntegerValue];

    return [BAVVideoFormat formatWithWidth:width height:height frameRate:frameRate];
}

- (void)storeVideoFormat:(BAVVideoFormat *)format
{
    [self.userDefaults setValue:@{
                    VIDEO_FORMAT_WIDTH_KEY : @(format.width),
                    VIDEO_FORMAT_HEIGHT_KEY : @(format.height),
                    VIDEO_FORMAT_FPS_KEY : @(format.frameRate)
            } 
                         forKey:VIDEO_FORMAT_SETTINGS_KEY];
}

- (void)flush
{
    [self.userDefaults synchronize];
}

- (void)registerDefaults
{
    [self.userDefaults registerDefaults:@{
            CAMERA_POSITION_SETTING_KEY : @(AVCaptureDevicePositionFront),
            VIDEO_FORMAT_SETTINGS_KEY : @{
                    VIDEO_FORMAT_WIDTH_KEY : @(640),
                    VIDEO_FORMAT_HEIGHT_KEY : @(480),
                    VIDEO_FORMAT_FPS_KEY : @(30)
            },
            PUBLISH_SETTINGS_KEY : [NSKeyedArchiver archivedDataWithRootObject:[PublishSettings new]],
            SUBSCRIBE_SETTINGS_KEY : [NSKeyedArchiver archivedDataWithRootObject:[SubscribeSettings new]],
            ROOM_SETTINGS_KEY : [NSKeyedArchiver archivedDataWithRootObject:[RoomSettings new]],
            AUDIO_SESSION_SETTINGS_KEY : [NSKeyedArchiver archivedDataWithRootObject:[AudioSessionSettings new]],
    }];
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static SettingsRepository *instance;

    dispatch_once (&onceToken, ^{
        instance = [SettingsRepository new];
    });

    return instance;
}


@end
