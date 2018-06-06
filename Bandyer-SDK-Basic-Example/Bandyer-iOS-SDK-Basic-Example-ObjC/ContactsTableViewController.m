// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

#import <BandyerCommunicationCenter/BandyerCommunicationCenter.h>

#import "ContactsTableViewController.h"
#import "CallViewController.h"

@interface ContactsTableViewController () <BCXCallClientObserver, CallViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UISegmentedControl *callType;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *callButton;

@property (nonatomic, strong) NSMutableArray<NSString*> *selectedIndexes;

@end

@implementation ContactsTableViewController

static NSArray<NSString*> *users; //This is the array containing the users from your company, it should be filled with the aliases identifying each user in Bandyer platform.

+ (void)initialize
{
    users = @[];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Here we are subscribing as a call client observer. If the client detects an
    //incoming call, it will call our callClient:didReceiveIncomingCall: method implementation.
    [BandyerCommunicationCenter.instance.callClient addObserver:self];
    self.selectedIndexes = [NSMutableArray new];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)callTypeDidChange:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 1) //Conference
    {
        self.tableView.allowsMultipleSelection = YES;
        self.tableView.allowsMultipleSelectionDuringEditing = YES;
        [self.tableView setEditing:YES animated:YES];
    } else //Call
    {
        self.tableView.allowsMultipleSelection = NO;
        [self.tableView setEditing:NO animated:YES];
    }
}

- (IBAction)callButtonTouched:(UIBarButtonItem *)sender
{
    [self startCall];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Table Data Source
//-------------------------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCellId" forIndexPath:indexPath];
    
    cell.textLabel.text = users[indexPath.row];

    return cell;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Table Delegate
//-------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedId = users[indexPath.row];
    if([self.selectedIndexes containsObject:selectedId])
    {
        [self.selectedIndexes removeObject:selectedId];
    } else
    {
        [self.selectedIndexes addObject:selectedId];
    }

    if (!self.tableView.allowsMultipleSelection)
    {
        [self startCall];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.selectedIndexes removeAllObjects];
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Start Call
//-------------------------------------------------------------------------------------------


- (void)startCall
{
    if (self.selectedIndexes.count > 0)
    {
        self.view.userInteractionEnabled = NO;

        //This is how an outgoing call is started. You must provide an array of users alias identifying the contacts your user wants to communicate with.
        //Starting an outgoing call is an asynchronous process, failure or success are reported in the callback provided.
        [BandyerCommunicationCenter.instance.callClient callUsers:self.selectedIndexes
                                              completion:^(id <BCXCall> call, NSError *error) {

                                                  self.view.userInteractionEnabled = YES;

                                                  if (error)
                                                  {
                                                      //If an error occurs the call cannot be performed and an error will be
                                                      //provided as an argument in this block.
                                                      [self showCannotCreateCallAlert];
                                                  } else
                                                  {
                                                      //If the call is created successfully, we show the user interface responsible for
                                                      //handling the call. At this moment you cannot talk with the other users yet,
                                                      //the back-end system is taking care of notifying them that you want to make a call.
                                                      [self showCallInterface];
                                                  }
                                              }];
    }
}

- (void)showCannotCreateCallAlert
{
    NSString *message = [NSString stringWithFormat:@"Error while calling %@", self.selectedIndexes];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:NULL];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController animated:YES completion:NULL];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Call Center observer
//-------------------------------------------------------------------------------------------

- (void)callClient:(BCXCallClient *)callClient didReceiveIncomingCall:(id <BCXCall>)call
{
    //When the call client detects an incoming call has been received, it will notify its observer through this method
    //Now we are ready to show the User interface responsible for handling a call.
    [self showCallInterface];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Navigation
//-------------------------------------------------------------------------------------------

- (void)showCallInterface
{
    if (self.presentedViewController == nil)
    {
        [self performSegueWithIdentifier:@"showCallSegueId" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{
    if([segue.identifier isEqualToString:@"showCallSegueId"])
    {
        CallViewController *callController = segue.destinationViewController;
        callController.call = BandyerCommunicationCenter.instance.callClient.ongoingCall;
        callController.delegate = self;
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Call View Controller Delegate
//-------------------------------------------------------------------------------------------

- (void)callControllerDidEnd:(CallViewController *)controller
{
    if (self.presentedViewController != nil)
    {
        [self dismissViewControllerAnimated:YES completion:^{
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    }
}

@end
