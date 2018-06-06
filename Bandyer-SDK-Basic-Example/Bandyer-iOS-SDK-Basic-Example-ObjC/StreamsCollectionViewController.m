// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

#import "StreamsCollectionViewController.h"
#import "StreamCollectionViewCell.h"

@interface StreamsCollectionViewController () <BAVRoomObserver, UICollectionViewDelegateFlowLayout, BAVSubscriberObserver>

@end

@implementation StreamsCollectionViewController

static NSString * const reuseIdentifier = @"remoteCellId";

- (void)setRoom:(BAVRoom *)room
{
    if (_room == room)
        return;

    [_room removeObserver:self];
    _room = room;
    [_room addObserver:self];
}

//-------------------------------------------------------------------------------------------
#pragma mark - View
//-------------------------------------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];

    //This view controller is responsible for showing the remote video feeds of the other participants publishing their streams in this room.
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"StreamCollectionViewCell" bundle:[NSBundle bundleForClass:self.class]] forCellWithReuseIdentifier:reuseIdentifier];
}

//-------------------------------------------------------------------------------------------
#pragma mark - UICollectionViewDataSource
//-------------------------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.room.subscribers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StreamCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    cell.videoView.stream = self.room.subscribers[indexPath.item].stream;
    [cell.videoView startRendering];

    return cell;
}

//-------------------------------------------------------------------------------------------
#pragma mark - UICollectionViewDelegate
//-------------------------------------------------------------------------------------------

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.room.subscribers.count == 1)
    {
        return collectionView.frame.size;
    }
    else if(self.room.subscribers.count == 2)
    {
        if(collectionView.bounds.size.width < collectionView.bounds.size.height)
            return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.height / 2);
        else
            return CGSizeMake(collectionView.bounds.size.width / 2 , collectionView.bounds.size.height);
    } else
    {
        return CGSizeMake(collectionView.bounds.size.width / 2 , collectionView.bounds.size.height / 2);
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Room Observer
//-------------------------------------------------------------------------------------------

- (void)roomDidConnect:(BAVRoom *)room
{
}

- (void)roomDidDisconnect:(BAVRoom *)room
{
}

- (void)room:(BAVRoom *)room didFailWithError:(NSError *)error
{
}

- (void)room:(BAVRoom *)room didAddStream:(BAVStream *)stream
{
}

- (void)room:(BAVRoom *)room didRemoveStream:(BAVStream *)stream
{
    [self.collectionView reloadData];
}

- (void)room:(BAVRoom *)room didAddSubscriber:(BAVSubscriber *)subscriber
{
    //When a new subscriber is added to the room we update our collection view
    //(we are adding a new subscriber any time a new remote stream is added to the room in the RoomViewController).
    [self.collectionView reloadData];

    [subscriber addObserver:self];
}

- (void)room:(BAVRoom *)room didRemoveSubscriber:(BAVSubscriber *)subscriber
{
    //When a subscriber is removed from the room we update our collection view.
    [self.collectionView reloadData];

    [subscriber removeObserver:self];
}

- (void)subscriberDidConnectToStream:(BAVSubscriber *)subscriber
{
    //Once the subscriber has connected to its stream successfully, we update the cell that is showing the remote video feed, starting the rendering process.
    NSInteger index = [self.room.subscribers indexOfObject:subscriber];

    if (index != NSNotFound)
    {
        StreamCollectionViewCell *cell = (StreamCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        [cell.videoView startRendering];
    }
}

- (void)subscriberDidDisconnectFromStream:(BAVSubscriber *)subscriber
{
    //Once the subscriber has disconnected from its stream  we update the cell that is showing the remote video feed, stopping the rendering process.
    NSInteger index = [self.room.subscribers indexOfObject:subscriber];

    if (index != NSNotFound)
    {
        StreamCollectionViewCell *cell = (StreamCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        [cell.videoView stopRendering];
    }
}

- (void)subscriber:(BAVSubscriber *)subscriber didFailWithError:(NSError *)error
{
    //Here, you have the chance to update your view showing an error message on a cell or prompt an alert to the user.
}


@end
