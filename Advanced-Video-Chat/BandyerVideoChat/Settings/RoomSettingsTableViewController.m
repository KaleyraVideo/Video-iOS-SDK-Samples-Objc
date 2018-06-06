//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import "RoomSettingsTableViewController.h"
#import "RoomSettings.h"
#import "SettingsRepository.h"

typedef NS_ENUM(NSInteger, RoomSettingsSections)
{
    RoomSettingsHostSection = 0,
    RoomSettingsTypeSection,
    RoomSettingsRecordingSection,
    RoomSettingsUserRoleSection
};

typedef NS_ENUM (NSInteger, RoomSettingsTypeRows)
{
    RoomSettingsTypeRelayedRow = 0,
    RoomSettingsTypeRoutedRow,
};

typedef NS_ENUM(NSInteger, RoomSettingsUserRoleRows)
{
    RoomSettingsUserRolePresenterRow = 0,
    RoomSettingsUserRoleViewerRow,
    RoomSettingsUserRolePublishOnlyRow,
    RoomSettingsUserRoleViewerWithDataRow,
};


@interface RoomSettingsTableViewController ()

@property (nonatomic, strong) IBOutlet UISwitch *recordingSwitch;
@property (nonatomic, strong) SettingsRepository *settingsRepository;
@property (nonatomic, strong) RoomSettings *settings;

@end

@implementation RoomSettingsTableViewController


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
    _settings = [_settingsRepository retrieveRoomSettings];
}

//-------------------------------------------------------------------------------------------
#pragma mark - View lifecycle
//-------------------------------------------------------------------------------------------


- (void)viewWillDisappear:(BOOL)animated
{
    [self.settingsRepository storeRoomSettings:self.settings];
    [self.settingsRepository flush];

    [super viewWillDisappear:animated];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Table Datasource
//-------------------------------------------------------------------------------------------


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    if(section == RoomSettingsHostSection)
    {
        cell.detailTextLabel.text = self.settings.url;
    }else if (section == RoomSettingsTypeSection)
    {
        switch ((RoomSettingsTypeRows)row)
        {
            case RoomSettingsTypeRelayedRow:
                cell.accessoryType = self.settings.type == RoomTypeRelayed ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case RoomSettingsTypeRoutedRow:
                cell.accessoryType = self.settings.type == RoomTypeRouted ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
        }
    } else if (section == RoomSettingsRecordingSection)
    {
        self.recordingSwitch.enabled = self.settings.type == RoomTypeRouted;
        self.recordingSwitch.on = self.settings.isRecording;
    } else if (section == RoomSettingsUserRoleSection)
    {
        switch ((RoomSettingsUserRoleRows)row)
        {
            case RoomSettingsUserRolePresenterRow:
                cell.accessoryType = self.settings.userRole == UserRolePresenter ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case RoomSettingsUserRoleViewerRow:
                cell.accessoryType = self.settings.userRole == UserRoleViewer ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case RoomSettingsUserRolePublishOnlyRow:
                cell.accessoryType = self.settings.userRole == UserRolePublishOnly ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case RoomSettingsUserRoleViewerWithDataRow:
                cell.accessoryType = self.settings.userRole == UserRoleViewerWithData ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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

    if(section == RoomSettingsHostSection)
    {
        [self presentURLInputAlert];
    }else if (section == RoomSettingsTypeSection)
    {
        switch ((RoomSettingsTypeRows)row)
        {
            case RoomSettingsTypeRelayedRow:
                self.settings.type = RoomTypeRelayed;
                break;
            case RoomSettingsTypeRoutedRow:
                self.settings.type = RoomTypeRouted;
                break;
        }
        [self.tableView reloadData];
    } else if (section == RoomSettingsUserRoleSection)
    {
        switch ((RoomSettingsUserRoleRows)row)
        {
            case RoomSettingsUserRolePresenterRow:
                self.settings.userRole = UserRolePresenter;
                break;
            case RoomSettingsUserRoleViewerRow:
                self.settings.userRole = UserRoleViewer;
                break;
            case RoomSettingsUserRolePublishOnlyRow:
                self.settings.userRole = UserRolePublishOnly;
                break;
            case RoomSettingsUserRoleViewerWithDataRow:
                self.settings.userRole = UserRoleViewerWithData;
                break;
        }
        [self.tableView reloadData];
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - URL Alert
//-------------------------------------------------------------------------------------------


- (void)presentURLInputAlert
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"URL" message:@"Please, insert the host url" preferredStyle:UIAlertControllerStyleAlert];
    [controller addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"https://example.com";
        textField.text = self.settings.url;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel 
                                                         handler:NULL];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *field = controller.textFields.firstObject;
        NSString *urlString = field.text;
        NSURL * url = [NSURL URLWithString:urlString];

        if(url)
        {
            self.settings.url = urlString;
            [self.tableView reloadData];
        }

    }];
    [controller addAction:cancelAction];
    [controller addAction:confirmAction];
    
    [self presentViewController:controller animated:YES completion:NULL];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)recordingSwitchChanged:(UISwitch *)sender
{
    self.settings.recording = sender.isOn;
    [self.tableView reloadData];
}

@end
