//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import "SettingsRepository.h"
#import "PublishSettingsTableViewController.h"
#import "PublishSettings.h"

typedef NS_ENUM(NSInteger, PublishSettingsSection)
{
    PublishSettingsModeSection = 0,
    PublishSettingsOptionsSection,
};

typedef NS_ENUM(NSInteger, PublishSettingsModeSectionRows)
{
    PublishModeAutoRow = 0,
    PublishModeManualRow,
};

typedef NS_ENUM(NSInteger, PublishSettingsOptionsSectionRows)
{
    PublishOptionsAudioRow = 0,
    PublishOptionsVideoRow,
    PublishOptionsAudioEnabledRow,
    PublishOptionsVideoEnabledRow,
};


@interface PublishSettingsTableViewController ()

@property (nonatomic, strong) IBOutlet UISwitch *audioEnabledSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *videoEnabledSwitch;

@property (nonatomic, strong) SettingsRepository *settingsRepository;
@property (nonatomic, strong) PublishSettings *settings;

@end

@implementation PublishSettingsTableViewController

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
    _settingsRepository = [SettingsRepository sharedInstance];
    _settings = [_settingsRepository retrievePublishSettings];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.settingsRepository storePublishSettings:self.settings];
    [self.settingsRepository flush];

    [super viewWillDisappear:animated];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    if (section == PublishSettingsModeSection)
    {
        switch ((PublishSettingsModeSectionRows) row)
        {
            case PublishModeAutoRow:
                cell.accessoryType = self.settings.mode == PublishModeAuto ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case PublishModeManualRow:
                cell.accessoryType = self.settings.mode == PublishModeManual ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
        }
    }else if (section == PublishSettingsOptionsSection)
    {
        switch ((PublishSettingsOptionsSectionRows) row)
        {
            case PublishOptionsAudioRow:
                cell.accessoryType = self.settings.hasAudio ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case PublishOptionsVideoRow:
                cell.accessoryType = self.settings.hasVideo ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case PublishOptionsAudioEnabledRow:
                self.audioEnabledSwitch.on = self.settings.hasAudioEnabled;
                self.audioEnabledSwitch.enabled = self.settings.hasAudio;
                break;
            case PublishOptionsVideoEnabledRow:
                self.videoEnabledSwitch.on = self.settings.hasVideoEnabled;
                self.videoEnabledSwitch.enabled = self.settings.hasVideo;
                break;
        }
    }


    return cell;
}


//-------------------------------------------------------------------------------------------
#pragma mark - Table Delegate
//-------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    if (section == PublishSettingsModeSection)
    {
        switch ((PublishSettingsModeSectionRows) row)
        {
            case PublishModeAutoRow:
                self.settings.mode = PublishModeAuto;
                break;
            case PublishModeManualRow:
                self.settings.mode = PublishModeManual;
                break;
        }
    } else if (section == PublishSettingsOptionsSection)
    {
        switch ((PublishSettingsOptionsSectionRows) row)
        {
            case PublishOptionsAudioRow:
                self.settings.audio = !self.settings.audio;
                break;
            case PublishOptionsVideoRow:
                self.settings.video = !self.settings.video;
                break;
            case PublishOptionsAudioEnabledRow:
                break;
            case PublishOptionsVideoEnabledRow:
                break;
        }
    }

    [self.tableView reloadData];
}


//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)audioEnabledSwitchChanged:(UISwitch *)sender
{
    self.settings.audioEnabled = sender.isOn;
    [self.tableView reloadData];
}

- (IBAction)videoEnabledSwitchChanged:(UISwitch *)sender
{
    self.settings.videoEnabled = sender.isOn;
    [self.tableView reloadData];
}

@end
