//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>

@interface MyFormatter : NSFormatter

- (NSString *)stringForItems:(NSArray<BDKUserInfoDisplayItem *> *)items eachItemPrecededBySymbol:(NSString *)symbol;
- (NSString *)stringForItem:(BDKUserInfoDisplayItem *)item precededBySymbol:(NSString *)symbol;

@end
