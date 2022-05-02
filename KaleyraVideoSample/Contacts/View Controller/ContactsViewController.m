//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import "ContactsViewController.h"
#import "CallOptionsTableViewController.h"
#import "AddressBook.h"
#import "CallOptionsItem.h"
#import "Contact.h"
#import "UserDetailsProvider.h"
#import "UserSession.h"
#import "ContactTableViewCell.h"
#import "AsteriskFormatter.h"
#import "UIColor+Custom.h"
#import "UIFont+Custom.h"
#import "PercentageFormatter.h"

#import <Bandyer/Bandyer.h>

NSString *const kShowOptionsSegueIdentifier = @"showOptionsSegue";
NSString *const kContactCellIdentifier = @"userCellId";

@interface ContactsViewController () <CallOptionsTableViewControllerDelegate, BDKCallClientObserver, BDKIncomingCallObserver, BDKCallWindowDelegate, BDKChannelViewControllerDelegate, ContactTableViewCellDelegate, BDKInAppChatNotificationTouchListener, BDKInAppFileShareNotificationTouchListener>

@property (nonatomic, weak) IBOutlet UISegmentedControl *callTypeSegmentedControl;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *callOptionsBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *callBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *logoutBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *userBarButtonItem;
@property (nonatomic, weak) UIView *toastView;

@property (nonatomic, strong) BDKCallWindow *callWindow;

@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *selectedContacts;
@property (nonatomic, copy) CallOptionsItem *options;

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
}

//-------------------------------------------------------------------------------------------
#pragma mark - View
//-------------------------------------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userBarButtonItem.title = [UserSession currentUser];
    [self disableMultipleSelection:NO];

    //When view loads we register as a client observer, in order to receive notifications about incoming calls received and client state changes.
    [BandyerSDK.instance.callClient addObserver:self queue:dispatch_get_main_queue()];
    [BandyerSDK.instance.callClient addIncomingCallObserver:self queue:dispatch_get_main_queue()];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setupNotificationCoordinator];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self disableNotificationCoordinator];
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
        [aliases addObject:self.addressBook.contacts[(NSUInteger) indexPath.row].userID];
    }

    //Then we create the intent providing the aliases array (which is a required parameter) along with the type of call we want perform.
    //The record flag specifies whether we want the call to be recorded or not.
    //The maximumDuration parameter specifies how long the call can last.
    //If you provide 0, the call will be created without a maximum duration value.
    //We store the intent for later use, because we can present again the BDKCallViewController with the same call.
    BDKStartOutgoingCallIntent *intent = [BDKStartOutgoingCallIntent intentWithCallees:aliases
                                                                               options: [BDKCallOptions optionsWithCallType:self.options.type recorded:self.options.record duration:self.options.maximumDuration]];

    //Then we trigger a presentation of BDKCallViewController.
    [self presentCallViewControllerForIntent:intent];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Receiving an incoming call
//-------------------------------------------------------------------------------------------

