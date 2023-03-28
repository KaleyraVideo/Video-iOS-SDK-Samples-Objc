//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
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
        _environment = BDKEnvironmentSandbox;
        _region = BDKRegionEurope;
        _automaticallyHandleVoIPNotifications = YES;
        _isCallkitEnabled = YES;
        _isFilesharingEnabled = YES;
        _isInAppScreensharingEnabled = YES;
        _isWhiteboardEnabled = YES;
        _isBroadcastScreensharingEnabled = YES;
        _isChatEnabled = YES;
    }
    
    return  self;
}

- (nonnull BDKConfig *)makeSDKConfig:(nullable id<PKPushRegistryDelegate>)registryDelegate
{
    BDKConfigBuilder * builder = [self createSDKConfig];

    [self setupVoIPNotifications:builder registryDelegate:registryDelegate];
    [self setupCallKit:builder];
    [self setupTools:builder];

    return  builder.build();
}

- (BDKConfigBuilder *)createSDKConfig
{
    // Here we are telling the SDK the app id token identifying your app in Bandyer platform, the region and the environment to connect to.
    // We strongly recommend to test your app in a sandbox environment before deploying it to production.
    BDKConfigBuilder *builder = BDKConfigBuilder.create([Constants appId], self.environment, self.region);

    return  builder;
}

- (void)setupVoIPNotifications:(BDKConfigBuilder*)builder registryDelegate:(nullable id<PKPushRegistryDelegate>)registryDelegate
{
    builder.voip(^(BDKVoIPPushConfigurationBuilder * voipBuilder) {
        
        if (self.automaticallyHandleVoIPNotifications && registryDelegate != nil)
        {
            //This is how you enable automatic VoIP notification handling.
            voipBuilder.automaticBackground(registryDelegate, nil);
        }
        else if (!self.automaticallyHandleVoIPNotifications)
        {
            //This is how you enable manual VoIP notification handling.
            voipBuilder.manual(nil);
        }
    });
}

- (void)setupCallKit:(BDKConfigBuilder*)builder
{
    builder.callKit(^(BDKCallKitConfigurationBuilder * callKitBuilder) {
        if (self.isCallkitEnabled)
        {
            [self enableCallKit:callKitBuilder];
        }
        else
        {
            [self disableCallKit:callKitBuilder];
        }
    });
}

// If you don't want to support CallKit
// you can set the isCallKitEnabled flag to false
// Beware though, if CallKit is disabled the call will end if the user leaves the app while a call is in progress
- (void)disableCallKit:(BDKCallKitConfigurationBuilder*)builder
{
    // Here we are disabling CallKit support.
    // Make sure to disable CallKit, otherwise it will be enable by default
    builder.disabled();
}

// If you want to support CallKit, then:
// CallKit framework must be linked to your app and it must linked as a required framework,
// otherwise the app will have a weird behaviour when it is launched upon receiving a VoIP notification.
// Please check the project "Build Settings" tab under the "Other Linker Flags" directive that the CallKit
// framework is linked as required framework
- (void)enableCallKit:(BDKCallKitConfigurationBuilder*)builder
{
    builder.enabledWithConfiguration(^(BDKCallKitProviderConfigurationBuilder * callKitProviderConfBuilder) {
        callKitProviderConfBuilder
        // The following statement is going to change the ringtone used by the system call UI when an incoming call
        // is received. You should provide the name of the sound resource in the app bundle that is going to be used as
        // ringtone. If you don't set this value, the SDK will use the default system ringtone.
        .ringtoneSound(@"MyRingtoneSound")
        // The following statements will tell the BandyerSDK which type of handle the SDK should use with CallKit
        .supportedHandles(@[@(CXHandleTypeGeneric)]);
        
        UIImage *callKitIcon = [UIImage imageNamed:@"callkit-icon"];
        if (callKitIcon)
        {
            // The following statements are going to change the app icon shown in the system call UI. When the user answers
            // a call from the lock screen or when the app is not in foreground and a call is in progress, the system
            // presents the system call UI to the end user. One of the buttons gives the user the ability to get back into your
            // app. The following statements allows you to change that icon.
            // You must provide a side length 40 points square png image.
            // It is highly recommended to set this property, otherwise a "question mark" icon placeholder is used instead.
            callKitProviderConfBuilder.iconImage(callKitIcon);
        }
    });
}

- (void)setupTools:(BDKConfigBuilder*)builder
{
    builder.tools(^(BDKToolsConfigurationBuilder * toolsBuilder) {
        [self setupBroadcastScreensharing: toolsBuilder];
        [self setupInAppScreensharing: toolsBuilder];
        [self setupFileSharing: toolsBuilder];
        [self setupWhiteboard: toolsBuilder];
        [self setupChat:toolsBuilder];
    });
}

- (void)setupInAppScreensharing:(BDKToolsConfigurationBuilder*)builder
{
    if (self.isInAppScreensharingEnabled)
    {
        // This is how you enable in-app screen sharing tool. By default this tool is disabled.
        builder.inAppScreensharing();
    }
}

// If you don't want to support the broadcast screen sharing feature
// Comment the body of this method
- (void)setupBroadcastScreensharing:(BDKToolsConfigurationBuilder*)builder
{
    if (self.isBroadcastScreensharingEnabled)
    {
        // This configuration object enable the sdk to talk with the broadcast extension
        // You must provide the app group identifier used by your app and the upload extension bundle identifier
        // By default this tool is disabled.
        builder.broadcastScreensharing([Constants appGroupIdentifier], [Constants broadcastExtensionBundleId]);
    }
}

- (void)setupFileSharing:(BDKToolsConfigurationBuilder*)builder
{
    if (self.isFilesharingEnabled)
    {
        // This is how you enable fileshare tool. By default this tool is disabled.
        builder.fileshare();
    }
}

- (void)setupWhiteboard:(BDKToolsConfigurationBuilder*)builder
{
    if (self.isWhiteboardEnabled)
    {
        // This is how you enable whiteboard tool. By default this tool is disabled.
        builder.whiteboard();
    }
}

- (void)setupChat:(BDKToolsConfigurationBuilder*)builder
{
    if (self.isChatEnabled)
    {
        // This is how you enable chat tool. By default this tool is disabled.
        builder.chat();
    }
}

+ (instancetype)default
{
    return [[AppConfig alloc] init];
}

@end
