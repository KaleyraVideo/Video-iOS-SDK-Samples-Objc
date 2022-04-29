//
// Copyright © 2018-Present. Kaleyra S.p.a. All Rights Reserved.
//

#import "ModernVoIPPushNotificationHandler.h"

@implementation ModernVoIPPushNotificationHandler

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion
{
    [self handleNotification:payload];

    completion();
}

@end
