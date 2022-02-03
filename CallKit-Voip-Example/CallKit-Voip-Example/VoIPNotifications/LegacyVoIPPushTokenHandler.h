//
// Copyright © 2018-Present. Kaleyra S.p.a. All Rights Reserved.
//

#import "VoIPPushTokenHandler.h"

NS_ASSUME_NONNULL_BEGIN

API_DEPRECATED("This class workaround an issue with PKPushRegistryDelegate in iOS 10.x and below", ios(8.0, 10.0)) @interface LegacyVoIPPushTokenHandler : VoIPPushTokenHandler
@end

NS_ASSUME_NONNULL_END
