//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BDKUserDetails;

@interface MyFormatter : NSFormatter

- (NSString *)stringForItems:(NSArray<BDKUserDetails *> *)items eachItemPrecededBySymbol:(NSString *)symbol;
- (NSString *)stringForItem:(BDKUserDetails *)item precededBySymbol:(NSString *)symbol;

@end
