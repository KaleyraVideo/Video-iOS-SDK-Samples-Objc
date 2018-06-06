//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <UIKit/UIKit.h>

@protocol CollectionDataProvider;
@protocol SubscriberCollectionViewCellDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface SubscriberCollectionViewDataSource : NSObject <UICollectionViewDataSource>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataProvider:(id <CollectionDataProvider>)provider subscriberCellDelegate:(id <SubscriberCollectionViewCellDelegate>)cellDelegate;

+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
