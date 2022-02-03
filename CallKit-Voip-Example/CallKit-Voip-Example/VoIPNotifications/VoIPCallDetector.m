//
// Copyright © 2018-Present. Kaleyra S.p.a. All Rights Reserved.
//

#import "VoIPCallDetector.h"
#import "VoIPPushNotificationHandlerDelegate.h"
#import "VoIPPushTokenHandler.h"
#import "VoIPPushNotificationHandler.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VoIPCallDetector () <VoIPPushNotificationHandlerDelegate>

@property (nonatomic, strong, readwrite, nullable) PKPushRegistry *pushRegistry;
@property (nonatomic, strong, readonly) id<PKPushRegistryDelegate> registryDelegate;
@property (nonatomic, strong, readonly) id<ApplicationStateChangeObservable> appStateObserver;
@property (nonatomic, strong, nullable) id <PKPushRegistryDelegate> currentRegistryDelegate;
@property (nonatomic, assign, readwrite, getter=isDetecting) BOOL detecting;

@end

@implementation VoIPCallDetector

@synthesize delegate = _delegate;

- (void)setCurrentRegistryDelegate:(id <PKPushRegistryDelegate>)currentRegistryDelegate
{
    _currentRegistryDelegate = currentRegistryDelegate;
    self.pushRegistry.delegate = currentRegistryDelegate;
}

- (instancetype)initWithRegistryDelegate:(id<PKPushRegistryDelegate>)registryDelegate
{
    self = [self initWithRegistryDelegate:registryDelegate appStateObserver:[[ApplicationStateChangeObserver alloc] init]];

    return self;
}

- (instancetype)initWithRegistryDelegate:(id<PKPushRegistryDelegate>)registryDelegate
                        appStateObserver:(id<ApplicationStateChangeObservable>)appStateObserver
{
    self = [super init];

    _registryDelegate = registryDelegate;
    _appStateObserver = appStateObserver;
    [_appStateObserver addListener:self];

    return self;
}

- (void)start
{
    if (self.isDetecting)
        return;

    self.detecting = YES;

    self.pushRegistry = [[PKPushRegistry alloc] initWithQueue: dispatch_queue_create("_VoIP_notification_queue_identifier", nil)];

    if (self.appStateObserver.isCurrentAppStateBackground)
    {
        [self attachBackgroundHandler];
    }
    else
    {
        [self attachForegroundHandler];
    }

    self.pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];

    if ([self.delegate respondsToSelector:@selector(detectorDidStart)])
        [self.delegate detectorDidStart];

}

- (void)stop
{
    if (!self.isDetecting)
        return;

    self.pushRegistry.delegate = nil;
    self.pushRegistry = nil;
    self.detecting = NO;

    if ([self.delegate respondsToSelector:@selector(detectorDidStop)])
        [self.delegate detectorDidStop];
}

- (void)onApplicationDidBecomeActive
{
    [self attachForegroundHandler];
}

- (void)onApplicationDidEnterBackground
{
    [self attachBackgroundHandler];
}

- (void)attachForegroundHandler
{
    if (self.pushRegistry != nil)
    {
        self.currentRegistryDelegate = [VoIPPushTokenHandler tokenHandlerWithRegistryDelegate:self.registryDelegate];
    }
}

-(void)attachBackgroundHandler
{
    if (self.pushRegistry != nil)
    {
        self.currentRegistryDelegate = [VoIPPushNotificationHandler handlerWithRegistryDelegate:self.registryDelegate delegate:self];
    }
}

- (void)handle:(nonnull PKPushPayload *)payload
{
    if (self.delegate != nil)
    {
        [self.delegate handle:payload];
    }
}

@end
