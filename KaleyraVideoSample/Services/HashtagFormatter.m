//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import <Bandyer/Bandyer.h>

#import "HashtagFormatter.h"

//This formatter will print first name and last name preceded by an hashtag.
@implementation HashtagFormatter

- (NSString *)stringForObjectValue:(id)obj {
    
    NSArray<BDKUserDetails*>* items = (NSArray<BDKUserDetails*> *) obj;
    
    if (items != nil)
    {
        BDKUserDetails * user = items.firstObject;
        if (user != nil)
        {
            NSString* firstName = user.firstname ? user.firstname : @"";
            NSString* lastName = user.lastname ? user.lastname : @"";
            return [NSString stringWithFormat:@"#%@ #%@", firstName, lastName];
        }
    }
    
    return nil;
}

@end
