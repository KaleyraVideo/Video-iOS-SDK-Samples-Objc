//
// Copyright © 2018-Present. Kaleyra S.p.a. All Rights Reserved.
//

#import "VoIPPushNotificationHandlerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VoIPPushNotificationHandlerDelegate;

@protocol VoIPCallDetectorDelegate <NSObject, VoIPPushNotificationHandlerDelegate>

@optional

- (void)detectorDidStart;
- (void)detectorDidStop;


@end

NS_ASSUME_NONNULL_END


