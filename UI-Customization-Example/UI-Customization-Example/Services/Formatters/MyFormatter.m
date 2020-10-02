//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE.txt for licensing information
//

#import <Bandyer/Bandyer.h>

#import "MyFormatter.h"

@implementation MyFormatter
{
}

- (NSString *)stringForItems:(NSArray<BDKUserInfoDisplayItem *> *)items eachItemPrecededBySymbol:(NSString *)symbol
{
    NSMutableArray *mapped = [NSMutableArray arrayWithCapacity:[items count]];
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        NSString *mapObj = [self stringForItem:obj precededBySymbol:symbol];
        [mapped addObject:mapObj];
    }];
    return [mapped componentsJoinedByString:@" "];
}

- (NSString *)stringForItem:(BDKUserInfoDisplayItem *)item precededBySymbol:(NSString *)symbol
{
    NSString *value;
    if (item.lastName == nil && item.firstName == nil)
        value = item.alias;
    else
    {
        NSString* firstName = item.firstName ? item.firstName : @"";
        NSString* lastName = item.lastName ? item.lastName : @"";
        value = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
    return [NSString stringWithFormat:@"%@ %@", symbol, value];
}

@end


