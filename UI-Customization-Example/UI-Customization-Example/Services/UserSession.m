//
// Copyright © 2020 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information
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
