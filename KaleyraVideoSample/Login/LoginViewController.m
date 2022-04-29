//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import <Bandyer/Bandyer.h>

#import "LoginViewController.h"
#import "ContactsViewController.h"
#import "AddressBook.h"
#import "UserRepository.h"
#import "UserSession.h"
#import "UserDetailsProvider.h"
#import "SessionFactory.h"

NSString *const kContactsSegueIdentifier = @"showContactsSegue";
NSString *const kUserCellIdentifier = @"userCellId";

@interface LoginViewController () <BDKCallClientObserver, BDKChatClientObserver>

@property (nonatomic, strong) NSArray<NSString*> *userIds;
@property (nonatomic, strong) NSString *selectedUserId;
@property (nonatomic, strong) UserRepository *repository;
@property(nonatomic) BOOL activityIndicatorShown;
@property (nonatomic, strong) AddressBook *addressBook;

@end

@implementation LoginViewController

- (void)setUserIds:(NSArray<NSString *> *)userIds
{
    _userIds = userIds;
    [self.tableView reloadData];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Init
//-------------------------------------------------------------------------------------------

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        [self _commonInit];
    }

    return self;
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self _commonInit];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self _commonInit];
    }

    return self;
}

- (void)_commonInit
{
    _repository = [UserRepository new];
    _selectedUserId = [UserSession currentUser];
}


//-------------------------------------------------------------------------------------------
#pragma mark - View
//-------------------------------------------------------------------------------------------

//This view controller acts as the root view controller of your app.
//In order for the SDK to receive or make calls we must start it specifying which user is connecting to Bandyer platform.
//Bandyer SDK uses an "user alias" to identify a user, you can think of it as an alphanumeric unique "slug" which identifies
//a user in your company. The SDK needs this "user alias" to connect, so you must retrieve it in some way from your back-end system.

//Let's pretend this is the login screen of your app where the user enters hers/his credentials.
//Once your app has been able to authenticate her/him, hers/his "user alias" should be available to you and it should be ready
//to be used to start the Bandyer SDK.
//In this sample app, we simulate those steps retrieving from our backend system all the users belonging to a company of our own.
//Then when the end user selects the user she/he wants to sign-in as, we start the SDK client and if everything went fine we let her/him
//proceed to the next screen.

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.refreshControl addTarget:self action:@selector(refreshControlDidRefresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self refreshUsers];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self cleanup];
}

