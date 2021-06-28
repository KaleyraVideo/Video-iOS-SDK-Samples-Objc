//
//  Copyright © 2019 Bandyer. All rights reserved.
//

#import "AppDelegate.h"
#import "AddressBook.h"

#import <Bandyer/Bandyer.h>
#import <PushKit/PushKit.h>
#import <Intents/Intents.h>
#import <CallKit/CallKit.h>

@interface AppDelegate () <PKPushRegistryDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Before we can get started, you must review your project configuration, and enable the required
    //app capabilities for CallKit and VoIP notifications.
    
    //Namely, you must enable "Background modes" capability
    //checking "Audio, AirPlay and Picture in Picture" and "Voice over IP" checkboxes on.
    //You must also enable "Push notifications" capability even if you use VoIP notifications only.
    
    //Privacy usage descriptions:
    //You must add NSCameraUsageDescription and NSMicrophoneUsageDescription to your app Info.plist file.
    //Those values are required to access microphone and camera.
    //In this sample app, those values have been already added for you.
    
    //Consider also to add NSPhotoLibraryUsageDescription key into app Info.plist in case you want your users to upload photos on our services.

    //If your build target is less than iOS 11, please add iCloud entitlement with at least Key-value storage checked,
    //otherwise your app is going to crash anytime the user try to upload a document from iCloud.
    //In this sample app, this is already done for you inside 'Signing & Capabilities' tab of project settings.
    
    //To enable build on physical devices, you should disable bitcode on build settings tab of your target settings. In this sample app, this flag is already set for you.
    
    //CallKit:
    //CallKit framework must be linked to your app and it must linked as a required framework,
    //otherwise the app will have a weird behaviour when it is launched upon receiving a VoIP notification.
    //It is going to be launched, but the system is going to suspend it after few milliseconds.
    //In this example app, the CallKit framework has been already added for you.

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

    //The following statement is going to tell the BandyerSDK which object it must forward device push tokens to when one is received.
    config.pushRegistryDelegate = self;

    if (@available(iOS 12.0, *))
    {
        // This configuration object enable the sdk to talk with the broadcast extension
        config.broadcastScreensharingConfiguration = [BDKBroadcastScreensharingToolConfiguration
                                                      enabledWithAppGroupIdentifier:@"APP_GROUP_IDENTIFIER_GOES_HERE"
                                                      broadcastExtensionBundleIdentifier:@"EXTENSION_BUNDLE_IDENTIFIER_GOES_HERE"];
    }

#error("Please set your notification payload keypath here")
    //This statement is going to tell the BandyerSDK where to look for incoming call information within the VoIP push notifications it receives.
    config.notificationPayloadKeyPath = @"SET YOUR PAYLOAD KEY PATH HERE";

#error("Please initialize the Bandyer SDK with your App Id")
    //Now we are ready to initialize the SDK providing the app id token identifying your app in Bandyer platform.
    [BandyerSDK.instance initializeWithApplicationId:@"PUT YOUR APP ID HERE" config:config];

    return YES;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Registry Delegate
//-------------------------------------------------------------------------------------------

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type
{
    //Update push token credential in your back-end system.
    NSLog(@"Updated push credentials %@", pushCredentials.token);
}

//-------------------------------------------------------------------------------------------
#pragma mark - Handling SiriKit Intent
//-------------------------------------------------------------------------------------------

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id <UIUserActivityRestoring>> *__nullable restorableObjects))restorationHandler
{
    //When System call ui is shown to the user, it will show a "video" button if the call supports it.
    //The code below will handle the siri intent received from the system and it will hand it to the call view controller
    //if the controller is presented.

    if (@available(iOS 13.0, *))
    {
        if ([userActivity.interaction.intent isKindOfClass:INStartCallIntent.class])
        {
            UIViewController *visibleController = [self visibleController:self.window.rootViewController];

            if ([visibleController isKindOfClass:BDKCallViewController.class])
            {
                BDKCallViewController *callController = (BDKCallViewController *) visibleController;
                [callController handleINStartCallIntent:(INStartCallIntent *) userActivity.interaction.intent];
                return YES;
            }
        }
    } else
    {
        if (@available (iOS 10.0, *))
        {
            if ([userActivity.interaction.intent isKindOfClass:INStartVideoCallIntent.class])
            {
                UIViewController *visibleController = [self visibleController:self.window.rootViewController];

                if ([visibleController isKindOfClass:BDKCallViewController.class])
                {
                    BDKCallViewController *callController = (BDKCallViewController *) visibleController;
                    [callController handleINStartVideoCallIntent:(INStartVideoCallIntent *) userActivity.interaction.intent];
                    return YES;
                }
            }
        }
    }

    return NO;
}

- (UIViewController *)visibleController:(UIViewController *)rootController
{
    UIViewController *visibleVC = rootController;

    if (visibleVC.presentedViewController != nil)
    {
        if ([visibleVC.presentedViewController isKindOfClass:UINavigationController.class])
        {
            UINavigationController *navController = (UINavigationController *) visibleVC.presentedViewController;
            return [self visibleController:navController.viewControllers.lastObject];
        }

        return [self visibleController:visibleVC.presentedViewController];
    }

    return visibleVC;
}

@end
