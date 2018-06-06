//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CollectionDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface ArrayDataProvider <__covariant ObjectType> : NSObject <CollectionDataProvider>

- (void)append:(ObjectType)item;
- (void)remove:(ObjectType)item;
- (NSInteger)itemCount;
- (nullable ObjectType)itemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)indexPathForItem:(ObjectType)item;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
