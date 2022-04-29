//
// Copyright © 2018-Present. Kaleyra S.p.a. All Rights Reserved.
//

#import "LegacyVoIPPushNotificationHandler.h"

@implementation LegacyVoIPPushNotificationHandler

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type
{
    [self handleNotification:payload];
}

@end
