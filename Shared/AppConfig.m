//
//  AppConfig.m
//  KaleyraVideoSample
//
//  Created by Alessandro Limardo on 29/04/22.
//

#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>

#import "AppConfig.h"
#import "Constants.h"

@interface AppConfig()

@end

@implementation AppConfig

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _environment = BDKEnvironment.sandbox;
        _isCallkitEnabled = YES;
        _isFilesharingEnabled = YES;
        _isInAppScreensharingEnabled = YES;
        _isWhiteboardEnabled = YES;
        _isBroadcastScreensharingEnabled = YES;
    }
    
    return  self;
}

- (nonnull BDKConfig *)makeSDKConfig:(nullable id<PKPushRegistryDelegate>)registryDelegate
{
    BDKConfig * config = [self createSDKConfig];

    [self setupCallKit:config registryDelegate:registryDelegate];
    [self setupTools:config];

    return  config;
}

- (BDKConfig *)createSDKConfig
{
    BDKConfig * config = [[BDKConfig alloc] init];

    // Here we are telling the SDK we want to work in a sandbox environment.
    // Beware the default environment is production, we strongly recommend to test your app in a sandbox environment.
    config.environment = self.environment;

    return  config;
}

- (void)setupCallKit:(BDKConfig*)config registryDelegate:(nullable id<PKPushRegistryDelegate>)registryDelegate
{
    if (self.isCallkitEnabled)
    {
        [self enableCallKit:config registryDelegate:registryDelegate];
    }
    else
    {
        [self disableCallKit:config];
    }
}

// If you don't want to support CallKit
// you can set the isCallKitEnabled flag to false
// Beware though, if CallKit is disabled the call will end if the user leaves the app while a call is in progress
- (void)disableCallKit:(BDKConfig*)config
{
    // Here we are disabling CallKit support.
    // Make sure to disable CallKit, otherwise it will be enable by default
    config.callKitEnabled = NO;
}

// If you want to support CallKit, then:
// CallKit framework must be linked to your app and it must linked as a required framework,
// otherwise the app will have a weird behaviour when it is launched upon receiving a VoIP notification.
// Please check the project "Build Settings" tab under the "Other Linker Flags" directive that the CallKit
// framework is linked as required framework
- (void)enableCallKit:(BDKConfig*)config registryDelegate:(nullable id<PKPushRegistryDelegate>)registryDelegate
{
    // On iOS 10 and above this statement is not needed, the default configuration object
    // enables CallKit by default, it is here for completeness sake
    config.callKitEnabled = YES;

    // The following statement is going to change the name of the app that is going to be shown by the system call UI.
    // If you don't set this value during the configuration, the SDK will look for to the value of the
    // CFBundleDisplayName key (or the CFBundleName, if the former is not available) found in your App Info.plist

    config.nativeUILocalizedName = @"My wonderful app";

    // The following statement is going to change the ringtone used by the system call UI when an incoming call
    // is received. You should provide the name of the sound resource in the app bundle that is going to be used as
    // ringtone. If you don't set this value, the SDK will use the default system ringtone.

    // config.nativeUIRingToneSound = @"MyRingtoneSound";

    // The following statements are going to change the app icon shown in the system call UI. When the user answers
    // a call from the lock screen or when the app is not in foreground and a call is in progress, the system
    // presents the system call UI to the end user. One of the buttons gives the user the ability to get back into your
    // app. The following statements allows you to change that icon.
    // Beware, the configuration object property expects the image as an NSData object. You must provide a side
    // length 40 points square png image.
    // It is highly recommended to set this property, otherwise a "question mark" icon placeholder is used instead.

    UIImage *callKitIconImage = [UIImage imageNamed:@"callkit-icon"];
    config.nativeUITemplateIconImageData = UIImagePNGRepresentation(callKitIconImage);

    // The following statements will tell the BandyerSDK which type of handle the SDK should use with CallKit
    config.supportedHandleTypes = [NSSet setWithObject:@(CXHandleTypeGeneric)];

    if (registryDelegate)
    {
        // The following statement is going to tell the BandyerSDK which object it must forward device push tokens to when one is received.
        config.pushRegistryDelegate = registryDelegate;
    }

    //Set this flag to false if you want to manually handle VoIP notifications. This flag is ignored unless the `isCallKitEnabled` flag is set to `true`.
    config.automaticallyHandleVoIPNotifications = YES;
}

- (void)setupTools:(BDKConfig*)config
{
    [self setupBroadcastScreensharing: config];
    [self setupInAppScreensharing: config];
    [self setupFileSharing: config];
    [self setupWhiteboard: config];
}

- (void)setupInAppScreensharing:(BDKConfig*)config
{
    if (self.isInAppScreensharingEnabled)
    {
        config.inAppScreensharingConfiguration = [BDKInAppScreensharingToolConfiguration enabled];
    }
    else
    {
        config.inAppScreensharingConfiguration = [BDKInAppScreensharingToolConfiguration disabled];
    }
}

// If you don't want to support the broadcast screen sharing feature
// Comment the body of this method
- (void)setupBroadcastScreensharing:(BDKConfig*)config
{
    if (@available(iOS 12.0, *))
    {
        if (self.isBroadcastScreensharingEnabled)
        {
            // This configuration object enable the sdk to talk with the broadcast extension
            // You must provide the app group identifier used by your app and the upload extension bundle identifier

            config.broadcastScreensharingConfiguration = [BDKBroadcastScreensharingToolConfiguration enabledWithAppGroupIdentifier:[Constants appGroupIdentifier]
                                                                                                broadcastExtensionBundleIdentifier:[Constants broadcastExtensionBundleId]];
        }
        else
        {
            config.broadcastScreensharingConfiguration = [BDKBroadcastScreensharingToolConfiguration disabled];
        }
    }
}

- (void)setupFileSharing:(BDKConfig*)config
{
    if (self.isFilesharingEnabled)
    {
        config.fileshareConfiguration = [BDKFileshareToolConfiguration enabled];
    }
    else
    {
        config.fileshareConfiguration = [BDKFileshareToolConfiguration disabled];
    }
}

- (void)setupWhiteboard:(BDKConfig*)config
{
    if (self.isWhiteboardEnabled)
    {
        config.whiteboardConfiguration = [BDKWhiteboardToolConfiguration enabledWithUploadEnabled:YES];
    }
    else
    {
        config.whiteboardConfiguration = [BDKWhiteboardToolConfiguration disabled];
    }
}

+ (instancetype)default
{
    return [[AppConfig alloc] init];
}

@end
