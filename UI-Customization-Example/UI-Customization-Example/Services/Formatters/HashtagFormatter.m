//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE.txt for licensing information
//

#import "HashtagFormatter.h"

#import <Bandyer/Bandyer.h>

@implementation HashtagFormatter

- (NSString *)stringForObjectValue:(id)obj
{
    NSString *symbol = @"#";
    if ([obj isKindOfClass:[NSArray<BDKUserDetails*> class]])
    {
        NSArray<BDKUserDetails*>* items = (NSArray<BDKUserDetails*> *)obj;
        return [self stringForItems:items eachItemPrecededBySymbol:symbol];
    }

    if ([obj isKindOfClass:[BDKUserDetails class]])
    {
        BDKUserDetails *item = (BDKUserDetails *)obj;
        return [self stringForItem:item precededBySymbol:symbol];
    }

    return nil;
}

@end
