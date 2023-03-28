//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import <Bandyer/Bandyer.h>

@interface AppConfig : NSObject

@property (nonatomic, strong, nonnull) BDKEnvironment environment;
@property (nonatomic, strong, nonnull) BDKRegion region;

@property (nonatomic) BOOL automaticallyHandleVoIPNotifications;

@property (nonatomic) BOOL isCallkitEnabled;
@property (nonatomic) BOOL isFilesharingEnabled;
@property (nonatomic) BOOL isInAppScreensharingEnabled;
@property (nonatomic) BOOL isWhiteboardEnabled;
@property (nonatomic) BOOL isBroadcastScreensharingEnabled;
@property (nonatomic) BOOL isChatEnabled;

- (nonnull BDKConfig *)makeSDKConfig:(nullable id<PKPushRegistryDelegate>)registryDelegate;

+ (nonnull instancetype)default;

@end
