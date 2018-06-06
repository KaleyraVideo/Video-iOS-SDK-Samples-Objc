//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import "SubscribeOptionsSelectionTableViewController.h"

typedef NS_ENUM(NSInteger, SubscribeOptionsRows)
{
    SubscribeOptionsSelectionAudioRow = 0,
    SubscribeOptionsSelectionVideoRow,
    SubscribeOptionsSelectionAudioEnabledRow,
    SubscribeOptionsSelectionVideoEnabledRow,
};

@interface SubscribeOptionsSelectionTableViewController ()

@property (nonatomic, strong) IBOutlet UISwitch *audioEnabledSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *videoEnabledSwitch;

@end

@implementation SubscribeOptionsSelectionTableViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    if (section == 0)
    {
        switch ((SubscribeOptionsRows) row)
        {
            case SubscribeOptionsSelectionAudioRow:
                cell.accessoryType = self.options.hasAudio ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case SubscribeOptionsSelectionVideoRow:
                cell.accessoryType = self.options.hasVideo ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case SubscribeOptionsSelectionAudioEnabledRow:
                self.audioEnabledSwitch.on = self.options.hasAudioEnabled;
                self.audioEnabledSwitch.enabled = self.options.hasAudio;
                break;
            case SubscribeOptionsSelectionVideoEnabledRow:
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
        switch ((SubscribeOptionsRows) row)
        {
            case SubscribeOptionsSelectionAudioRow:
                self.options.audio = !self.options.hasAudio;
                break;
            case SubscribeOptionsSelectionVideoRow:
                self.options.video = !self.options.hasVideo;
                break;
            case SubscribeOptionsSelectionAudioEnabledRow:
                break;
            case SubscribeOptionsSelectionVideoEnabledRow:
                break;
        }
    }

    [self.tableView reloadData];
    [self.delegate subscribeOptionsSelectionController:self didChangeOptions:self.options];
}


//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)audioSwitchChanged:(UISwitch *)sender
{
    self.options.audioEnabled = sender.isOn;
    [self.tableView reloadData];
    [self.delegate subscribeOptionsSelectionController:self didChangeOptions:self.options];
}

- (IBAction)videoSwitchChanged:(UISwitch *)sender
{
    self.options.videoEnabled = sender.isOn;
    [self.tableView reloadData];
    [self.delegate subscribeOptionsSelectionController:self didChangeOptions:self.options];
}

@end
