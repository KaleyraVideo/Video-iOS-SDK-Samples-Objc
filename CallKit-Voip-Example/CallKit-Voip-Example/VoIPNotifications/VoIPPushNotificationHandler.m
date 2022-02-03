//
// Copyright © 2018-Present. Kaleyra S.p.a. All Rights Reserved.
//

#import "VoIPPushNotificationHandler.h"
#import "ModernVoIPPushNotificationHandler.h"
#import "LegacyVoIPPushNotificationHandler.h"
#import "VoIPPushNotificationHandlerDelegate.h"

@interface VoIPPushNotificationHandler ()

@end

@implementation VoIPPushNotificationHandler

- (instancetype)initWithRegistryDelegate:(id<PKPushRegistryDelegate>)registryDelegate
                                delegate:(id<VoIPPushNotificationHandlerDelegate>)delegate
{
    self = [super initWithRegistryDelegate:registryDelegate];

    if (self)
    {
        if ([self isMemberOfClass:VoIPPushNotificationHandler.class])
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"This class is not meant to be instantiated directly, use one of its concrete subclasses"
                                         userInfo:nil];

        _delegate = delegate;
    }

    return self;
}

- (void)handleNotification:(PKPushPayload *)payload
{
    [self.delegate handle:payload];
}

+ (instancetype)handlerWithRegistryDelegate:(id<PKPushRegistryDelegate>)registryDelegate
                                   delegate:(id<VoIPPushNotificationHandlerDelegate>)delegate
{
    if (@available(iOS 13.0, *))
    {
        return [[ModernVoIPPushNotificationHandler alloc] initWithRegistryDelegate:registryDelegate
                                                                             delegate:delegate];
    } else
    {
        return [[LegacyVoIPPushNotificationHandler alloc] initWithRegistryDelegate:registryDelegate
                                                                             delegate:delegate];
    }
}

@end
