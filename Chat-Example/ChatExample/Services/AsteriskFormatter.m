//
//  AsteriskFormatter.m
//  ChatExample
//
//  Created by Luca Tagliabue on 11/05/2020.
//  Copyright © 2020 Acme. All rights reserved.
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
