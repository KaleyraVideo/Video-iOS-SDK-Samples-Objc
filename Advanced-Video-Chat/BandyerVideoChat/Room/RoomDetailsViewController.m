//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <BandyerCoreAV/BAVRoom.h>
#import <BandyerCoreAV/BAVRoomProperties.h>
#import <BandyerCoreAV/BAVStream.h>
#import <BandyerCoreAV/BAVPublisher.h>
#import <BandyerCoreAV/BAVSubscriber.h>

#import "RoomDetailsViewController.h"
#import "StreamDetailTableViewCell.h"
#import "StreamInfoTableViewController.h"
#import "SubscriberInfoTableViewController.h"
#import "PublisherInfoTableViewController.h"

#define ROOM_CELL_ID @"roomCellId"
#define STREAM_CELL_ID @"streamCellId"
#define PUBLISHER_CELL_ID @"publisherCellId"
#define SUBSCRIBER_CELL_ID @"subscriberCellId"
#define SHOW_STREAM_SEGUE_ID @"showStreamInfoSegueId"
#define SHOW_SUBSCRIBER_SEGUE_ID @"showSubscriberInfoSegueId"
#define SHOW_PUBLISHER_INFO_SEGUE @"showPublisherInfoSegue"


typedef NS_ENUM(NSInteger, RoomDetailsSection)
{
    RoomDetailsInfoSection = 0,
    RoomDetailsStreamsSection,
    RoomDetailsPublishersSection,
    RoomDetailsSubscribersSection,
};

typedef NS_ENUM(NSInteger, RoomInfoSectionRow)
{
    RoomInfoSectionStateRow = 0,
    RoomInfoSectionRoomIdRow,
    RoomInfoSectionSessionIdRow,
    RoomInfoSectionRoomTypeRow,
};

@interface RoomDetailsViewController () <BAVRoomObserver>

@property (nonatomic, weak) BAVStream *selectedStream;
@property (nonatomic, weak) BAVSubscriber *selectedSubscriber;

@end

@implementation RoomDetailsViewController


- (void)setRoom:(BAVRoom *)room
{
    [_room removeObserver:self];
    _room = room;
    [_room addObserver:self];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Table Data Source
//-------------------------------------------------------------------------------------------


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == RoomDetailsInfoSection)
        return @"Info";
    else if (section == RoomDetailsStreamsSection)
        return @"Streams";
    else if (section == RoomDetailsPublishersSection)
        return @"Publishers";
    else if (section == RoomDetailsSubscribersSection)
        return @"Subscribers";
    else
        return nil;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == RoomDetailsStreamsSection && self.room.streams.count == 0)
        return @"There are no streams at the moment";

    if (section == RoomDetailsSubscribersSection && self.room.subscribers.count == 0)
        return @"There are no subscribers at the moment";

    if (section == RoomDetailsPublishersSection && self.room.publisher == nil)
        return @"There are no publishers at the moment";

    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == RoomDetailsInfoSection)
        return 4;
    else if (section == RoomDetailsStreamsSection)
        return self.room.streams.count;
    else if (section == RoomDetailsPublishersSection)
        return self.room.publisher ? 1 : 0;
    else if (section == RoomDetailsSubscribersSection)
        return self.room.subscribers.count;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];

    if (section == RoomDetailsInfoSection)
        return [self tableView:tableView cellForInfoSectionAtRow:row];
    else if (section == RoomDetailsStreamsSection)
        return [self tableView:tableView cellForStreamsSectionAtRow:row];
    else if (section == RoomDetailsPublishersSection)
        return [self tableView:tableView cellForPublishersSectionAtRow:row];
    else if (section == RoomDetailsSubscribersSection)
        return [self tableView:tableView cellForSubscribersSectionAtRow:row];

    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForInfoSectionAtRow:(NSInteger)row
{
    UITableViewCell *cell;
    RoomInfoSectionRow sectionRow = (RoomInfoSectionRow) row;
    switch (sectionRow)
    {
        case RoomInfoSectionStateRow:
            cell = [tableView dequeueReusableCellWithIdentifier:ROOM_CELL_ID];
            cell.textLabel.text = @"State:";
            cell.detailTextLabel.text = self.room ? NSStringFromBAVRoomState(self.room.state) : @"Unknown";
            break;
        case RoomInfoSectionRoomIdRow:
            cell = [tableView dequeueReusableCellWithIdentifier:ROOM_CELL_ID];
            cell.textLabel.text = @"Room Id:";
            cell.detailTextLabel.text = self.room.properties.roomId ?: @"N/A";
            break;
        case RoomInfoSectionSessionIdRow:
            cell = [tableView dequeueReusableCellWithIdentifier:ROOM_CELL_ID];
            cell.textLabel.text = @"Session Id:";
            cell.detailTextLabel.text = self.room.properties.sessionId ?: @"N/A";
            break;
        case RoomInfoSectionRoomTypeRow:
            cell = [tableView dequeueReusableCellWithIdentifier:ROOM_CELL_ID];
            cell.textLabel.text = @"Type:";
            cell.detailTextLabel.text = NSStringFromBAVRoomType(self.room.properties.roomType);
            break;
    }

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForStreamsSectionAtRow:(NSInteger)row
{
    if (row >= self.room.streams.count)
        return nil;

    BAVStream *stream = self.room.streams[row];
    StreamDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:STREAM_CELL_ID];
    cell.identifierLabel.text = stream.streamId;

    cell.audioLabel.text = stream.hasAudio ? @"With Audio" : @"No audio";
    cell.videoLabel.text = stream.hasVideo ? @"With Video" : @"No video";

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForPublishersSectionAtRow:(NSInteger)row
{
    __kindof UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PUBLISHER_CELL_ID];

    BAVPublisher *pub = self.room.publisher;
    cell.textLabel.text = pub.stream.streamId ?: @"N/A";
    cell.detailTextLabel.text = NSStringFromBAVPublisherState(pub.state);

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubscribersSectionAtRow:(NSInteger)row
{
    __kindof UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SUBSCRIBER_CELL_ID];

    if (row >= self.room.subscribers.count)
        return nil;

    BAVSubscriber *sub = self.room.subscribers[row];
    cell.textLabel.text = sub.stream.streamId ?: @"N/A";
    cell.detailTextLabel.text = NSStringFromBAVSubscriberState(sub.state);

    return cell;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Table Delegate
//-------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    if (section == RoomDetailsStreamsSection)
    {
        if (row >= self.room.streams.count)
            return;

        self.selectedStream = self.room.streams[row];
        [self performSegueWithIdentifier:SHOW_STREAM_SEGUE_ID sender:self];
    } else if (section == RoomDetailsSubscribersSection)
    {
        if (row >= self.room.subscribers.count)
            return;

        self.selectedSubscriber = self.room.subscribers[row];
        [self performSegueWithIdentifier:SHOW_SUBSCRIBER_SEGUE_ID sender:self];
    } else if (section == RoomDetailsPublishersSection)
    {
        [self performSegueWithIdentifier:SHOW_PUBLISHER_INFO_SEGUE sender:self];
    }
}


