//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PublishMode)
{
    PublishModeAuto = 0,
    PublishModeManual
};

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *NSStringFromPublishMode(PublishMode mode);

@interface PublishSettings : NSObject <NSCoding>

@property (nonatomic, assign) PublishMode mode;
@property (nonatomic, assign, getter=hasAudio) BOOL audio;
@property (nonatomic, assign, getter=hasVideo) BOOL video;
@property (nonatomic, assign, getter=hasAudioEnabled) BOOL audioEnabled;
@property (nonatomic, assign, getter=hasVideoEnabled) BOOL videoEnabled;

@end

NS_ASSUME_NONNULL_END
