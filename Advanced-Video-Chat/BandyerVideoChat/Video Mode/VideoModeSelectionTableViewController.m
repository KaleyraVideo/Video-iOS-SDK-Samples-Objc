//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import "VideoModeSelectionTableViewController.h"

@interface VideoModeSelectionTableViewController ()

@end

@implementation VideoModeSelectionTableViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSInteger row = indexPath.row;

    cell.accessoryType = row == self.videoFittingMode ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.videoFittingMode = (BAVVideoSizeFittingMode) indexPath.row;
    [self.delegate videoModeSelectionController:self didChangeVideoFittingMode:self.videoFittingMode];
    [self.tableView reloadData];
}


@end
