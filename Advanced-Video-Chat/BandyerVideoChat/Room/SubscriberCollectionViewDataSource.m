//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <BandyerCoreAV/BAVSubscriber.h>

#import "SubscriberCollectionViewDataSource.h"
#import "CollectionDataProvider.h"
#import "SubscriberCollectionViewCell.h"

#define SUBSCRIBER_CELL_ID @"subscriberCellId"

@interface SubscriberCollectionViewDataSource()

@property (nonatomic, strong) id<CollectionDataProvider> provider;
@property (nonatomic, weak) id<SubscriberCollectionViewCellDelegate> cellDelegate;

@end

@implementation SubscriberCollectionViewDataSource


- (instancetype)initWithDataProvider:(id <CollectionDataProvider>)provider subscriberCellDelegate:(id <SubscriberCollectionViewCellDelegate>)cellDelegate
{
    NSParameterAssert(provider);
    NSParameterAssert(cellDelegate);

    self = [super init];

    if(self)
    {
        _provider = provider;
        _cellDelegate = cellDelegate;
    }

    return self;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.provider.sectionsCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.provider itemCountInSection:section];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BAVSubscriber *subscriber = [self.provider itemAtIndexPath:indexPath];

    if(!subscriber)
        return nil;

    SubscriberCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SUBSCRIBER_CELL_ID forIndexPath:indexPath];
    cell.stream = subscriber.stream;
    cell.delegate = self.cellDelegate;
    [cell startRendering];

    return cell;
}


@end
