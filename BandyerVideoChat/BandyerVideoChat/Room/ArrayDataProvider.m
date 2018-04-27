//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <BandyerCoreAV/BAVSubscriber.h>

#import "ArrayDataProvider.h"

@interface ArrayDataProvider()

@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation ArrayDataProvider

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _data = [NSMutableArray new];
    }

    return self;
}


- (void)append:(id)item
{
    [self.data addObject:item];
}

- (void)remove:(id)item
{
    [self.data removeObject:item];
}

- (nullable id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    if(!indexPath)
        return nil;

    NSInteger section = indexPath.section;
    NSInteger index = indexPath.item;

    if(section == 0 && index < self.data.count)
        return self.data[index];

    return nil;
}

- (NSInteger)sectionsCount
{
    return 1;
}

- (NSInteger)itemCount
{
    return self.data.count;
}

- (NSInteger)itemCountInSection:(NSInteger)section
{
    if(section == 0)
        return [self itemCount];
    return 0;
}

- (nullable NSIndexPath *)indexPathForItem:(id)item
{
    NSUInteger index = [self.data indexOfObject:item];

    if(index == NSNotFound)
        return nil;

    return [NSIndexPath indexPathForItem:index inSection:0];
}

- (void)clear
{
    [self.data removeAllObjects];
}

@end
