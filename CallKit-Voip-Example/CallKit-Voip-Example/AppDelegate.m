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
    //Before you can get started, you must review your project configuration, and enable the required
    //app capabilities for CallKit and Voip notifications. Namely, you must enable "Background modes" capability
    //checking "Audio, AirPlay and Picture in Picture" and "Voice over IP" checkboxes on.
    //You must also enable "Push notifications" capability even if you use VOIP notifications only

    BDKEnvironment *env = BDKEnvironment.sandbox;
    BDKConfig *config = [BDKConfig new];
    config.environment = env;
    config.callKitEnabled = YES;

    [BandyerSDK.instance initializeWithApplicationId:@"YOUR_APP_ID" config:config];
    [BandyerSDK.instance.callClient addObserver:self queue:dispatch_get_main_queue()];

#if !TARGET_IPHONE_SIMULATOR
    self.registry = [[PKPushRegistry alloc] initWithQueue:nil];
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
    NSDictionary *incomingCallPayload = [dictionaryPayload valueForKeyPath:@"KEYPATH_TO_DATA_DICTIONARY"];

    //We ask the client to handle the notification payload
    [BandyerSDK.instance.callClient handleNotification:incomingCallPayload];

    //If everything went fine, client observers `callClient:didReceiveIncomingCall:` method will get invoked
}


@end