- (void)cleanup
{
    self.selectedUserId = nil;
    self.addressBook = nil;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Fetching users
//-------------------------------------------------------------------------------------------

- (void)refreshUsers
{
    [self.refreshControl beginRefreshing];

    //Here we are fetching user information from our backend system.
    //We are doing this in order to have the list of available users we can impersonate.
    [self.repository fetchAllUsers:^(NSArray<NSString *> *userIds, NSError *error) {
        [self.refreshControl endRefreshing];

        if (!error)
        {
            self.userIds = userIds;

            [self loginUser];
        }
    }];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Login
//-------------------------------------------------------------------------------------------

- (void)loginUser
{
    if (!self.selectedUserId)
        return;
    
    // Once the end user has selected which user wants to impersonate, we create a Session object for that user.
    BDKSession *session = [SessionFactory makeSessionFor:self.selectedUserId];
    
    // Here we connect the BandyerSDK with the created Session object
    [BandyerSDK.instance connect:session];
    
    // We are registering as a call client observer in order to be notified when the client changes its state.
    // We are also providing the main queue telling the SDK onto which queue should notify the observer provided,
    // otherwise the SDK will notify the observer onto its background internal queue.
    [BandyerSDK.instance.callClient addObserver:self queue:dispatch_get_main_queue()];
    [BandyerSDK.instance.chatClient addObserver:self queue:dispatch_get_main_queue()];

    AddressBook *addressBook = [AddressBook createFromUserArray:self.userIds currentUser:self.selectedUserId];
    //This statement tells the Bandyer SDK which object, conforming to `UserDetailsProvider` protocol, should use to present contact
    //information in its views.
    //The backend system does not send any user information to its clients, the SDK and the backend system identify the users in any view
    //using their user aliases, it is your responsibility to match "user aliases" with the corresponding user object in your system
    //and provide those information to the Bandyer SDK.
    BandyerSDK.instance.userDetailsProvider = [[UserDetailsProvider alloc] initWithAddressBook:addressBook];

    self.addressBook = addressBook;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Call client observer
//-------------------------------------------------------------------------------------------

- (void)callClientDidChangeState:(id<BDKCallClient>)client oldState:(enum BDKCallClientState)oldState newState:(enum BDKCallClientState)newState
{
    if (newState == BDKCallClientStateRunning)
    {
        [self callClientDidStart: client];
    }
}

- (void)callClientWillChangeState:(id<BDKCallClient>)client oldState:(enum BDKCallClientState)oldState newState:(enum BDKCallClientState)newState
{
    if (newState == BDKCallClientStateStarting)
    {
        [self callClientWillStart: client];
    }
}

- (void)callClientWillStart:(id <BDKCallClient>)client
{
    [self clientsWillStart:BandyerSDK.instance.chatClient callClient:client];
}

- (void)callClientDidStart:(id <BDKCallClient>)client
{
    [self clientsDidStart:BandyerSDK.instance.chatClient callClient:client];
}

- (void)callClient:(id <BDKCallClient>)client didFailWithError:(NSError *)error
{
    //If the call client could not start for any reasons, this method will be called and the error occurred will be provided as argument.

    [self clients:BandyerSDK.instance.chatClient callClient:client didFailWithError:error];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Chat client observer
//-------------------------------------------------------------------------------------------

- (void)chatClientWillChangeState:(id<BDKChatClient>)client oldState:(enum BDKChatClientState)oldState newState:(enum BDKChatClientState)newState
{
    if (newState == BDKChatClientStateStarting)
    {
        [self chatClientWillStart: client];
    }
}

- (void)chatClientDidChangeState:(id<BDKChatClient>)client oldState:(enum BDKChatClientState)oldState newState:(enum BDKChatClientState)newState
{
    if (newState == BDKChatClientStateRunning)
    {
        [self chatClientDidStart: client];
    }
}

- (void)chatClientWillStart:(id <BDKChatClient>)client
{
    [self clientsWillStart:client callClient:BandyerSDK.instance.callClient];
}

- (void)chatClientDidStart:(id <BDKChatClient>)client
{
    [self clientsDidStart:client callClient:BandyerSDK.instance.callClient];
}

- (void)chatClient:(id <BDKChatClient>)client didFailWithError:(NSError *)error
{
    //If the chat client could not start for any reasons, this method will be called and the error occurred will be provided as argument.

   [self clients:client callClient:BandyerSDK.instance.callClient didFailWithError:error];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Clients observer wrapper
//-------------------------------------------------------------------------------------------

- (void)clientsWillStart:(id <BDKChatClient>)chatClient callClient:(id <BDKCallClient>)callClient
{
    if (callClient.state == BDKCallClientStateStarting ||
        chatClient.state == BDKChatClientStateStarting) {
        self.view.userInteractionEnabled = NO;

        [self showActivityIndicatorInNavigationBar];
    }
}

- (void)clientsDidStart:(id <BDKChatClient>)chatClient callClient:(id <BDKCallClient>)callClient
{
    //Once both clients did start, we can proceed to show the end user the contacts screen.

    if (callClient.state == BDKCallClientStateRunning && chatClient.state == BDKChatClientStateRunning) {
        if (self.presentedViewController != nil)
            return;

        [UserSession setCurrentUser:self.selectedUserId];

        [self performSegueWithIdentifier:kContactsSegueIdentifier sender:self];
        [self hideActivityIndicatorFromNavigationBar];
        self.view.userInteractionEnabled = YES;
    }
}

- (void)clients:(id <BDKChatClient>)chatClient callClient:(id <BDKCallClient>)callClient didFailWithError:(NSError *)error
{
    if (callClient.state == BDKCallClientStateStopped || chatClient.state == BDKChatClientStateFailed) {
        [self hideActivityIndicatorFromNavigationBar];
        self.view.userInteractionEnabled = YES;
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Table view datasource
//-------------------------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userIds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserCellIdentifier forIndexPath:indexPath];

    if (@available(iOS 14.0, *))
    {
        UIListContentConfiguration *config = [cell defaultContentConfiguration];
        config.text = self.userIds[(NSUInteger) indexPath.row];
        [cell setContentConfiguration:config];
    } else
    {
        cell.textLabel.text = self.userIds[(NSUInteger) indexPath.row];
    }

    return cell;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Table view delegate
//-------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedUserId = self.userIds[(NSUInteger) indexPath.row];
    [self loginUser];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)refreshControlDidRefresh:(UIRefreshControl *)sender
{
    [self refreshUsers];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Activity Indicator
//-------------------------------------------------------------------------------------------

- (void)showActivityIndicatorInNavigationBar
{

    if (self.activityIndicatorShown) {
        return;
    }

    UIActivityIndicatorViewStyle style;
    
    if (@available(iOS 13.0, *))
    {
        style = UIActivityIndicatorViewStyleMedium;
    } else
    {
        style = UIActivityIndicatorViewStyleGray;
    }

    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    [indicatorView startAnimating];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    [self.navigationItem setRightBarButtonItem:item animated:YES];

    self.activityIndicatorShown = YES;
}

- (void)hideActivityIndicatorFromNavigationBar
{
    if (!self.activityIndicatorShown) {
        return;
    }

    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    self.activityIndicatorShown = NO;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Navigating to Contact screen
//-------------------------------------------------------------------------------------------

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender
{
    if ([segue.identifier isEqualToString:kContactsSegueIdentifier])
    {
        UINavigationController *navController = segue.destinationViewController;
        ContactsViewController *controller = (ContactsViewController *) navController.topViewController;

        controller.addressBook = self.addressBook;
    }
}

@end
