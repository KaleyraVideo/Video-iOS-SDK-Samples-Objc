//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import "AudioSessionSettingsTableViewController.h"
#import "SettingsRepository.h"
#import "AudioSessionSettings.h"

typedef NS_ENUM(NSInteger, AudioSessionSettingsSections)
{
    AudioSessionSettingsOptionsSection = 0,
    AudioSessionSettingsActivationModeSection,
    AudioSessionSettingsSpeakerSection,
};

typedef NS_ENUM(NSInteger, AudioSessionSettingsOptionsSectionRows)
{
    AudioSessionSettingsOptionsAllowBluetoothRow = 0,
    AudioSessionSettingsOptionsAllowBluetoothA2DPRow,
    AudioSessionSettingsOptionsAllowAirplayRow,
    AudioSessionSettingsOptionsMixWithOthersRow,
    AudioSessionSettingsOptionsDuckOthersRow,
    AudioSessionSettingsOptionsInterruptSpokenAudioAndMixOthersRow,
    AudioSessionSettingsOptionsOutputDefaultToSpeakerRow
};

typedef NS_ENUM(NSInteger, AudioSessionActivationModeSectionRows)
{
    AudioSessionActivationModeSectionAutoRow = 0,
    AudioSessionActivationModeSectionManualRow
};

@interface AudioSessionSettingsTableViewController ()

@property (nonatomic, weak) IBOutlet UISwitch *overrideToSpeakerSwitch;
@property (nonatomic, strong) SettingsRepository *repository;
@property (nonatomic, strong) AudioSessionSettings *settings;

@end

@implementation AudioSessionSettingsTableViewController

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
    _repository = [SettingsRepository sharedInstance];
    _settings = [_repository retrieveAudioSessionSettings];
}

//-------------------------------------------------------------------------------------------
#pragma mark - View
//-------------------------------------------------------------------------------------------


- (void)viewWillDisappear:(BOOL)animated
{
    [self.repository storeAudioSessionSettings:self.settings];
    [self.repository flush];

    [super viewWillDisappear:animated];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Table Data Source
//-------------------------------------------------------------------------------------------


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    switch ((AudioSessionSettingsSections) section)
    {
        case AudioSessionSettingsOptionsSection:
            [self configureCell:cell forOptionsSectionAtRow:row];
            break;
        case AudioSessionSettingsActivationModeSection:
            [self configureCell:cell forActivationModeSectionAtRow:row];
            break;
        case AudioSessionSettingsSpeakerSection:
            [self configureCell:cell forSpeakerSectionAtRow:row];
            break;
    }

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forOptionsSectionAtRow:(NSInteger)row
{
    BOOL checkmark = [self.settings hasOption:[self categoryOptionForOptionsSectionRow:(AudioSessionSettingsOptionsSectionRows) row]];
    cell.accessoryType = checkmark ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)configureCell:(UITableViewCell *)cell forActivationModeSectionAtRow:(NSInteger)row
{
    BOOL checkmark = NO;

    switch ((AudioSessionActivationModeSectionRows) row)
    {
        case AudioSessionActivationModeSectionAutoRow:
            checkmark = !self.settings.manual;
            break;
        case AudioSessionActivationModeSectionManualRow:
            checkmark = self.settings.manual;
            break;
    }

    cell.accessoryType = checkmark ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)configureCell:(UITableViewCell *)cell forSpeakerSectionAtRow:(NSInteger)row
{
    self.overrideToSpeakerSwitch.enabled = !(self.settings.options & AVAudioSessionCategoryOptionDefaultToSpeaker);
    self.overrideToSpeakerSwitch.on = self.settings.overrideToSpeaker;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Table Delegate
//-------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    switch ((AudioSessionSettingsSections) section)
    {
        case AudioSessionSettingsOptionsSection:
            [self didSelectRowInOptionsSection:row];
            break;
        case AudioSessionSettingsActivationModeSection:
            [self didSelectRowInActivationModeSection:row];
            break;
        case AudioSessionSettingsSpeakerSection:
            break;
    }
}

- (void)didSelectRowInOptionsSection:(NSInteger)row
{
    [self.settings toggleOption:[self categoryOptionForOptionsSectionRow:(AudioSessionSettingsOptionsSectionRows) row]];

    [self.tableView reloadData];
}

- (void)didSelectRowInActivationModeSection:(NSInteger)row
{
    switch ((AudioSessionActivationModeSectionRows) row)
    {
        case AudioSessionActivationModeSectionAutoRow:
            self.settings.manual = NO;
            break;
        case AudioSessionActivationModeSectionManualRow:
            self.settings.manual = YES;
            break;
    }

    [self.tableView reloadData];
}

- (AVAudioSessionCategoryOptions)categoryOptionForOptionsSectionRow:(AudioSessionSettingsOptionsSectionRows)row
{
    switch (row)
    {
        case AudioSessionSettingsOptionsAllowBluetoothRow:
            return AVAudioSessionCategoryOptionAllowBluetooth;
        case AudioSessionSettingsOptionsAllowBluetoothA2DPRow:
            return AVAudioSessionCategoryOptionAllowBluetoothA2DP;
        case AudioSessionSettingsOptionsAllowAirplayRow:
            return AVAudioSessionCategoryOptionAllowAirPlay;
        case AudioSessionSettingsOptionsMixWithOthersRow:
            return AVAudioSessionCategoryOptionMixWithOthers;
        case AudioSessionSettingsOptionsDuckOthersRow:
            return AVAudioSessionCategoryOptionDuckOthers;
        case AudioSessionSettingsOptionsInterruptSpokenAudioAndMixOthersRow:
            return AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers;
        case AudioSessionSettingsOptionsOutputDefaultToSpeakerRow:
            return AVAudioSessionCategoryOptionDefaultToSpeaker;
    }
    return 0x0;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------


- (IBAction)overrideToSpeakerSwitchChanged:(UISwitch *)sender
{
    self.settings.overrideToSpeaker = sender.isOn;
    [self.tableView reloadData];
}

@end
