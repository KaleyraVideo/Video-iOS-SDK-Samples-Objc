//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import <Bandyer/Bandyer.h>

#import "AsteriskFormatter.h"

@implementation AsteriskFormatter

- (NSString *)stringForObjectValue:(id)obj
{
    if ([obj isKindOfClass:NSArray.class])
    {
        return [self stringForItems:obj];
    }

    if ([obj isKindOfClass:BDKUserDetails.class])
    {
        return [self stringForUserDetails:obj];
    }

    return nil;
}

- (nullable NSString *)stringForItems:(NSArray<BDKUserDetails *>*)items
{
    if (items == nil)
        return nil;

    if (items.count == 0)
        return nil;

    return [self stringForUserDetails:items.firstObject];
}

- (nullable NSString *)stringForUserDetails:(BDKUserDetails *)userDetails
{
    if (userDetails == nil)
        return nil;

    NSString* firstName = userDetails.firstname ? userDetails.firstname : @"";
    NSString* lastName = userDetails.lastname ? userDetails.lastname : @"";
    return [NSString stringWithFormat:@"%@ * %@", firstName, lastName];
}

@end
