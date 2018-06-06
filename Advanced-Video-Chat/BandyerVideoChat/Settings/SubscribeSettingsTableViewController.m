//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import "SubscribeSettingsTableViewController.h"
#import "SettingsRepository.h"
#import "SubscribeSettings.h"

typedef NS_ENUM(NSInteger, SubscribeSettingsSection)
{
    SubscribeSettingsModeSection = 0,
    SubscribeSettingsOptionsSection,
};

typedef NS_ENUM(NSInteger, SubscribeSettingsModeSectionRows)
{
    SubscribeModeAutoRow = 0,
    SubscribeModeManualRow,
};

typedef NS_ENUM(NSInteger, SubscribeSettingsOptionsSectionRows)
{
    SubscribeOptionsAudioRow = 0,
    SubscribeOptionsVideoRow,
    SubscribeOptionsAudioEnabledRow,
    SubscribeOptionsVideoEnabledRow,
};


@interface SubscribeSettingsTableViewController ()

@property (nonatomic, strong) IBOutlet UISwitch *audioEnabledSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *videoEnabledSwitch;

@property (nonatomic, strong) SettingsRepository *settingsRepository;
@property (nonatomic, strong) SubscribeSettings *settings;

@end

@implementation SubscribeSettingsTableViewController

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
    _settings = [_settingsRepository retrieveSubscribeSettings];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.settingsRepository storeSubscribeSettings:self.settings];
    [self.settingsRepository flush];
    
    [super viewWillDisappear:animated];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Data Source
//-------------------------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    if(section == SubscribeSettingsModeSection)
    {
        switch ((SubscribeSettingsModeSectionRows)row)
        {
            case SubscribeModeAutoRow:
                cell.accessoryType = self.settings.mode == SubscribeModeAuto ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case SubscribeModeManualRow:
                cell.accessoryType = self.settings.mode == SubscribeModeManual ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
        }
    }else if (section == SubscribeSettingsOptionsSection)
    {
        switch ((SubscribeSettingsOptionsSectionRows)row)
        {
            case SubscribeOptionsAudioRow:
                cell.accessoryType = self.settings.hasAudio ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case SubscribeOptionsVideoRow:
                cell.accessoryType = self.settings.hasVideo ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case SubscribeOptionsAudioEnabledRow:
                self.audioEnabledSwitch.enabled = self.settings.hasAudio;
                self.audioEnabledSwitch.on = self.settings.hasAudioEnabled;
                break;
            case SubscribeOptionsVideoEnabledRow:
                self.videoEnabledSwitch.enabled = self.settings.hasVideo;
                self.videoEnabledSwitch.on = self.settings.hasVideoEnabled;
                break;
        }
    }
    
    return cell;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Delegate
//-------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    if(section == SubscribeSettingsModeSection)
    {
        switch ((SubscribeSettingsModeSectionRows) row)
        {
            case SubscribeModeAutoRow:
                self.settings.mode = SubscribeModeAuto;
                break;
            case SubscribeModeManualRow:
                self.settings.mode = SubscribeModeManual;
                break;
        }
    }else if (section == SubscribeSettingsOptionsSection)
    {
        switch ((SubscribeSettingsOptionsSectionRows)row)
        {
            case SubscribeOptionsAudioRow:
                self.settings.audio = !self.settings.hasAudio;
                break;
            case SubscribeOptionsVideoRow:
                self.settings.video = !self.settings.hasVideo;
                break;
            case SubscribeOptionsAudioEnabledRow:break;
            case SubscribeOptionsVideoEnabledRow:break;
        }
    }

    [self.tableView reloadData];
}


//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)audioEnabledSwitchChanged:(UISwitch *)sender
{
    self.settings.audio = sender.isOn;
    [self.tableView reloadData];
}

- (IBAction)videoEnabledSwitchChanged:(UISwitch *)sender
{
    self.settings.video = sender.isOn;
    [self.tableView reloadData];
}

@end
