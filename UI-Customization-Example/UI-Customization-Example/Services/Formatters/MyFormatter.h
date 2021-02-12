//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>

@class BDKUserDetails;

@interface MyFormatter : NSFormatter

- (NSString *)stringForItems:(NSArray<BDKUserDetails *> *)items eachItemPrecededBySymbol:(NSString *)symbol;
- (NSString *)stringForItem:(BDKUserDetails *)item precededBySymbol:(NSString *)symbol;

@end
