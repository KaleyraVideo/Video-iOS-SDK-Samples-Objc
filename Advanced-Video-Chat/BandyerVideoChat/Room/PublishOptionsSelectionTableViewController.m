//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import "PublishOptionsSelectionTableViewController.h"

typedef NS_ENUM(NSInteger, PublishOptionsRows)
{
    PublishOptionsSelectionAudioRow = 0,
    PublishOptionsSelectionVideoRow,
    PublishOptionsSelectionAudioEnabledRow,
    PublishOptionsSelectionVideoEnabledRow,
};

@interface PublishOptionsSelectionTableViewController ()

@property (nonatomic, strong) IBOutlet UISwitch *audioEnabledSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *videoEnabledSwitch;

@end

@implementation PublishOptionsSelectionTableViewController


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    if (section == 0)
    {
        switch ((PublishOptionsRows) row)
        {
            case PublishOptionsSelectionAudioRow:
                cell.accessoryType = self.options.hasAudio ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case PublishOptionsSelectionVideoRow:
                cell.accessoryType = self.options.hasVideo ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case PublishOptionsSelectionAudioEnabledRow:
                self.audioEnabledSwitch.on = self.options.hasAudioEnabled;
                self.audioEnabledSwitch.enabled = self.options.hasAudio;
                break;
            case PublishOptionsSelectionVideoEnabledRow:
                self.videoEnabledSwitch.on = self.options.hasVideoEnabled;
                self.videoEnabledSwitch.enabled = self.options.hasVideo;
                break;
        }
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0)
    {
        switch ((PublishOptionsRows) row)
        {
            case PublishOptionsSelectionAudioRow:
                self.options.audio = !self.options.hasAudio;
                break;
            case PublishOptionsSelectionVideoRow:
                self.options.video = !self.options.hasVideo;
                break;
            case PublishOptionsSelectionAudioEnabledRow:
                break;
            case PublishOptionsSelectionVideoEnabledRow:
                break;
        }
    }

    [self.tableView reloadData];
    [self.delegate publishOptionsSelectionController:self didChangeOptions:self.options];
}


//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)audioSwitchChanged:(UISwitch *)sender
{
    self.options.audioEnabled = sender.isOn;
    [self.tableView reloadData];
    [self.delegate publishOptionsSelectionController:self didChangeOptions:self.options];
}

- (IBAction)videoSwitchChanged:(UISwitch *)sender
{
    self.options.videoEnabled = sender.isOn;
    [self.tableView reloadData];
    [self.delegate publishOptionsSelectionController:self didChangeOptions:self.options];
}

@end
