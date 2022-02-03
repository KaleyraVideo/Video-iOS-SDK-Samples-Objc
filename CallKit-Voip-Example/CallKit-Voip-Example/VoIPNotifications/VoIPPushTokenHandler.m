//
// Copyright © 2018-Present. Kaleyra S.p.a. All Rights Reserved.
//

#import "VoIPPushTokenHandler.h"
#import "LegacyVoIPPushTokenHandler.h"

@implementation VoIPPushTokenHandler

- (instancetype)initWithRegistryDelegate:(id <PKPushRegistryDelegate>)registryDelegate
{
    self = [super init];

    if (self)
    {
        _registryDelegate = registryDelegate;
    }

    return self;
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type
{
    [self.registryDelegate pushRegistry:registry didUpdatePushCredentials:pushCredentials forType:type];
}

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type
{
    if ([self.registryDelegate respondsToSelector:@selector(pushRegistry:didInvalidatePushTokenForType:)])
        [self.registryDelegate pushRegistry:registry didInvalidatePushTokenForType:type];
}

+ (instancetype)tokenHandlerWithRegistryDelegate:(id <PKPushRegistryDelegate>)delegate
{
    if (@available(iOS 11.0, *))
    {
        return [[VoIPPushTokenHandler alloc] initWithRegistryDelegate:delegate];
    } else
    {
        return [[LegacyVoIPPushTokenHandler alloc] initWithRegistryDelegate:delegate];
    }
}

@end
