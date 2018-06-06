//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <BandyerCoreAV/BAVPublisherIdentity.h>

#import "StreamSelectionTableViewController.h"
#import "DetailedStreamTableViewCell.h"
#import "StreamInfoTableViewController.h"

#define SHOW_PUBLISH_OPTIONS_SELECTION_SEGUE @"showPublishOptionsSelection"
#define SHOW_STREAM_INFO_SEGUE @"showStreamInfo"

@interface StreamSelectionTableViewController ()

@property (nonatomic, strong) NSMutableArray<NSIndexPath*> *selectedIndexPaths;

@end

@implementation StreamSelectionTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }

    return self;
}

- (void)commonInit
{
    _selectedIndexPaths = [NSMutableArray new];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return self.streams.count;

    return 0;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"Streams";

    return nil;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(self.streams.count == 0)
        return @"There are no streams available at the moment";
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailedStreamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"streamCellId" forIndexPath:indexPath];
    BAVStream *stream = [self streamForIndexPath:indexPath];

    cell.streamIdLabel.text = stream.streamId;
    cell.publisherDetailLabel.text = [self formatPublisherDetails:stream];
    cell.audioImageView.image = [UIImage imageNamed:stream.hasAudio ? @"mic_enabled" : @"mic_not_available"];
    cell.videoImageView.image = [UIImage imageNamed:stream.hasVideo ? @"video_enabled" : @"video_not_available"];

    return cell;
}

- (BAVStream *)streamForIndexPath:(NSIndexPath *)path
{
    NSInteger section = path.section;
    NSInteger row = path.row;

    if(section == 0 && row < self.streams.count)
        return self.streams[row];

    return nil;
}

- (NSString *)formatPublisherDetails:(BAVStream *)stream
{
    return [stream hasPublisherIdentity] ? [NSString stringWithFormat:@"%@ %@", stream.publisherIdentity.firstName, stream.publisherIdentity.lastName] : stream.name;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![self.selectedIndexPaths containsObject:indexPath])
    {
        [self.selectedIndexPaths addObject:indexPath];
        BAVStream *stream = [self streamForIndexPath:indexPath];

        if(stream)
            [self.delegate streamSelectionController:self didSelectStream:stream];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    BAVStream *stream = [self streamForIndexPath:indexPath];
    [self.delegate streamSelectionController:self didSelectInfoForStream:stream];
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.selectedIndexPaths containsObject:indexPath])
    {
        [self.selectedIndexPaths removeObject:indexPath];
        BAVStream *stream = [self streamForIndexPath:indexPath];

        if(stream)
            [self.delegate streamSelectionController:self didDeselectStream:stream];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SHOW_PUBLISH_OPTIONS_SELECTION_SEGUE])
    {
               
    }else if([segue.identifier isEqualToString:SHOW_STREAM_INFO_SEGUE])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        StreamInfoTableViewController *controller = segue.destinationViewController;
        controller.stream = self.streams[indexPath.row];
    }
}

@end
