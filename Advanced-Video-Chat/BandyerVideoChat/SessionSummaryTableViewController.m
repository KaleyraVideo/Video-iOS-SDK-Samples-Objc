//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <BandyerCoreAV/BAVRoomToken.h>

#import "SessionSummaryTableViewController.h"
#import "SettingsRepository.h"
#import "RoomSettings.h"
#import "PublishSettings.h"
#import "SubscribeSettings.h"
#import "RoomViewController.h"

#define SHOW_SETTINGS_SEGUE @"showSettingsSegue"
#define SHOW_ROOM_SEGUE @"showRoomSegue"


typedef NS_ENUM(NSInteger, SessionSummarySections)
{
    SessionSummarySessionSection = 0,
    SessionSummaryPubSubSection,
};

typedef NS_ENUM(NSInteger, SessionSummarySessionRows)
{
    SessionSummarySessionURLRow = 0,
    SessionSummarySessionRoomTypeRow,
    SessionSummarySessionUserRoleRow
};

typedef NS_ENUM(NSInteger, SessionSummaryPubSubRows)
{
    SessionSummaryPubSubPublishModeRow = 0,
    SessionSummaryPubSubSubscribeModeRow
};


@interface SessionSummaryTableViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *callBarButtonItem;

@property (nonatomic, strong) SettingsRepository *settingsRepository;
@property (nonatomic, strong) RoomSettings *roomSettings;
@property (nonatomic, strong) PublishSettings *publishSettings;
@property (nonatomic, strong) SubscribeSettings *subscribeSettings;
@property (nonatomic, strong) BAVRoomToken *roomToken;

@end

@implementation SessionSummaryTableViewController

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
}

//-------------------------------------------------------------------------------------------
#pragma mark - View lifecycle
//-------------------------------------------------------------------------------------------

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.roomSettings = [self.settingsRepository retrieveRoomSettings];
    self.publishSettings = [self.settingsRepository retrievePublishSettings];
    self.subscribeSettings = [self.settingsRepository retrieveSubscribeSettings];

    [self.tableView reloadData];
}


//-------------------------------------------------------------------------------------------
#pragma mark - Table Datasource
//-------------------------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    if(section == SessionSummarySessionSection)
    {
        switch ((SessionSummarySessionRows)row)
        {
            case SessionSummarySessionURLRow:
                cell.detailTextLabel.text = self.roomSettings.url;
                break;
            case SessionSummarySessionRoomTypeRow:
                cell.detailTextLabel.text = NSStringFromRoomType(self.roomSettings.type);
                break;
            case SessionSummarySessionUserRoleRow:
                cell.detailTextLabel.text = NSStringFromUserRole(self.roomSettings.userRole);
                break;
        }
    }else if (section == SessionSummaryPubSubSection)
    {
        switch ((SessionSummaryPubSubRows)row)
        {
            case SessionSummaryPubSubPublishModeRow:
                cell.detailTextLabel.text = NSStringFromPublishMode(self.publishSettings.mode);
                break;
            case SessionSummaryPubSubSubscribeModeRow:
                cell.detailTextLabel.text = NSStringFromSubscribeMode(self.subscribeSettings.mode);
                break;
        }
    }

    return cell;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)settingsBarButtonTouched:(id)sender
{
    [self performSegueWithIdentifier:SHOW_SETTINGS_SEGUE sender:sender];
}

- (IBAction)callBarButtonTouched:(id)sender
{
    [self requestToken];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Segue
//-------------------------------------------------------------------------------------------

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender
{
    if([segue.identifier isEqualToString:SHOW_ROOM_SEGUE])
    {
        RoomViewController *roomViewController = segue.destinationViewController;
        roomViewController.token = self.roomToken;
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - User Interactions
//-------------------------------------------------------------------------------------------

- (void)enableUserInteractions
{
    self.settingsBarButtonItem.enabled = YES;
    self.callBarButtonItem.enabled = YES;
    self.view.userInteractionEnabled = YES;
}

- (void)disableUserInteractions
{
    self.settingsBarButtonItem.enabled = NO;
    self.callBarButtonItem.enabled = NO;
    self.view.userInteractionEnabled = NO;
}


//-------------------------------------------------------------------------------------------
#pragma mark - Private
//-------------------------------------------------------------------------------------------

- (void)requestToken
{
    [self disableUserInteractions];
    NSDictionary * requestBody = @{
            @"username": @"26",
            @"role": [self stringFromUserRole:self.roomSettings.userRole],
            @"room": @"basicExampleRoom",
            @"type": self.roomSettings.type == RoomTypeRelayed ? @"p2p" : @"erizo"
    };
    NSError * serializationError;
    NSData * requestData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&serializationError];

    if(serializationError)
    {
        [self showSerializationErrorAlert:serializationError];
        [self enableUserInteractions];
        return;
    }

    NSURL * url = [NSURL URLWithString:self.roomSettings.url];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = requestData;
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        dispatch_async(dispatch_get_main_queue(), ^{
//            [self hideActivityIndicatorInNavBar];
            [self enableUserInteractions];
        });


        if(error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showRequestFailedErrorAlert:error];
            });
            return;
        }

        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
        if(httpResponse.statusCode >= 200 && httpResponse.statusCode < 300)
        {
            NSString * token = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            if(!token)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showInvalidResponseReceivedAlert];
                });
                return;
            }

            BAVRoomToken * roomToken = [[BAVRoomToken alloc] initEncoded:token];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.roomToken = roomToken;
                [self showRoomController];
            });
        }

    }];

//    [self showActivityIndicatorInNavBar];
    [task resume];
}

- (NSString *)stringFromUserRole:(UserRole)role
{
    switch (role)
    {
        case UserRolePresenter:
            return @"presenter";
        case UserRoleViewer:
            return @"viewer";
        case UserRolePublishOnly:
            return @"publishOnly";
        case UserRoleViewerWithData:
            return @"viewerWithData";
    }
    return @"";
}

- (void)showRoomController
{
    [self performSegueWithIdentifier:SHOW_ROOM_SEGUE sender:self];
}


//-------------------------------------------------------------------------------------------
#pragma mark - Alerts
//-------------------------------------------------------------------------------------------


- (void)showSerializationErrorAlert:(NSError *)serializationError
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Serialization Error"
                                                                              message:[serializationError localizedDescription]
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:dismissAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showRequestFailedErrorAlert:(NSError *)error
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Request Failed"
                                                                              message:[error localizedDescription]
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:dismissAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showInvalidResponseReceivedAlert
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Couldn't deserialize Data"
                                                                              message:@"Invalid response received"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:dismissAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
