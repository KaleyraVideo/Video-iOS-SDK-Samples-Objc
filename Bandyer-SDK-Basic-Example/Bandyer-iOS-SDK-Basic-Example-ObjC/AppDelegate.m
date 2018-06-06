// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

#import <BandyerCommunicationCenter/BandyerCommunicationCenter.h>

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Before diving into the code, make sure your app's Info.plist contains an NSCameraUsageDescription key and
    //an NSMicrophoneUsageDescription key with the descriptions of why the user should grant access to those resources.
    //If those two keys are not found in the app's Info.plist when the camera or the microphone are accessed for the first time, the app
    //will crash in iOS 10.0 and above.

    //Now we are ready to go!
    //The first thing that must be done is to initialize the sdk

    //The following statement will set the log level to the highest priority, useful when debugging the application.
    [BandyerCommunicationCenter.instance setLogLevel:BDFDDLogLevelAll];

    //Here we set the sdk environment to sandbox, don't forget to set it to production when ready to release your app.
    [BandyerCommunicationCenter.instance setEnvironment:BCXEnvironment.sandbox];

    //This is the statement that will actually initialize the sdk with the configuration provided. Once initialized, you cannot change the environment the sdk is working in.
    [BandyerCommunicationCenter.instance initializeWithApplicationId:@"PUT YOUR APP ID HERE"];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    //When the app is about to go in background the call client must be stopped in order to signal Bandyer platform that the current device is not online anymore
    [BandyerCommunicationCenter.instance.callClient stop];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //When the app returns in foreground the call client should be resumed in order to signal Bandyer platform that the current device is not offline anymore
    [BandyerCommunicationCenter.instance.callClient resume];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [BandyerCommunicationCenter.instance.callClient stop];
}


@end
