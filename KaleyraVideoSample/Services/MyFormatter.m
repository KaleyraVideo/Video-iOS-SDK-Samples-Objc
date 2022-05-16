//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import <Bandyer/Bandyer.h>

#import "MyFormatter.h"

@implementation MyFormatter

- (NSString *)stringForItems:(NSArray<BDKUserDetails *> *)items eachItemPrecededBySymbol:(NSString *)symbol
{
    NSMutableArray *mapped = [NSMutableArray arrayWithCapacity:[items count]];
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        NSString *mapObj = [self stringForItem:obj precededBySymbol:symbol];
        [mapped addObject:mapObj];
    }];
    return [mapped componentsJoinedByString:@" "];
}

- (NSString *)stringForItem:(BDKUserDetails *)item precededBySymbol:(NSString *)symbol
{
    NSString *value;
    if (item.lastname == nil && item.firstname == nil)
    {
        value = item.userID;
    }
    else
    {
        NSString* firstName = item.firstname ? item.firstname : @"";
        NSString* lastName = item.lastname ? item.lastname : @"";
        value = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
    return [NSString stringWithFormat:@"%@ %@", symbol, value];
}

@end


