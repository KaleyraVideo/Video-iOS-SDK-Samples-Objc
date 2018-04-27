//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <AVFoundation/AVFoundation.h>
#import <BandyerCoreAV/BAVVideoFormat.h>

#import "VideoSettingsTableViewController.h"
#import "SettingsRepository.h"
#import "CameraPositionPickingTableViewCell.h"
#import "VideoFormatPickingTableViewCell.h"

@interface VideoSettingsTableViewController () <CameraPositionPickingTableViewCellDelegate, VideoFormatPickingTableViewCellDelegate>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *saveBarButtonItem;

@property (nonatomic, assign) BOOL cameraPositionPickerShown;
@property (nonatomic, assign) BOOL videoFormatPickerShown;
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;
@property (nonatomic, strong) BAVVideoFormat *videoFormat;
@property (nonatomic, strong) SettingsRepository *settingsRepository;

@end

@implementation VideoSettingsTableViewController

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
    _cameraPosition = [_settingsRepository retrieveCameraPosition];
    _videoFormat = [_settingsRepository retrieveVideoFormat];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)saveBarButtonTouched:(UIBarButtonItem *)sender
{
    [self.settingsRepository storeCameraPosition:self.cameraPosition];
    [self.settingsRepository storeVideoFormat:self.videoFormat];
    [self.settingsRepository flush];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Table View Datasource
//-------------------------------------------------------------------------------------------


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 4;
    }

    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    UITableViewCell *cell;

    if(row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"capturePositionCellIdentifier" forIndexPath:indexPath];

        NSString * detailText;
        if(self.cameraPosition == AVCaptureDevicePositionFront)
            detailText = @"Front";
        else if(self.cameraPosition == AVCaptureDevicePositionBack)
            detailText = @"Back";
        else
            detailText = @"Unspecified";

        cell.detailTextLabel.text = detailText;

    } else if (row == 1)
    {
        CameraPositionPickingTableViewCell * pickingCell = [tableView dequeueReusableCellWithIdentifier:@"capturePositionPickerCellIdentifier" forIndexPath:indexPath];
        pickingCell.delegate = self;
        pickingCell.cameraPosition = self.cameraPosition;

        cell = pickingCell;
    }else if (row == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"videoFormatCellIdentifier" forIndexPath:indexPath];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ux%u @%u fps", self.videoFormat.width, self.videoFormat.height, self.videoFormat.frameRate];
    }else if (row == 3)
    {
        VideoFormatPickingTableViewCell *pickingCell = [tableView dequeueReusableCellWithIdentifier:@"videoFormatPickerCellIdentifier" forIndexPath:indexPath];
        pickingCell.delegate = self;
        pickingCell.videoFormat = self.videoFormat;

        cell = pickingCell;
    }

    return cell;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Table View Delegate
//-------------------------------------------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];

    if(row == 1)
    {
        return self.cameraPositionPickerShown ? UITableViewAutomaticDimension : 0;
    }

    if(row == 3)
    {
        return self.videoFormatPickerShown  ? UITableViewAutomaticDimension : 0;
    }

    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];

    if(row == 0)
    {
        self.cameraPositionPickerShown = !self.cameraPositionPickerShown;
        self.videoFormatPickerShown = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

    if(row == 2)
    {
        self.videoFormatPickerShown = !self.videoFormatPickerShown;
        self.cameraPositionPickerShown = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

}

//-------------------------------------------------------------------------------------------
#pragma mark - Camera Position Picking Cell Delegate
//-------------------------------------------------------------------------------------------

- (void)cell:(CameraPositionPickingTableViewCell *)cell didSelectCameraPosition:(AVCaptureDevicePosition)position
{
    self.cameraPosition = position;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Video Format Picking Cell Delegate
//-------------------------------------------------------------------------------------------

- (void)cell:(VideoFormatPickingTableViewCell *)cell didSelectVideoFormat:(BAVVideoFormat *)format
{
    self.videoFormat = format;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end
