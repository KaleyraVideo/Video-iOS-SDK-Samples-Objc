//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import "VideoQualitySelectionTableViewController.h"

typedef NS_ENUM(NSInteger, VideoQualitySelectionSections)
{
    VideoQualitySelectionSpatialSection = 0,
    VideoQualitySelectionTemporalSection
};

typedef NS_ENUM(NSInteger, VideoQualitySelectionSpatialSectionRows)
{
    VideoQualitySelectionSpatialQualityAutoRow = 0,
    VideoQualitySelectionSpatialQualityHighRow,
    VideoQualitySelectionSpatialQualityLowRow,
};

typedef NS_ENUM(NSInteger, VideoQualitySelectionTemporalSectionRows)
{
    VideoQualitySelectionTemporalQualityAutoRow = 0,
    VideoQualitySelectionTemporalQuality30FpsRow ,
    VideoQualitySelectionTemporalQuality15FpsRow ,
    VideoQualitySelectionTemporalQuality7FpsRow ,
};

@interface VideoQualitySelectionTableViewController ()

@end

@implementation VideoQualitySelectionTableViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    switch ((VideoQualitySelectionSections)section)
    {
        case VideoQualitySelectionSpatialSection:
            [self configureCell:cell forSpatialSectionAtRow:row];
            break;
        case VideoQualitySelectionTemporalSection:
            [self configureCell:cell forTemporalSectionAtRow:row];
            break;
    }

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forSpatialSectionAtRow:(NSInteger)row
{
    UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;

    switch ((VideoQualitySelectionSpatialSectionRows)row)
    {
        case VideoQualitySelectionSpatialQualityAutoRow:
            accessoryType = self.quality.spatialQuality == BAVVideoSpatialQualityAuto ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        case VideoQualitySelectionSpatialQualityHighRow:
            accessoryType = self.quality.spatialQuality == BAVVideoSpatialQualityHigh ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        case VideoQualitySelectionSpatialQualityLowRow:
            accessoryType = self.quality.spatialQuality == BAVVideoSpatialQualityLow ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
    }

    cell.accessoryType = accessoryType;
}

- (void)configureCell:(UITableViewCell *)cell forTemporalSectionAtRow:(NSInteger)row
{
    UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;

    switch ((VideoQualitySelectionTemporalSectionRows) row)
    {
        case VideoQualitySelectionTemporalQualityAutoRow:
            accessoryType = self.quality.temporalQuality == BAVVideoTemporalQualityAuto ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        case VideoQualitySelectionTemporalQuality30FpsRow:
            accessoryType = self.quality.temporalQuality == BAVVideoTemporalQuality30FPS ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        case VideoQualitySelectionTemporalQuality15FpsRow:
            accessoryType = self.quality.temporalQuality == BAVVideoTemporalQuality15FPS ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        case VideoQualitySelectionTemporalQuality7FpsRow:
            accessoryType = self.quality.temporalQuality == BAVVideoTemporalQuality7FPS ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
    }

    cell.accessoryType = accessoryType;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    BAVVideoSpatialQuality spatialQuality = self.quality.spatialQuality;
    BAVVideoTemporalQuality temporalQuality = self.quality.temporalQuality;

    if (section == VideoQualitySelectionSpatialSection)
    {
        switch ((VideoQualitySelectionSpatialSectionRows)row)
        {
            case VideoQualitySelectionSpatialQualityAutoRow:
                spatialQuality = BAVVideoSpatialQualityAuto;
                break;
            case VideoQualitySelectionSpatialQualityHighRow:
                spatialQuality = BAVVideoSpatialQualityHigh;
                break;
            case VideoQualitySelectionSpatialQualityLowRow:
                spatialQuality = BAVVideoSpatialQualityLow;
                break;
        }
    } else if (section == VideoQualitySelectionTemporalSection)
    {
        switch ((VideoQualitySelectionTemporalSectionRows) row)
        {
            case VideoQualitySelectionTemporalQualityAutoRow:
                temporalQuality = BAVVideoTemporalQualityAuto;
                break;
            case VideoQualitySelectionTemporalQuality30FpsRow:
                temporalQuality = BAVVideoTemporalQuality30FPS;
                break;
            case VideoQualitySelectionTemporalQuality15FpsRow:
                temporalQuality = BAVVideoTemporalQuality15FPS;
                break;
            case VideoQualitySelectionTemporalQuality7FpsRow:
                temporalQuality = BAVVideoTemporalQuality7FPS;
                break;
        }
    }

    self.quality = [[BAVVideoQuality alloc] initWithSpatialQuality:spatialQuality temporalQuality:temporalQuality];
    [self.delegate videoQualitySelectionController:self didSelectQuality:self.quality];
    [self.tableView reloadData];
}


@end
