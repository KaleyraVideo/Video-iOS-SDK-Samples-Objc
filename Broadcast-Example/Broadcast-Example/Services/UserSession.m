//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import "UserSession.h"


@implementation UserSession

#define USER_DEFAULTS_KEY @"com.acme.logged_user_id"

+ (nullable NSString *)currentUser
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY];
}

+ (void)setCurrentUser:(nullable NSString *)currentUser
{
    [[NSUserDefaults standardUserDefaults] setObject:currentUser forKey:USER_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
