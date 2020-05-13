//
//  Copyright © 2019 Bandyer. All rights reserved.
//

#import <Bandyer/Bandyer.h>

#import "ContactsViewController.h"
#import "CallOptionsTableViewController.h"
#import "AddressBook.h"
#import "CallOptionsItem.h"
#import "Contact.h"
#import "UserInfoFetcher.h"
#import "UserSession.h"
#import "ContactsNavigationController.h"
#import "ContactTableViewCell.h"
#import "AsteriskFormatter.h"

NSString *const kShowOptionsSegueIdentifier = @"showOptionsSegue";
NSString *const kContactCellIdentifier = @"userCellId";

@interface ContactsViewController () <CallOptionsTableViewControllerDelegate, BCXCallClientObserver, BDKCallWindowDelegate, BCHChannelViewControllerDelegate, BDKCallBannerControllerDelegate, ContactTableViewCellDelegate, BDKInAppChatNotificationTouchListener, BDKInAppFileShareNotificationTouchListener>

@property (nonatomic, weak) IBOutlet UISegmentedControl *callTypeSegmentedControl;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *callOptionsBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *callBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *logoutBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *userBarButtonItem;
@property (nonatomic, weak) UIView *toastView;

@property (nonatomic, strong) BDKCallWindow *callWindow;

@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *selectedContacts;
@property (nonatomic, copy) CallOptionsItem *options;
@property (nonatomic, strong) BDKCallBannerController *callBannerController;

@end

@implementation ContactsViewController

//-------------------------------------------------------------------------------------------
#pragma mark - Init
//-------------------------------------------------------------------------------------------

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
    _selectedContacts = [NSMutableArray new];
    _options = [CallOptionsItem new];
    _callBannerController = [BDKCallBannerController new];
}

//-------------------------------------------------------------------------------------------
#pragma mark - View
//-------------------------------------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];

    //When view loads we have to setup custom view controllers.
    [self setupCallBannerView];
    
    self.userBarButtonItem.title = [UserSession currentUser];
    [self disableMultipleSelection:NO];

    //When view loads we register as a client observer, in order to receive notifications about incoming calls received and client state changes.
    [BandyerSDK.instance.callClient addObserver:self queue:dispatch_get_main_queue()];
}

- (void)setupCallBannerView
{
    self.callBannerController.delegate = self;
    self.callBannerController.parentViewController = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.callBannerController show];
    [self setupNotificationCoordinator];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.callBannerController hide];
    [self disableNotificationCoordinator];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    //Remember to call viewWillTransitionTo on custom view controllers to update UI while rotating.
    [self.callBannerController viewWillTransitionTo:size withTransitionCoordinator:coordinator];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

//-------------------------------------------------------------------------------------------
#pragma mark -  Notification coordinator
//-------------------------------------------------------------------------------------------

- (void)setupNotificationCoordinator
{
    BandyerSDK.instance.notificationsCoordinator.chatListener = self;
    BandyerSDK.instance.notificationsCoordinator.fileShareListener = self;
    [BandyerSDK.instance.notificationsCoordinator start];
}

