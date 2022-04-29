//
//  AppConfig.h
//  KaleyraVideoSample
//
//  Created by Alessandro Limardo on 29/04/22.
//

#import <Bandyer/Bandyer.h>

@interface AppConfig : NSObject

@property (nonatomic, strong, nonnull) BDKEnvironment* environment;
@property (nonatomic) BOOL isCallkitEnabled;
@property (nonatomic) BOOL isFilesharingEnabled;
@property (nonatomic) BOOL isInAppScreensharingEnabled;
@property (nonatomic) BOOL isWhiteboardEnabled;
@property (nonatomic) BOOL isBroadcastScreensharingEnabled;

- (nonnull BDKConfig *)makeSDKConfig:(nullable id<PKPushRegistryDelegate>)registryDelegate;

+ (nonnull instancetype)default;

@end
