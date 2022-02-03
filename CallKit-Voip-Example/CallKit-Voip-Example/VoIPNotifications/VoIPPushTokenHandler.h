//
// Copyright © 2018-Present. Kaleyra S.p.a. All Rights Reserved.
//

#import <PushKit/PushKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoIPPushTokenHandler : NSObject <PKPushRegistryDelegate>

@property (nonatomic, weak, readonly) id <PKPushRegistryDelegate> registryDelegate;

+ (instancetype)tokenHandlerWithRegistryDelegate:(id <PKPushRegistryDelegate>)delegate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

@interface VoIPPushTokenHandler (Protected)

- (instancetype)initWithRegistryDelegate:(id <PKPushRegistryDelegate>)registryDelegate;

@end

NS_ASSUME_NONNULL_END