- (void)disableNotificationCoordinator
{
    [BandyerSDK.instance.notificationsCoordinator stop];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Making an Outgoing call
//-------------------------------------------------------------------------------------------

- (void)startOutgoingCall
{
    //To start an outgoing call we must create a `BDKMakeCallIntent` object specifying who we want to call, the type of call
    //we want to be performed, along with any call option.

    //Here we create the array containing the "user aliases" we want to contact.
    NSMutableArray *aliases = [NSMutableArray arrayWithCapacity:self.selectedContacts.count];
    for (NSIndexPath *indexPath in self.selectedContacts)
    {
        [aliases addObject:self.addressBook.contacts[(NSUInteger) indexPath.row].alias];
    }

    //Then we create the intent providing the aliases array (which is a required parameter) along with the type of call we want perform.
    //The record flag specifies whether we want the call to be recorded or not.
    //The maximumDuration parameter specifies how long the call can last.
    //If you provide 0, the call will be created without a maximum duration value.
    //We store the intent for later use, because we can present again the BDKCallViewController with the same call.
    BDKMakeCallIntent *intent = [BDKMakeCallIntent intentWithCallee:aliases type:self.options.type record:self.options.record maximumDuration:self.options.maximumDuration];

    //Then we trigger a presentation of BDKCallViewController.
    [self presentCallViewControllerForIntent:intent];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Receiving an incoming call
//-------------------------------------------------------------------------------------------

- (void)receiveIncomingCall
{
    //When the client detects an incoming call it will notify its observers through this method.
    //Here we are creating an `BDKIncomingCallHandlingIntent` object, storing it for later use,
    //then we trigger a presentation of BDKCallViewController.
    BDKIncomingCallHandlingIntent *intent = [[BDKIncomingCallHandlingIntent alloc] init];
    [self presentCallViewControllerForIntent:intent];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Call client state changes
//-------------------------------------------------------------------------------------------

- (void)callClient:(id <BCXCallClient>)client didReceiveIncomingCall:(id <BCXCall>)call
{
    [self receiveIncomingCall];
}

- (void)callClientDidStart:(id <BCXCallClient>)client
{
    self.view.userInteractionEnabled = YES;
    [self hideActivityIndicatorFromNavigationBar:YES];
    [self hideToast];
}

- (void)callClientDidStartReconnecting:(id <BCXCallClient>)client
{
    self.view.userInteractionEnabled = NO;
    [self showActivityIndicatorInNavigationBar:YES];
    [self showToastWithMessage:@"Client is reconnecting, please wait" color:UIColor.orangeColor];
}

- (void)callClientWillResume:(id <BCXCallClient>)client
{
    self.view.userInteractionEnabled = NO;
    [self showActivityIndicatorInNavigationBar:YES];
    [self showToastWithMessage:@"Client is resuming, please wait" color:UIColor.orangeColor];
}

- (void)callClientDidResume:(id <BCXCallClient>)client
{
    self.view.userInteractionEnabled = YES;
    [self hideActivityIndicatorFromNavigationBar:YES];
    [self hideToast];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Segue
//-------------------------------------------------------------------------------------------

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender
{
    if ([segue.identifier isEqualToString:kShowOptionsSegueIdentifier])
    {
        CallOptionsTableViewController *controller = segue.destinationViewController;
        controller.options = self.options;
        controller.delegate = self;
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Present Chat ViewController
//-------------------------------------------------------------------------------------------

- (void)presentChatFrom:(BCHChatNotification *)notification
{
    if (!self.presentedViewController)
    {
        [self presentChatFrom:self notification:notification];
    }
}

- (void)presentChatFrom:(UIViewController *)controller notification:(BCHChatNotification *)notification
{
    BCHOpenChatIntent *intent = [BCHOpenChatIntent openChatFrom:notification];

    [self presentChatFrom:controller intent:intent];
}

- (void)presentChatFrom:(UIViewController *)controller intent:(BCHOpenChatIntent *)intent
{
    BCHChannelViewController *channelViewController = [[BCHChannelViewController alloc] init];
    channelViewController.delegate = self;

    //Here we are configuring the channel view controller:
    // if audioButton is true, the channel view controller will show audio button on nav bar;
    // if videoButton is true, the channel view controller will show video button on nav bar;
    // if userInfoFetcher is set, the global userInfoFetcher will be overridden. WARNING!!!
    // if formatter is set, the default formatter will be overridden.

    UserInfoFetcher* userInfoFetcher = [[UserInfoFetcher alloc] initWithAddressBook:self.addressBook];

    //Here if we pass a nil userInfoFetcher, the Bandyer SDK will use the global one if set at initialization time, otherwise a default one. The same result is achieved without setting the configuration property.
    //Here if we pass a nil userInfoFetcher, the Bandyer SDK will use the global one if set at initialization time, otherwise a default one.
    //If we pass a nil formatter, the Bandyer SDK will use a default one.
    BCHChannelViewControllerConfiguration* configuration = [[BCHChannelViewControllerConfiguration alloc] initWithAudioButton:YES videoButton:YES userInfoFetcher:userInfoFetcher formatter:[AsteriskFormatter new]];
    
    //Otherwise you can use other initializer.
    //BCHChannelViewControllerConfiguration* configuration = [[BCHChannelViewControllerConfiguration alloc] init]; //Equivalent to BCHChannelViewControllerConfiguration* configuration = [[BCHChannelViewControllerConfiguration alloc] initWithAudioButton:NO videoButton:NO userInfoFetcher:nil, formatter: nil];

    //If no configuration is provided, the default one will be used, the one with nil user info fetcher and showing both of the buttons -> BCHChannelViewControllerConfiguration* configuration = [[BCHChannelViewControllerConfiguration alloc] initWithAudioButton:YES videoButton:YES userInfoFetcher:nil, formatter: nil];
    channelViewController.configuration = configuration;

    //Please make sure to set intent after configuration, otherwise the configuration will be not taking in charge.
    channelViewController.intent = intent;

    [controller presentViewController:channelViewController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Present Call ViewController
//-------------------------------------------------------------------------------------------

- (void)presentCallViewControllerForIntent:(id<BDKIntent>)intent
{
    [self prepareForCallViewControllerPresentation];

    //Here we tell the call window what it should do and we present the BDKCallViewController if there is no another call in progress.
    //Otherwise you should manage the behaviour, for example with a UIAlert warning.
    [self.callWindow presentCallViewControllerFor:intent completion:^(NSError * error) {
        if ([error.domain isEqualToString:BDKCallPresentationErrorDomain.value] && error.code == BDKCallPresentationErrorCodeAnotherCallOnGoing)
        {
            [self presentAlertControllerWithTitle:@"Warning" message:@"Another call ongoing."];
        }
        else if (error)
        {
            [self presentAlertControllerWithTitle:@"Error" message:@"Impossible to start a call now. Try again later"];
        }
    }];
}

-(void)presentAlertControllerWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];

    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)prepareForCallViewControllerPresentation
{
    [self initCallWindowIfNeeded];

    //Here we are configuring the BDKCallWindow instance
    //A `BDKCallViewControllerConfiguration` object instance is needed to customize the behaviour and appearance of the view controller.
    BDKCallViewControllerConfiguration *config = [[BDKCallViewControllerConfiguration alloc] init];

    //This url points to a sample mp4 video in the app bundle used only if the application is run in the simulator.
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"SampleVideo_640x360_10mb" ofType:@"mp4"]];
    config.fakeCapturerFileURL = url;

    //This statement tells the view controller which object, conforming to `BDKUserInfoFetcher` protocol, should use to present contact
    //information in its views.
    //The backend system does not send any user information to its clients, the SDK and the backend system identify the users in a call
    //using their user aliases, it is your responsibility to match "user aliases" with the corresponding user object in your system
    //and provide those information to the view controller
    config.userInfoFetcher = [[UserInfoFetcher alloc] initWithAddressBook:self.addressBook];

    //Here, we set the configuration object created. You must set the view controller configuration object before the view controller
    //view is loaded, otherwise an exception is thrown.
    //If a call is already ongoing, the new configuration is skipped.
    [self.callWindow setConfiguration:config];
}

- (void)initCallWindowIfNeeded
{
    //Please remember to reference the call window only once in order to avoid the reset of BDKCallViewController.
    if (self.callWindow)
    {
        return;
    }

    //Please be sure to have in memory only one instance of BDKCallWindow, otherwise an exception will be thrown.

    BDKCallWindow *window;

    if (BDKCallWindow.instance)
    {
        window = BDKCallWindow.instance;
    } else
    {
        //This will automatically save the new instance inside BDKCallWindow.instance.
        window = [[BDKCallWindow alloc] init];
    }

    //Remember to subscribe as the delegate of the window. The window  will notify its delegate when it has finished its
    //job
    window.callDelegate = self;

    self.callWindow = window;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Hide Call ViewController
//-------------------------------------------------------------------------------------------

- (void)hideCallViewController
{
    self.callWindow.hidden = YES;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)callTypeValueChanged:(UISegmentedControl *)sender
{
    if ([sender selectedSegmentIndex] == 0)
    {
        [self.selectedContacts removeAllObjects];
        [self disableMultipleSelection:YES];
        [self hideCallButtonInNavigationBar:YES];
        [self enableChatButtonOnVisibleCells];
    } else
    {
        [self enableMultipleSelection:YES];
        [self showCallButtonInNavigationBar:YES];
        [self disableChatButtonOnVisibleCells];
    }
}

- (IBAction)callBarButtonItemTouched:(UIBarButtonItem *)sender
{
    [self startOutgoingCall];
}

- (IBAction)callOptionsBarButtonTouched:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:kShowOptionsSegueIdentifier sender:self];
}

- (IBAction)logoutBarButtonTouched:(UIBarButtonItem *)sender
{
    //When the user sign off, we also stop the client.
    //We highly recommend to stop the client when the end user signs off
    //Failing to do so, will result in incoming calls being processed by the SDK.
    //Moreover the previously logged user will appear to the Bandyer platform as she/he is available and ready to receive calls.
    [UserSession setCurrentUser:nil];
    [BandyerSDK.instance.callClient stop];

    [self dismissViewControllerAnimated:YES completion:NULL];
}

//-------------------------------------------------------------------------------------------
#pragma mark - StatusBar appearance
//-------------------------------------------------------------------------------------------

- (void)restoreStatusBarAppearance
{
    ContactsNavigationController *rootNavigationController = (ContactsNavigationController *) self.navigationController;

    if (rootNavigationController)
    {
        [rootNavigationController restoreStatusBarAppearance];
    }
}

- (void)setStatusBarAppearanceToLight
{
    ContactsNavigationController *rootNavigationController = (ContactsNavigationController *) self.navigationController;

    if (rootNavigationController)
    {
        [rootNavigationController setStatusBarAppearance:UIStatusBarStyleLightContent];
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Call options controller delegate
//-------------------------------------------------------------------------------------------

- (void)controllerDidUpdateOptions:(CallOptionsTableViewController *)controller
{
    self.options = controller.options;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Call window delegate
//-------------------------------------------------------------------------------------------

- (void)callWindowDidFinish:(BDKCallWindow *)window
{
    [self hideCallViewController];
}

- (void)callWindow:(BDKCallWindow *)window openChatWith:(BCHOpenChatIntent *)intent
{
    [self hideCallViewController];
    [self presentChatFrom:self intent:intent];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Channel view controller delegate
//-------------------------------------------------------------------------------------------

- (void)channelViewControllerDidFinish:(BCHChannelViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)channelViewController:(BCHChannelViewController *)controller didTapAudioCallWith:(NSArray *)users
{
    [self dismissChannelViewController:controller presentCallViewControllerWithCallee:users type:BDKCallTypeAudioUpgradable];
}

- (void)channelViewController:(BCHChannelViewController *)controller didTapVideoCallWith:(NSArray *)users
{
    [self dismissChannelViewController:controller presentCallViewControllerWithCallee:users type:BDKCallTypeAudioVideo];
}

- (void)channelViewController:(BCHChannelViewController *)controller willHide:(BDKCallBannerView *)banner
{
    [self restoreStatusBarAppearance];
}

- (void)channelViewController:(BCHChannelViewController *)controller willShow:(BDKCallBannerView *)banner
{
    [self setStatusBarAppearanceToLight];
}

- (void)channelViewController:(BCHChannelViewController *)controller didTouchBanner:(BDKCallBannerView *)banner
{
    //Please remember to override the current call intent with the one saved inside call window.
    id <BDKIntent> intent = self.callWindow.intent;
    [controller dismissViewControllerAnimated:YES completion:^{
        [self presentCallViewControllerForIntent:intent];
    }];
}

- (void)dismissChannelViewController:(BCHChannelViewController *)controller presentCallViewControllerWithCallee:(NSArray<NSString *> *)callee type:(BDKCallType)type
{
    if ([self.presentedViewController isKindOfClass:BCHChannelViewController.class])
    {
        [controller dismissViewControllerAnimated:YES completion:^{
            BDKMakeCallIntent *intent = [BDKMakeCallIntent intentWithCallee:callee type:type];
            [self presentCallViewControllerForIntent:intent];
        }];
        return;
    }

    BDKMakeCallIntent *intent = [BDKMakeCallIntent intentWithCallee:callee type:type];
    [self presentCallViewControllerForIntent:intent];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Call Banner Controller delegate
//-------------------------------------------------------------------------------------------

- (void)callBannerController:(BDKCallBannerController *_Nonnull)controller willHide:(BDKCallBannerView *_Nonnull)banner
{
    [self restoreStatusBarAppearance];
}

- (void)callBannerController:(BDKCallBannerController *_Nonnull)controller willShow:(BDKCallBannerView *_Nonnull)banner
{
    [self setStatusBarAppearanceToLight];
}

- (void)callBannerController:(BDKCallBannerController *_Nonnull)controller didTouch:(BDKCallBannerView *_Nonnull)banner
{
    //Please remember to override the current call intent with the one saved inside call window.
    id <BDKIntent> intent = self.callWindow.intent;
    if (intent) {
        [self presentCallViewControllerForIntent:intent];
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Enabling / Disabling multiple selection
//-------------------------------------------------------------------------------------------

- (void)enableMultipleSelection:(BOOL)animated
{
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;

    [self.tableView setEditing:YES animated:animated];
}

- (void)disableMultipleSelection:(BOOL)animated
{
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;

    [self.tableView setEditing:NO animated:animated];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Enabling / Disabling chat button
//-------------------------------------------------------------------------------------------

- (void)enableChatButtonOnVisibleCells
{
    NSArray <ContactTableViewCell *> *cells = (NSArray <ContactTableViewCell *> *) self.tableView.visibleCells;

    for (ContactTableViewCell *cell in cells)
    {
        [UIView animateWithDuration:0.3 animations:^(void) {
            cell.chatButton.alpha = 1;
        } completion:^(BOOL finished) {
            cell.chatButton.enabled = YES;
        }];
    }
}

- (void)disableChatButtonOnVisibleCells
{
    NSArray <ContactTableViewCell *> *cells = (NSArray <ContactTableViewCell *> *) self.tableView.visibleCells;

    for (ContactTableViewCell *cell in cells)
    {
        cell.chatButton.enabled = NO;

        [UIView animateWithDuration:0.3 animations:^(void) {
            cell.chatButton.alpha = 0;
        }];
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Table view data source
//-------------------------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.addressBook.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactTableViewCell * cell = (ContactTableViewCell * )
    [tableView dequeueReusableCellWithIdentifier:kContactCellIdentifier forIndexPath:indexPath];

    cell.delegate = self;

    Contact *contact = self.addressBook.contacts[(NSUInteger) indexPath.row];
    cell.titleLabel.text = [contact fullName];
    cell.subtitleLabel.text = [contact alias];

    if (tableView.allowsMultipleSelection)
    {
        cell.chatButton.enabled = NO;
        cell.chatButton.alpha = 0;
    } else
    {
        cell.chatButton.enabled = YES;
        cell.chatButton.alpha = 1;
    }

    return cell;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Table view delegate
//-------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.selectedContacts containsObject:indexPath])
    {
        [self.selectedContacts removeObject:indexPath];
    } else
    {
        [self.selectedContacts addObject:indexPath];
    }

    self.callBarButtonItem.enabled = self.selectedContacts.count > 1;

    if (!self.tableView.allowsMultipleSelection)
    {
        [self startOutgoingCall];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.selectedContacts removeAllObjects];
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Call button in navbar
//-------------------------------------------------------------------------------------------

- (void)showCallButtonInNavigationBar:(BOOL)animated
{
    UIBarButtonItem *callItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"phone"] style:UIBarButtonItemStylePlain target:self action:@selector(callBarButtonItemTouched:)];
    [self.navigationItem setRightBarButtonItem:callItem animated:animated];
    self.callBarButtonItem = callItem;
}

- (void)hideCallButtonInNavigationBar:(BOOL)animated
{
    [self.navigationItem setRightBarButtonItem:nil animated:animated];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Activity Indicator
//-------------------------------------------------------------------------------------------

- (void)showActivityIndicatorInNavigationBar:(BOOL)animated
{
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView startAnimating];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    [self.navigationItem setRightBarButtonItem:item animated:animated];
}

- (void)hideActivityIndicatorFromNavigationBar:(BOOL)animated
{
    if ([self.navigationItem.rightBarButtonItem.customView isKindOfClass:UIActivityIndicatorView.class])
        [self.navigationItem setRightBarButtonItem:nil animated:animated];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Toast Notification
//-------------------------------------------------------------------------------------------

- (void)showToastWithMessage:(NSString *)message color:(UIColor *)color
{
    [self hideToast];

    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = color;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textColor = UIColor.blackColor;
    label.font = [UIFont boldSystemFontOfSize:7];
    label.text = message;

    [view addSubview:label];
    [self.view addSubview:view];
    self.toastView = view;

    NSArray<NSLayoutConstraint*> *constraints = @[
            [label.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
            [label.centerYAnchor constraintEqualToAnchor:view.centerYAnchor],
            [view.topAnchor constraintEqualToAnchor:self.tableView.topAnchor],
            [view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
            [view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
            [view.heightAnchor constraintEqualToConstant:16]
        ];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)hideToast
{
    [self.toastView removeFromSuperview];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Contact table view cell delegate
//-------------------------------------------------------------------------------------------

- (void)contactTableViewCell:(ContactTableViewCell *_Nonnull)cell didTouch:(UIButton *_Nonnull)chatButton withCounterpart:(NSString *_Nonnull)aliasId
{

    BCHOpenChatIntent *intent = [BCHOpenChatIntent openChatWith:aliasId];

    [self presentChatFrom:self intent:intent];
}

//-------------------------------------------------------------------------------------------
#pragma mark - In-app notifications touch listeners
//-------------------------------------------------------------------------------------------

- (void)didTouchFileShareNotification:(BCHFileShareNotification *)notification
{
    if (_callWindow)
    {
        [self.callWindow presentCallViewControllerFor:[BDKOpenDownloadsIntent new] completion:^(NSError *_Nullable error) {}];
    }
}

- (void)didTouchChatNotification:(BCHChatNotification * _Nonnull)notification
{
    if ([self.presentedViewController isKindOfClass:BCHChannelViewController.class])
    {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            [self presentChatFrom:notification];
        }];
        return;
    }

    [self presentChatFrom:notification];
}

@end
