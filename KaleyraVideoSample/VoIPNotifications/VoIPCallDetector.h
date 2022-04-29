//
// Copyright © 2018-Present. Kaleyra S.p.a. All Rights Reserved.
//

#import <PushKit/PushKit.h>

#import "ApplicationStateChangeObserver.h"
#import "VoIPCallDetectorDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ApplicationStateChangeListener;
@protocol VoIPCallDetectorDelegate;

@interface VoIPCallDetector : NSObject <ApplicationStateChangeListener>

@property (nonatomic, assign, readonly, getter=isDetecting) BOOL detecting;
@property (nonatomic, weak, nullable) id<VoIPCallDetectorDelegate> delegate;

- (instancetype)initWithRegistryDelegate:(id <PKPushRegistryDelegate>)registryDelegate;

- (instancetype)initWithRegistryDelegate:(id <PKPushRegistryDelegate>)registryDelegate
                        appStateObserver:(id <ApplicationStateChangeObservable>)appStateObserver;

- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