//-------------------------------------------------------------------------------------------
#pragma mark - Segue
//-------------------------------------------------------------------------------------------

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender
{
    if ([segue.identifier isEqualToString:SHOW_STREAM_SEGUE_ID])
    {
        StreamInfoTableViewController *controller = segue.destinationViewController;
        controller.stream = self.selectedStream;
    } else if ([segue.identifier isEqualToString:SHOW_SUBSCRIBER_SEGUE_ID])
    {
        SubscriberInfoTableViewController *controller = segue.destinationViewController;
        controller.subscriber = self.selectedSubscriber;
    } else if ([segue.identifier isEqualToString:SHOW_PUBLISHER_INFO_SEGUE])
    {
        PublisherInfoTableViewController *controller = segue.destinationViewController;
        controller.publisher = self.room.publisher;
    }
}


//-------------------------------------------------------------------------------------------
#pragma mark - Room Observer
//-------------------------------------------------------------------------------------------


- (void)roomDidConnect:(BAVRoom *)room
{
    [self reloadInfoSection];
}

- (void)roomDidDisconnect:(BAVRoom *)room
{
    [self reloadInfoSection];
}

- (void)room:(BAVRoom *)room didFailWithError:(NSError *)error
{
    [self reloadInfoSection];
}

- (void)room:(BAVRoom *)room didAddStream:(BAVStream *)stream
{
    [self reloadStreamSection];
}

- (void)room:(BAVRoom *)room didRemoveStream:(BAVStream *)stream
{
    [self reloadStreamSection];
}

- (void)room:(BAVRoom *)room didAddPublisher:(BAVPublisher *)publisher
{
    [self reloadPublishersSection];
}

- (void)room:(BAVRoom *)room didRemovePublisher:(BAVPublisher *)publisher
{
    [self reloadPublishersSection];
}

- (void)room:(BAVRoom *)room didAddSubscriber:(BAVSubscriber *)subscriber
{
    [self reloadSubscribersSection];
}

- (void)room:(BAVRoom *)room didRemoveSubscriber:(BAVSubscriber *)subscriber
{
    [self reloadSubscribersSection];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Reload Sections
//-------------------------------------------------------------------------------------------


- (void)reloadInfoSection
{
    [self.tableView reloadData];
}

- (void)reloadStreamSection
{
    [self.tableView reloadData];
}

- (void)reloadPublishersSection
{
    [self.tableView reloadData];
}

- (void)reloadSubscribersSection
{
    [self.tableView reloadData];
}

@end
