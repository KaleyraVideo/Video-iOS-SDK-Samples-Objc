//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <BandyerCoreAV/BAVPublisher.h>
#import <BandyerCoreAV/BAVPublishOptions.h>
#import <BandyerCoreAV/BAVPublisherObserver.h>
#import <BandyerCoreAV/BAVCameraCapturer.h>
#import <BandyerCoreAV/BAVFileVideoCapturer.h>
#import <BandyerCoreAV/BAVStream.h>

#import "PublisherInfoTableViewController.h"
#import "StreamInfoTableViewController.h"

#define CELL_ID @"rightDetailCellId"
#define SHOW_STREAM_INFO_SEGUE @"showStreamInfoSegue"

typedef NS_ENUM(NSInteger, PublisherInfoSections)
{
    PublisherInfoSummarySection = 0,
    PublisherInfoCapturerSection,
    PublisherInfoStreamSection
};

typedef NS_ENUM(NSInteger, PublisherInfoSummarySectionRows)
{
    PublisherInfoSummarySectionStateRow = 0,
    PublisherInfoSummarySectionAudioRow,
    PublisherInfoSummarySectionVideoRow,
};


@interface PublisherInfoTableViewController () <BAVPublisherObserver>

@end

@implementation PublisherInfoTableViewController

- (void)setPublisher:(BAVPublisher *)publisher
{
    [_publisher removeObserver:self];
    _publisher = publisher;
    [_publisher addObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Table view data source
//-------------------------------------------------------------------------------------------


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch ((PublisherInfoSections)section)
    {
        case PublisherInfoSummarySection:
            return 3;
        case PublisherInfoCapturerSection:
            return 1; //TODO: In case of camera capture would be nice to show video capture formats, camera position and so on...
            //TODO: In case of file capture would be nice to show file name or url.
            //TODO: In any case would be nice to show capturer state (running, failed, etc...)
        case PublisherInfoStreamSection:
            return self.publisher.stream ? 1 : 0;
    }
    return 0;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch ((PublisherInfoSections)section)
    {
        case PublisherInfoSummarySection:
            return @"Summary";
        case PublisherInfoCapturerSection:
            return @"Capturer";
        case PublisherInfoStreamSection:
            return @"Stream";
    }

    return nil;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == PublisherInfoStreamSection && self.publisher.stream == nil)
        return @"Not publishing a stream at the moment";

    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    switch ((PublisherInfoSections)section)
    {
        case PublisherInfoSummarySection:
            [self configureCell:cell forSummarySectionAtRow:row];
            break;
        case PublisherInfoCapturerSection:
            [self configureCell:cell forCapturerSectionAtRow:row];
            break;
        case PublisherInfoStreamSection:
            [self configureCell:cell forStreamSectionAtRow:row];
            break;
    }

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forSummarySectionAtRow:(NSInteger)row
{
    UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;
    NSString *title;
    NSString *detail;

    switch ((PublisherInfoSummarySectionRows)row)
    {
        case PublisherInfoSummarySectionStateRow:
            title = @"State:";
            detail = NSStringFromBAVPublisherState(self.publisher.state);
            break;
        case PublisherInfoSummarySectionAudioRow:
            title = @"Publish Audio:";
            accessoryType = self.publisher.publishOptions.hasAudio ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        case PublisherInfoSummarySectionVideoRow:
            title = @"Publish Video:";
            accessoryType = self.publisher.publishOptions.hasVideo ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
    }

    cell.accessoryType = accessoryType;
    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
}

- (void)configureCell:(UITableViewCell *)cell forCapturerSectionAtRow:(NSInteger)row
{
    cell.textLabel.text = @"Source:";
    //TODO: Checking for object type should be avoided, an an enum could be added? (a more object oriented way?)
    if([self.publisher.capturer isKindOfClass:BAVCameraCapturer.class])
        cell.detailTextLabel.text = @"Camera";
    else if([self.publisher.capturer isKindOfClass:BAVFileVideoCapturer.class])
        cell.detailTextLabel.text = @"File";
    else
        cell.detailTextLabel.text = @"Unknown";
}

- (void)configureCell:(UITableViewCell *)cell forStreamSectionAtRow:(NSInteger)row
{
    NSString *detail = @"N/A";
    UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;

    if(self.publisher.stream.streamId)
    {
        detail = self.publisher.stream.streamId;
        accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    cell.textLabel.text = @"Stream:";
    cell.detailTextLabel.text = detail;
    cell.accessoryType = accessoryType;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Table View Delegate
//-------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == PublisherInfoStreamSection && self.publisher.stream != nil)
        [self performSegueWithIdentifier:SHOW_STREAM_INFO_SEGUE sender:self];
}


//-------------------------------------------------------------------------------------------
#pragma mark - Publisher Observer
//-------------------------------------------------------------------------------------------

- (void)publisherDidCreateStream:(BAVPublisher *)publisher
{
    [self.tableView reloadData];
}

- (void)publisher:(BAVPublisher *)publisher didFailWithError:(NSError *)error
{
    [self.tableView reloadData];
}

- (void)publisherDidChangeState:(BAVPublisher *)publisher
{
    [self.tableView reloadData];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Segue
//-------------------------------------------------------------------------------------------

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender
{
    if([segue.identifier isEqualToString:SHOW_STREAM_INFO_SEGUE])
    {
        StreamInfoTableViewController *controller = segue.destinationViewController;
        controller.stream = self.publisher.stream;
    }
}


@end
