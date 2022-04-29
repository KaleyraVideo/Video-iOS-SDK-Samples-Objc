//
// Copyright © 2018-Present. Kaleyra S.p.a. All Rights Reserved.
//

#import "VoIPPushTokenHandler.h"

@class VoIPPushNotificationHandler;
@protocol VoIPPushNotificationHandlerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface VoIPPushNotificationHandler : VoIPPushTokenHandler

@property (nonatomic, weak, readonly) id <VoIPPushNotificationHandlerDelegate> delegate;

+ (instancetype)handlerWithRegistryDelegate:(id <PKPushRegistryDelegate>)registryDelegate
                                   delegate:(id <VoIPPushNotificationHandlerDelegate>)delegate;

@end

@interface VoIPPushNotificationHandler (Protected)

- (instancetype)initWithRegistryDelegate:(id <PKPushRegistryDelegate>)registryDelegate
                                delegate:(id <VoIPPushNotificationHandlerDelegate>)delegate;

- (void)handleNotification:(PKPushPayload *)payload;

@end

NS_ASSUME_NONNULL_END
