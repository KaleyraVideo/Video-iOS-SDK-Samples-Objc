//
// Copyright © 2018-Present. Kaleyra S.p.a. All Rights Reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VoIPPushNotificationHandlerDelegate <NSObject>

- (void)handle:(PKPushPayload *)payload;

@end

NS_ASSUME_NONNULL_END
