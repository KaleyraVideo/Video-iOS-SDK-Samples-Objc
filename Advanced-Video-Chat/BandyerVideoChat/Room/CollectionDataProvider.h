//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CollectionDataProvider <NSObject>

- (NSInteger)sectionsCount;
- (NSInteger)itemCountInSection:(NSInteger)section;
- (nullable id)itemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)indexPathForItem:(id)item;

@end

NS_ASSUME_NONNULL_END
