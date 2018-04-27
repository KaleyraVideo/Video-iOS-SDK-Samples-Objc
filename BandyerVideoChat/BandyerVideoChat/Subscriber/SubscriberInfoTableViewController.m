//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <BandyerCoreAV/BAVStream.h>
#import <BandyerCoreAV/BAVSubscribeOptions.h>
#import <BandyerCoreAV/BAVVideoQuality.h>

#import "SubscriberInfoTableViewController.h"
#import "StreamInfoTableViewController.h"
#import "VideoQualitySelectionTableViewController.h"

typedef NS_ENUM(NSInteger, SubscriberInfoSections)
{
    SubscriberInfoStateSection = 0,
    SubscriberInfoStreamSection,
    SubscriberInfoVideoQualitySection
};

typedef NS_ENUM(NSInteger, SubscriberStateSectionRows)
{
    SubscriberStateSectionStateRow = 0,
    SubscriberStateSectionAudioRow,
    SubscriberStateSectionVideoRow,
};

typedef NS_ENUM(NSInteger, SubscriberVideoQualitySectionRows)
{
    SubscriberVideoQualitySectionSpatialRow = 0,
    SubscriberVideoQualitySectionTemporalRow,
};

#define CELL_ID @"rightDetailCellId"

#define SHOW_STREAM_INFO_SEGUE_ID @"showStreamInfoSegueId"

#define SHOW_VIDEO_QUALITY_SELECTION_SEGUE @"showVideoQualitySelectionSegue"

@interface SubscriberInfoTableViewController () <BAVSubscriberObserver, VideoQualitySelectionTableViewControllerDelegate>

@end

@implementation SubscriberInfoTableViewController

- (void)setSubscriber:(BAVSubscriber *)subscriber
{
    [_subscriber removeObserver:self];
    _subscriber = subscriber;
    [_subscriber addObserver:self];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Table Datasource
//-------------------------------------------------------------------------------------------


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch ((SubscriberInfoSections)section)
    {
        case SubscriberInfoStateSection:
            return 3;
        case SubscriberInfoStreamSection:
            return 1;
        case SubscriberInfoVideoQualitySection:
            return 2;
    }
    return 0;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch ((SubscriberInfoSections)section)
    {
        case SubscriberInfoStateSection:
            return @"State";
        case SubscriberInfoStreamSection:
            return @"Stream";
        case SubscriberInfoVideoQualitySection:
            return @"Video Quality";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];

    switch((SubscriberInfoSections)section)
    {
        case SubscriberInfoStateSection:
            [self configureCell:cell forInfoSectionAtRow:row];
            break;
        case SubscriberInfoStreamSection:
            [self configureCell:cell forStreamSectionAtRow:row];
            break;
        case SubscriberInfoVideoQualitySection:
            [self configureCell:cell forQualitySectionAtRow:row];
            break;
    }

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forInfoSectionAtRow:(NSInteger)row
{
    NSString *title;
    NSString *detail;
    UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;

    switch ((SubscriberStateSectionRows)row)
    {
        case SubscriberStateSectionStateRow:
            title = @"State:";
            detail = NSStringFromBAVSubscriberState(self.subscriber.state);
            break;
        case SubscriberStateSectionAudioRow:
            title = @"Subscribe to Audio:";
            accessoryType = self.subscriber.subscribeOptions.hasAudio ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        case SubscriberStateSectionVideoRow:
            title = @"Subscribe to Video:";
            accessoryType = self.subscriber.subscribeOptions.hasVideo ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
    }

    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
    cell.accessoryType = accessoryType;
}

- (void)configureCell:(UITableViewCell *)cell forStreamSectionAtRow:(NSInteger)row
{
    cell.textLabel.text = @"Stream:";
    cell.detailTextLabel.text = self.subscriber.stream.streamId ?: @"N/A";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureCell:(UITableViewCell *)cell forQualitySectionAtRow:(NSInteger)row
{
    NSString *title;
    NSString *detail;
    UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;

    switch ((SubscriberVideoQualitySectionRows)row)
    {
        case SubscriberVideoQualitySectionSpatialRow:
            title = @"Spatial:";
            detail = NSStringFromVideoSpatialQuality(self.subscriber.videoQuality.spatialQuality);
            break;
        case SubscriberVideoQualitySectionTemporalRow:
            title = @"Temporal:";
            detail = NSStringFromVideoTemporalQuality(self.subscriber.videoQuality.temporalQuality);
            break;
    }

    if([self.subscriber canUpdateVideoQuality])
        accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
    cell.accessoryType = accessoryType;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Table Delegate
//-------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;

    if(section == SubscriberInfoStreamSection)
        [self performSegueWithIdentifier:SHOW_STREAM_INFO_SEGUE_ID sender:self];
    else if(section == SubscriberInfoVideoQualitySection && [self.subscriber canUpdateVideoQuality])
        [self performSegueWithIdentifier:SHOW_VIDEO_QUALITY_SELECTION_SEGUE sender:self];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Segue
//-------------------------------------------------------------------------------------------

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender
{
    if([segue.identifier isEqualToString:SHOW_STREAM_INFO_SEGUE_ID])
    {
        StreamInfoTableViewController *controller = segue.destinationViewController;
        controller.stream = self.subscriber.stream;
    } else if([segue.identifier isEqualToString:SHOW_VIDEO_QUALITY_SELECTION_SEGUE])
    {
        VideoQualitySelectionTableViewController * controller = segue.destinationViewController;
        controller.quality = self.subscriber.videoQuality;
        controller.delegate = self;
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Subscriber Observer
//-------------------------------------------------------------------------------------------


- (void)subscriberDidConnectToStream:(BAVSubscriber *)subscriber
{

}

- (void)subscriberDidDisconnectFromStream:(BAVSubscriber *)subscriber
{

}

- (void)subscriber:(BAVSubscriber *)subscriber didFailWithError:(NSError *)error
{
    [self.tableView reloadData];
}

- (void)subscriberDidChangeState:(BAVSubscriber *)subscriber
{
    [self.tableView reloadData];
}

- (void)subscriber:(BAVSubscriber *)subscriber didUpdateVideoQuality:(BAVVideoQuality *)quality
{
    [self.tableView reloadData];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Video Quality Selection Delegate
//-------------------------------------------------------------------------------------------

- (void)videoQualitySelectionController:(VideoQualitySelectionTableViewController *)controller didSelectQuality:(BAVVideoQuality *)quality
{
    if(![self.subscriber.videoQuality isEqual:quality])
        [self.subscriber updateVideoQuality:quality];
}


@end
