//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE.txt for licensing information
//

#import "AppDelegate.h"
#import "UIColor+Custom.h"
#import "UIFont+Custom.h"
#import "HashtagFormatter.h"
#import "AddressBook.h"

#import <Bandyer/Bandyer.h>
#import <CallKit/CallKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Before we dive into the details of how the SDK must be configured and initialized
    //you should add NSCameraUsageDescription and NSMicrophoneUsageDescription keys into app Info.plist
    //if you haven't done so already, otherwise your app is going to crash anytime it tries to access camera
    //or microphone devices.
    //In this sample app, those values have been already added for you.
    
    //To enable build on physical devices, you should disable bitcode on build settings tab of your target settings. In this sample app, this flag is already set for you.
    
    //Consider also to add NSPhotoLibraryUsageDescription key into app Info.plist in case you want your users to upload photos on our services.

    //If your build target is less than iOS 11, please add iCloud entitlement with at least Key-value storage checked,
    //otherwise your app is going to crash anytime the user try to upload a document from iCloud.
    //In this sample app, this is already done for you inside 'Signing & Capabilities' tab of project settings.
    
    //Here we are going to initialize the Bandyer SDK.
    //The sdk needs a configuration object where it is specified which environment the sdk should work in.
    BDKConfig *config = [BDKConfig new];
    
    //Here we are telling the SDK we want to work in a sandbox environment.
    //Beware the default environment is production, we strongly recommend to test your app in a sandbox environment.
    config.environment = BDKEnvironment.sandbox;

    //On iOS 10 and above this statement is not needed, the default configuration object
    //enables CallKit by default, it is here for completeness sake
    config.callKitEnabled = YES;

    //The following statement is going to change the name of the app that is going to be shown by the system call UI.
    //If you don't set this value during the configuration, the SDK will look for to the value of the
    //CFBundleDisplayName key (or the CFBundleName, if the former is not available) found in your App 'Info.plist'.
    config.nativeUILocalizedName = @"My wonderful app";

    //The following statement is going to change the ringtone used by the system call UI when an incoming call
    //is received. You should provide the name of the sound resource in the app bundle that is going to be used as
    //ringtone. If you don't set this value, the SDK will use the default system ringtone.

    //config.nativeUIRingToneSound = @"MyRingtoneSound";

    //The following statements are going to change the app icon shown in the system call UI. When the user answers
    //a call from the lock screen or when the app is not in foreground and a call is in progress, the system
    //presents the system call UI to the end user. One of the buttons gives the user the ability to get back into your
    //app. The following statements allows you to change that icon.
    //Beware, the configuration object property expects the image as an NSData object. You must provide a side
    //length 40 points square png image.
    //It is highly recommended to set this property, otherwise a "question mark" icon placeholder is used instead.
    UIImage *callKitIconImage = [UIImage imageNamed:@"callkit-icon"];
    config.nativeUITemplateIconImageData = UIImagePNGRepresentation(callKitIconImage);

    //The following statements will tell the BandyerSDK which handle type your BDKUserDetailsProvider will provide when requested.
    //When any call is performed the sdk will tell CallKit which is the name of the call opponent it should show on the system call UI
    //using a CallKit CXHandle object.
    config.supportedHandleTypes = [NSSet setWithObject:@(CXHandleTypeGeneric)];

#error "Please initialize the Bandyer SDK with your App Id"
    //Now we are ready to initialize the SDK providing the app id token identifying your app in Bandyer platform.
    [BandyerSDK.instance initializeWithApplicationId:@"PUT YOUR APP ID HERE" config:config];

    [self applyTheme];

    [self customizeInAppNotification];

    return YES;
}

- (void)applyTheme
{
    UIColor *accentColor = UIColor.accentColor;
    
    if (@available(iOS 14.0, *)) {
    } else {
        self.window.tintColor = accentColor;
    }
    
    //This is the core of your customisation possibility using Bandyer SDK theme.
    //Let's suppose that your app is highly customised. Setting the following properties will let you to apply your colors, bar properties and fonts to all Bandyer's view controllers.
    
    //Colors
    BDKTheme.defaultTheme.accentColor = accentColor;
    BDKTheme.defaultTheme.primaryBackgroundColor = UIColor.customBackground;
    BDKTheme.defaultTheme.secondaryBackgroundColor = UIColor.customSecondary;
    BDKTheme.defaultTheme.tertiaryBackgroundColor = UIColor.customTertiary;
    
    //Bars
    BDKTheme.defaultTheme.barTranslucent = FALSE;
    BDKTheme.defaultTheme.barStyle = UIBarStyleBlack;
    BDKTheme.defaultTheme.keyboardAppearance = UIKeyboardAppearanceDark;
    BDKTheme.defaultTheme.barTintColor = UIColor.customBarTintColor;
    
    //Fonts
    BDKTheme.defaultTheme.navBarTitleFont = UIFont.robotoMedium;
    BDKTheme.defaultTheme.secondaryFont = UIFont.robotoLight;
    BDKTheme.defaultTheme.bodyFont = UIFont.robotoThin;
    BDKTheme.defaultTheme.font = UIFont.robotoRegular;
    BDKTheme.defaultTheme.emphasisFont = UIFont.robotoBold;
    BDKTheme.defaultTheme.mediumFontPointSize = 15;
}

- (void)customizeInAppNotification
{
    //Only after the SDK is initialized, you can change the In-app notification theme and set a custom formatter.
    //If you try to set the theme or the formatter before SDK initialization, the notificationsCoordinator will be nil and sets will not be applied.
    //The formatter will be used to display the user information on the In-app notification heading.

    BDKTheme *theme = [BDKTheme new];
    theme.secondaryFont = [UIFont.robotoRegular fontWithSize:5];
    BandyerSDK.instance.notificationsCoordinator.theme = theme;

    BandyerSDK.instance.notificationsCoordinator.formatter = [HashtagFormatter new];
}

@end
