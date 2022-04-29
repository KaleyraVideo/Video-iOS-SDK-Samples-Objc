//
// Copyright © 2018-Present. Kaleyra S.p.a. All Rights Reserved.
//

#import "LegacyVoIPPushTokenHandler.h"

@implementation LegacyVoIPPushTokenHandler

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type
{
    // Even tough this method is marked as optional if a voip push notification is received on iOS 10 the registry will call this method anyway
    // To workaround this issue we implement this method with an empty implementation
    return;
}

@end