- (void)receiveIncomingCall:(id<BDKCall>)call
{
    //When the client detects an incoming call it will notify its observers through this method.
    //Here we are creating an `BDKHandleIncomingCallIntent` object, storing it for later use,
    //then we trigger a presentation of BDKCallViewController.
    BDKHandleIncomingCallIntent *intent = [[BDKHandleIncomingCallIntent alloc] initWithCall:call];
    [self presentCallViewControllerForIntent:intent];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Call client state changes
//-------------------------------------------------------------------------------------------

- (void)callClientWillChangeState:(id<BDKCallClient>)client oldState:(enum BDKCallClientState)oldState newState:(enum BDKCallClientState)newState
{
    if (newState == BDKCallClientStateResuming)
    {
        [self callClientWillResume];
    }
}

- (void)callClientDidChangeState:(id<BDKCallClient>)client oldState:(enum BDKCallClientState)oldState newState:(enum BDKCallClientState)newState
{
    if (newState == BDKCallClientStateRunning)
    {
        [self callClientDidStart];
    }
    else if (newState == BDKCallClientStateReconnecting)
    {
        [self callClientDidStartReconnecting];
    }
}

- (void)callClientDidStart
{
    self.view.userInteractionEnabled = YES;
    [self hideActivityIndicatorFromNavigationBar:YES];
    [self hideToast];
}

- (void)callClientDidStartReconnecting
{
    self.view.userInteractionEnabled = NO;
    [self showActivityIndicatorInNavigationBar:YES];
    [self showToastWithMessage:@"Client is reconnecting, please wait" color:UIColor.orangeColor];
}

- (void)callClientWillResume
{
    self.view.userInteractionEnabled = NO;
    [self showActivityIndicatorInNavigationBar:YES];
    [self showToastWithMessage:@"Client is resuming, please wait" color:UIColor.orangeColor];
}

//-------------------------------------------------------------------------------------------
#pragma mark - BDKIncomingCallObserver
//-------------------------------------------------------------------------------------------

- (void)callClient:(id <BDKCallClient>)client didReceiveIncomingCall:(id <BDKCall>)call
{
    [self receiveIncomingCall:call];
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

- (void)presentChatFrom:(BDKChatNotification *)notification
{
    if (!self.presentedViewController)
    {
        [self presentChatFrom:self notification:notification];
    }
}

- (void)presentChatFrom:(UIViewController *)controller notification:(BDKChatNotification *)notification
{
    BDKOpenChatIntent *intent = [BDKOpenChatIntent openChatFrom:notification];

    [self presentChatFrom:controller intent:intent];
}

- (void)presentChatFrom:(UIViewController *)controller intent:(BDKOpenChatIntent *)intent
{
    BDKChannelViewController *channelViewController = [[BDKChannelViewController alloc] init];
    channelViewController.delegate = self;

    //Here we are configuring the channel view controller:
    // if audioButton is true, the channel view controller will show audio button on nav bar;
    // if videoButton is true, the channel view controller will show video button on nav bar;
    // if formatter is set, the default formatter will be overridden.

    BDKChannelViewControllerConfiguration* configuration = [[BDKChannelViewControllerConfiguration alloc] initWithAudioButton:YES videoButton:YES formatter:[AsteriskFormatter new]];
    
    //Otherwise you can use other initializer.
    //BDKChannelViewControllerConfiguration* configuration = [[BDKChannelViewControllerConfiguration alloc] init]; //Equivalent to BDKChannelViewControllerConfiguration* configuration = [[BDKChannelViewControllerConfiguration alloc] initWithAudioButton:NO videoButton:NO formatter: nil];

    //If no configuration is provided, the default one will be used, the one with nil user info fetcher and showing both of the buttons -> BDKChannelViewControllerConfiguration* configuration = [[BDKChannelViewControllerConfiguration alloc] initWithAudioButton:YES videoButton:YES, formatter: nil];
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
        if (error)
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
    
    //This url points to a sample mp4 video in the app bundle used only if the application is run in the simulator.
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"SampleVideo_640x360_10mb" ofType:@"mp4"]];
    
    BDKCallViewControllerConfigurationBuilder *builder = BDKCallViewControllerConfigurationBuilder
        .create()
        .withFakeCapturerFileURL(url);

    BOOL customizeUI = NO;

    if (customizeUI)
    {
        //Comment this line to disable the call feedback popup
        builder.withFeedbackEnabled();

        //Let's suppose that you want to change the navBarTitleFont only inside the BDKCallViewController.
        //You can achieve this result by allocate a new instance of the theme and set the navBarTitleFont property whit the wanted value.
        BDKTheme *callTheme = [BDKTheme new];
        callTheme.navBarTitleFont = [UIFont .robotoBold fontWithSize:30];

        builder.withCallTheme(callTheme);

        //The same reasoning will let you change the accentColor only inside the Whiteboard view controller.
        BDKTheme *whiteboardTheme = [BDKTheme new];
        whiteboardTheme.accentColor = [UIColor systemBlueColor];

        builder.withWhiteboardTheme(whiteboardTheme);

        //You can also customize the theme only of the Whiteboard text editor view controller.
        BDKTheme *whiteboardTextEditorTheme = [BDKTheme new];
        whiteboardTextEditorTheme.bodyFont = [UIFont .robotoThin fontWithSize:30];

        builder.withWhiteboardTextEditorTheme(whiteboardTextEditorTheme);

        //In the next lines you can see how it's possible to customize the File Sharing view controller theme.
        BDKTheme *fileSharingTheme = [BDKTheme new];
        //By setting a point size property of the theme you can change the point size of all the medium/large labels.
        fileSharingTheme.mediumFontPointSize = 20;
        fileSharingTheme.largeFontPointSize = 40;

        builder.withFileSharingTheme(fileSharingTheme);

        // In the same way as other themes, you can customize the appearance of the call feedback popup by creating a new instance of Theme
        BDKTheme *feedbackTheme = [BDKTheme new];
        // Setting the accentColor property with the desired value will modify the color of the stars and the background color of the submit button
        feedbackTheme.accentColor = [UIColor systemGreenColor];
        // You can also customize the font and emphasisFont properties
        feedbackTheme.font = UIFont.robotoThin;
        feedbackTheme.emphasisFont = UIFont.robotoBold;

        // The delay in seconds after which the feedback popup is automatically dismissed when the user leaves a feedback.
        builder.withFeedbackEnabledUsingThemeAndAutoDismissDelay(feedbackTheme, 5);
        
        // Every single string in the feedback popup is customizable.
        // To make this customization just pass the bundle containing the localization with the right keys valorized, as in this example.
        // If your file is named 'Localizable' you don't need to set the TableName value, otherwise provide the filename
        builder.withCustomLocalizationsUsingBundleAndTableName([NSBundle mainBundle], @"ExampleLocalizable");

        //You can also format the way our SDK displays the user information inside the call page. In this example, the user info will be preceded by a percentage.
        builder.withCallInfoTitleFormatter([PercentageFormatter new]);
    }

    //Here, we set the configuration object created. You must set the view controller configuration object before the view controller
    //view is loaded, otherwise an exception is thrown.
    //If a call is already ongoing, the new configuration is skipped.
    [self.callWindow setConfiguration:builder.build()];
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
        self.callBarButtonItem.enabled = FALSE;
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
    //When the user sign off, we also stop the clients.
    //We highly recommend to stop the clients when the end user signs off
    //Failing to do so, will result in incoming calls and chat messages being processed by the SDK.
    //Moreover the previously logged user will appear to the Bandyer platform as she/he is available and ready to receive calls and chat messages.
    [UserSession setCurrentUser:nil];
    [BandyerSDK.instance disconnect];

    [self dismissViewControllerAnimated:YES completion:NULL];
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

- (void)callWindow:(BDKCallWindow *)window openChatWith:(BDKOpenChatIntent *)intent
{
    [self presentChatFrom:self intent:intent];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Channel view controller delegate
//-------------------------------------------------------------------------------------------

- (void)channelViewControllerDidFinish:(BDKChannelViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)channelViewController:(BDKChannelViewController *)controller didTapAudioCallWith:(NSArray *)users
{
    [self dismissChannelViewController:controller presentCallViewControllerWithCallees:users type:BDKCallTypeAudioUpgradable];
}

- (void)channelViewController:(BDKChannelViewController *)controller didTapVideoCallWith:(NSArray *)users
{
    [self dismissChannelViewController:controller presentCallViewControllerWithCallees:users type:BDKCallTypeAudioVideo];
}

- (void)dismissChannelViewController:(BDKChannelViewController *)controller presentCallViewControllerWithCallees:(NSArray<NSString *> *)callees type:(BDKCallType)type
{
    if ([self.presentedViewController isKindOfClass:BDKChannelViewController.class])
    {
        [controller dismissViewControllerAnimated:YES completion:^{
            BDKStartOutgoingCallIntent *intent = [BDKStartOutgoingCallIntent intentWithCallees:callees
                                                                                       options:[BDKCallOptions optionsWithCallType:type]];
            [self presentCallViewControllerForIntent:intent];
        }];
        return;
    }

    BDKStartOutgoingCallIntent *intent = [BDKStartOutgoingCallIntent intentWithCallees:callees
                                                                               options:[BDKCallOptions optionsWithCallType:type]];
    [self presentCallViewControllerForIntent:intent];
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
            cell.phoneImg.alpha = 1;
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
            cell.phoneImg.alpha = 0;
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
    cell.subtitleLabel.text = [contact userID];

    if (tableView.allowsMultipleSelection)
    {
        cell.chatButton.enabled = NO;
        cell.chatButton.alpha = 0;
        cell.phoneImg.alpha = 0;
    } else
    {
        cell.chatButton.enabled = YES;
        cell.chatButton.alpha = 1;
        cell.phoneImg.alpha = 1;
    }

    return cell;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Table view delegate
//-------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self bindSelectionOfContactFromRowAtIndexPath:indexPath];

    if (!self.tableView.allowsMultipleSelection)
    {
        [self startOutgoingCall];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.selectedContacts removeAllObjects];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.tableView.allowsMultipleSelection)
        return indexPath;

    [self bindSelectionOfContactFromRowAtIndexPath:indexPath];

    return indexPath;
}

- (void)bindSelectionOfContactFromRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.selectedContacts containsObject:indexPath])
    {
        [self.selectedContacts removeObject:indexPath];
    } else
    {
        [self.selectedContacts addObject:indexPath];
    }

    self.callBarButtonItem.enabled = self.selectedContacts.count > 1;
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
    BDKOpenChatIntent *intent = [BDKOpenChatIntent openChatWith:aliasId];

    [self presentChatFrom:self intent:intent];
}

//-------------------------------------------------------------------------------------------
#pragma mark - In-app notifications touch listeners
//-------------------------------------------------------------------------------------------

- (void)didTouchFileShareNotification:(BDKFileShareNotification *)notification
{
    if (_callWindow)
    {
        [self.callWindow presentCallViewControllerFor:[BDKOpenDownloadsIntent new] completion:^(NSError *_Nullable error) {}];
    }
}

- (void)didTouchChatNotification:(BDKChatNotification * _Nonnull)notification
{
    if ([self.presentedViewController isKindOfClass:BDKChannelViewController.class])
    {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            [self presentChatFrom:notification];
        }];
        return;
    }

    [self presentChatFrom:notification];
}

@end
