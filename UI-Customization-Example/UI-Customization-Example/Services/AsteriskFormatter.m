//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE.txt for licensing information
//

#import <Bandyer/Bandyer.h>

#import "AsteriskFormatter.h"

@implementation AsteriskFormatter

- (NSString *)stringForObjectValue:(id)obj {
    
    NSArray<BDKUserInfoDisplayItem*>* items = (NSArray<BDKUserInfoDisplayItem*> *) obj;
    
    if (items) {
        BDKUserInfoDisplayItem * item = items.firstObject;
        if (item) {
            NSString* firstName = item.firstName ? item.firstName : @"";
            NSString* lastName = item.lastName ? item.lastName : @"";
            return [NSString stringWithFormat:@"%@ * %@", firstName, lastName];
        }
    }
    
    return nil;
}

@end
