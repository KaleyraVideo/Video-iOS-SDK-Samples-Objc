//
//  Copyright © 2019 Bandyer. All rights reserved.
//

#import <PushKit/PushKit.h>
#import <BandyerSDK/BandyerSDK.h>

#import "AppDelegate.h"

@interface AppDelegate () <PKPushRegistryDelegate, BCXCallClientObserver>

@property (nonatomic, strong, nullable) PKPushRegistry *registry;
@property (nonatomic, strong, nullable) PKPushPayload *pendingPayload;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Before we can get started, you must review your project configuration, and enable the required
    //app capabilities for CallKit and Voip notifications.
    //
    //Namely, you must enable "Background modes" capability
    //checking "Audio, AirPlay and Picture in Picture" and "Voice over IP" checkboxes on.
    //You must also enable "Push notifications" capability even if you use VOIP notifications only.
    //
    //Privacy usage descriptions:
    //You must add NSCameraUsageDescription and NSMicrophoneUsageDescription to your app Info.plist file.
    //Those values are required to access microphone and camera. In this example app, those values have been already added for you
    //
    //CallKit:
    //CallKit framework must be linked to your app and it must linked as a required framework,
    //otherwise the app will have a weird behaviour when it is launched upon receiving a voip notification.
    //It is going to be launched, but the system is going to suspend it after few milliseconds.
    //In this example app, the CallKit framework has been already added for you.

    BDKEnvironment *env = BDKEnvironment.sandbox;
    BDKConfig *config = [BDKConfig new];
    config.environment = env;

    //On iOS 10 and above this statement is not needed, the default configuration object
    //enables CallKit by default, it is here for completeness sake
    config.callKitEnabled = YES;

    //The following statement is going to change the name of the app that is going to be shown by the system call UI.
    //If you don't set this value during the configuration, the SDK will look for to the value of the
    //CFBundleDisplayName key (or the CFBundleName, if the former is not available) found in your App Info.plist

    //config.nativeUILocalizedName = @"My wonderful app";

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

    //UIImage *callKitIconImage = [UIImage imageNamed:@"IMAGE FROM APP BUNDLE OR XCAsset"];
    //config.nativeUITemplateIconImageData = UIImagePNGRepresentation(callKitIconImage);

    [BandyerSDK.instance initializeWithApplicationId:@"YOUR_APP_ID" config:config];
    [BandyerSDK.instance.callClient addObserver:self queue:dispatch_get_main_queue()];
    
#if !TARGET_IPHONE_SIMULATOR
    self.registry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    self.registry.delegate = self;
    self.registry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
#endif

    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id <UIUserActivityRestoring>> *__nullable restorableObjects))restorationHandler
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

//-------------------------------------------------------------------------------------------
#pragma mark - Registry Delegate
//-------------------------------------------------------------------------------------------

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type
{
    //Update push token credential in your back-end system
    NSLog(@"Updated push credentials %@", pushCredentials.token);
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type
{
    //When a notification is received, we check whether the call client is up and running.
    if (BandyerSDK.instance.callClient.state == BCXCallClientStateRunning)
    {
        //If the client is up and running we hand it the notification payload received
        [self handlePushPayload:payload];
    } else
    {
        //Otherwise we temporarily store the payload
        self.pendingPayload = payload;
        //Then we resume the client (here we are assuming the client has been already started, and subsequently paused)
        [BandyerSDK.instance.callClient resume];
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Call client observer
//-------------------------------------------------------------------------------------------

- (void)callClientDidStart:(id <BCXCallClient>)client
{
    if (self.pendingPayload)
    {
        [self handlePushPayload:self.pendingPayload];
        self.pendingPayload = nil;
    }
}

- (void)callClientDidResume:(id<BCXCallClient>)client
{
    if (self.pendingPayload)
    {
        [self handlePushPayload:self.pendingPayload];
        self.pendingPayload = nil;
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Push Payload Handling
//-------------------------------------------------------------------------------------------

- (void)handlePushPayload:(PKPushPayload *)payload
{
    NSDictionary *dictionaryPayload = payload.dictionaryPayload;

    //You must change the keypath otherwise notifications won't be handled by the sdk
    NSDictionary *incomingCallPayload = [dictionaryPayload valueForKeyPath:@"KEYPATH_TO_DATA_DICTIONARY"];

    //We ask the client to handle the notification payload
    [BandyerSDK.instance.callClient handleNotification:incomingCallPayload];

    //If everything went fine, client observers `callClient:didReceiveIncomingCall:` method will get invoked
}


@end
