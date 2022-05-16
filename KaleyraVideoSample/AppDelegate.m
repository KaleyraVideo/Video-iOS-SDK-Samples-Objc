//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import "AppDelegate.h"
#import "AddressBook.h"
#import "AppConfig.h"
#import "Constants.h"
#import "VoIPNotifications/VoIPCallDetector.h"
#import "VoIPNotifications/VoIPCallDetectorDelegate.h"
#import "UIColor+Custom.h"
#import "UIFont+Custom.h"
#import "HashtagFormatter.h"

#import <Bandyer/Bandyer.h>
#import <PushKit/PushKit.h>
#import <Intents/Intents.h>
#import <CallKit/CallKit.h>

@interface AppDelegate () <PKPushRegistryDelegate, VoIPCallDetectorDelegate>

@property (nonatomic, strong, readwrite, nullable) VoIPCallDetector *callDetector;

@end

@implementation AppDelegate


// Before we can get started, if you want to enable CallKit and VoIP notifications you
// must review your project configuration, and enable the required app capabilities .
// Namely, you must enable "Background modes" capability
// checking "Audio, AirPlay and Picture in Picture" and "Voice over IP" checkboxes on.
// You must also enable "Push notifications" capability even if you use VoIP notifications only.
//
// Privacy usage descriptions:
// You must add NSCameraUsageDescription and NSMicrophoneUsageDescription to your app Info.plist file.
// Those values are required to access microphone and camera. In this sample app, those values have been already added for you.
// Consider also to add NSPhotoLibraryUsageDescription key into app Info.plist in case you want your users to upload photos on our services.
//
// If your build target supports systems earlier than iOS 11, please add iCloud entitlement with at least Key-value storage checked,
// otherwise your app is going to crash anytime the user try to upload a document from iCloud.
// In this sample app, this is already done for you inside 'Signing & Capabilities' tab of project settings.
// To enable build on physical devices, you should disable bitcode on build settings tab of your target settings. In this sample app, this flag is already set for you.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Here we are going to initialize the Bandyer SDK
    // The sdk needs a configuration object where it is specified which environment the sdk should work in.
    BDKConfig *config = [[AppConfig default] makeSDKConfig:self];

    if (!config.voip.automaticallyHandleVoIPNotifications)
    {
        // If you have set the config `automaticallyHandleVoIPNotifications` to false you have to register to VoIP notifications manually.
        // This is an example of the required implementation.
        self.callDetector = [[VoIPCallDetector alloc] initWithRegistryDelegate:self];
        self.callDetector.delegate = self;
    }

    //Now we are ready to configure the SDK providing the configuration object previously created.
    [BandyerSDK.instance configure:config];

    return YES;
}

- (void)startCallDetectorIfNeeded
{
    if (self.callDetector != nil)
    {
        [self.callDetector start];
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Registry Delegate
//-------------------------------------------------------------------------------------------

// When the system notifies the SDK of the new VoIP push token
// The SDK will call this method (if set this instance as pushRegistryDelegate in the config object)
// Providing you the push token. You should send the token received to your back-end system
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type
{
    NSLog(@"Updated push credentials %@", pushCredentials.token);
}

//-------------------------------------------------------------------------------------------
#pragma mark - Handling SiriKit Intent
//-------------------------------------------------------------------------------------------

// When System call ui is shown to the user, it will show a "video" button if the call supports it.
// The code below will handle the siri intent received from the system and it will hand it to the call view controller
// if the controller is presented
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id <UIUserActivityRestoring>> *__nullable restorableObjects))restorationHandler
{
    if (@available(iOS 13.0, *))
    {
        if ([userActivity.interaction.intent isKindOfClass:INStartCallIntent.class])
        {
            [[BDKCallWindow instance] handleINStartCallIntent:(INStartCallIntent *) userActivity.interaction.intent];

            return YES;
        }
    }

    if ([userActivity.interaction.intent isKindOfClass:INStartVideoCallIntent.class])
    {
        [[BDKCallWindow instance] handleINStartVideoCallIntent:(INStartVideoCallIntent *) userActivity.interaction.intent];

        return YES;
    }

    return NO;
}

//-------------------------------------------------------------------------------------------
#pragma mark - VoIPCallDetectorDelegate protocol conformance
//-------------------------------------------------------------------------------------------

// This protocol conformance is required for the manually managed VoIP notification configuration, ignore it otherwise.
- (void)handle:(PKPushPayload *)payload
{
    // Once you received a VoIP notification and you want the sdk to handle it, call `handleNotification(_)` method on the sdk instance.
    [BandyerSDK.instance handleNotification:payload];
}

//-------------------------------------------------------------------------------------------
#pragma mark - UI Customization
//-------------------------------------------------------------------------------------------

- (void)applyTheme
{
    UIColor *accentColor = [UIColor accentColor];

    if (@available(iOS 13.0, *)) {
    } else
    {
        self.window.tintColor = accentColor;
    }

    // This is the core of your customisation possibility using Bandyer SDK theme.
    // Let's suppose that your app is highly customised. Setting the following properties will let you to apply your colors, bar properties and fonts to all Bandyer's view controllers.

    // Colors
    [BDKTheme defaultTheme].accentColor = accentColor;
    [BDKTheme defaultTheme].primaryBackgroundColor = [UIColor customBackground];
    [BDKTheme defaultTheme].secondaryBackgroundColor = [UIColor customSecondary];
    [BDKTheme defaultTheme].tertiaryBackgroundColor = [UIColor customTertiary];

    // Bars
    [BDKTheme defaultTheme].barTranslucent = NO;
    [BDKTheme defaultTheme].barStyle = UIBarStyleBlack;
    [BDKTheme defaultTheme].keyboardAppearance = UIKeyboardAppearanceDark;
    [BDKTheme defaultTheme].barTintColor = [UIColor customBarTintColor];

    //Fonts
    [BDKTheme defaultTheme].navBarTitleFont = [UIFont robotoMedium];
    [BDKTheme defaultTheme].secondaryFont = [UIFont robotoLight];
    [BDKTheme defaultTheme].bodyFont = [UIFont robotoThin];
    [BDKTheme defaultTheme].font = [UIFont robotoRegular];
    [BDKTheme defaultTheme].emphasisFont = [UIFont robotoBold];
    [BDKTheme defaultTheme].mediumFontPointSize = 15;
}

- (void)customizeInAppNotification
{
    //Only after the SDK is initialized, you can change the In-app notification theme and set a custom formatter.
    //If you try to set the theme or the formatter before SDK initialization, the notificationsCoordinator will be nil and sets will not be applied.
    //The formatter will be used to display the user information on the In-app notification heading.

    BDKTheme *theme = [[BDKTheme alloc] init];
    theme.secondaryFont = [[UIFont robotoRegular] fontWithSize:5];

    if ([BandyerSDK instance].notificationsCoordinator)
    {
        [BandyerSDK instance].notificationsCoordinator.theme = theme;
        [BandyerSDK instance].notificationsCoordinator.formatter = [[HashtagFormatter alloc] init];
    }
}

@end
