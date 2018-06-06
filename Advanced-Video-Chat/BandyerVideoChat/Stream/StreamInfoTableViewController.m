//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <BandyerFoundation/BandyerFoundationMacro.h>
#import <BandyerCoreAV/BAVStream.h>
#import <BandyerCoreAV/BAVPublisherIdentity.h>

#import "StreamInfoTableViewController.h"

typedef NS_ENUM(NSInteger, StreamInfoSections)
{
    StreamInfoMediaSection = 0,
    StreamInfoPublisherSection
};

typedef NS_ENUM(NSInteger, MediaSectionRows)
{
    MediaSectionStreamIdRow = 0,
    MediaSectionAudioRow,
    MediaSectionVideoRow,
    MediaSectionScreenRow,
    MediaSectionNameRow
};

typedef NS_ENUM(NSInteger, PublisherSectionRows)
{
    PublisherSectionAliasRow = 0,
    PublisherSectionFirstNameRow,
    PublisherSectionLastNameRow,
    PublisherSectionEmailRow,
    PublisherSectionAvatarRow,
};

#define STREAM_INFO_CELL @"streamInfoCell"

@interface StreamInfoTableViewController ()

@end

@implementation StreamInfoTableViewController

//-------------------------------------------------------------------------------------------
#pragma mark - Table Datasource
//-------------------------------------------------------------------------------------------


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.stream.hasPublisherIdentity)
        return 2;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    StreamInfoSections infoSection = (StreamInfoSections) section;

    switch (infoSection)
    {
        case StreamInfoMediaSection:
            return 5;
        case StreamInfoPublisherSection:
            return 5;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:STREAM_INFO_CELL forIndexPath:indexPath];

    switch (section)
    {
        case StreamInfoMediaSection:
            [self configureCell:cell forMediaSectionAtRow:row];
            break;
        case StreamInfoPublisherSection:
            [self configureCell:cell forPublisherSectionAtRow:row];
            break;
        default:
            break;
    }

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forMediaSectionAtRow:(NSInteger)row
{
    NSString *title;
    NSString *detail;
    switch ((MediaSectionRows)row)
    {
        case MediaSectionStreamIdRow:
            title = @"Stream Id:";
            detail = self.stream.streamId;
            break;
        case MediaSectionAudioRow:
            title = @"Audio";
            detail = BDFBoolToNSString(self.stream.hasAudio);
            break;
        case MediaSectionVideoRow:
            title = @"Video:";
            detail = BDFBoolToNSString(self.stream.hasVideo);
            break;
        case MediaSectionScreenRow:
            title = @"Screensharing:";
            detail = BDFBoolToNSString(self.stream.isScreen);
            break;
        case MediaSectionNameRow:
            title = @"Name";
            detail = self.stream.name ?: @"N/A";
            break;
    }

    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
}

- (void)configureCell:(UITableViewCell *)cell forPublisherSectionAtRow:(NSInteger)row
{
    NSString *title;
    NSString *detail;

    switch ((PublisherSectionRows)row)
    {
        case PublisherSectionAliasRow:
            title = @"Alias:";
            detail = self.stream.publisherIdentity.alias;
            break;
        case PublisherSectionFirstNameRow:
            title = @"First Name:";
            detail = self.stream.publisherIdentity.firstName;
            break;
        case PublisherSectionLastNameRow:
            title = @"Last Name:";
            detail = self.stream.publisherIdentity.lastName;
            break;
        case PublisherSectionEmailRow:
            title = @"Email:";
            detail = self.stream.publisherIdentity.email;
            break;
        case PublisherSectionAvatarRow:
            title = @"Avatar:";
            detail = self.stream.publisherIdentity.avatarFilename;
            break;
    }

    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == StreamInfoMediaSection)
        return @"Media Info";
    else if(section == StreamInfoPublisherSection)
        return @"Publisher Identity";
    return nil;
}


@end
