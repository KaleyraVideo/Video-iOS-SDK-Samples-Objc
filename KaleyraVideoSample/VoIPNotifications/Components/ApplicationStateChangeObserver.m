//
// Copyright © 2018-Present. Kaleyra S.p.a. All Rights Reserved.
//

#import "ApplicationStateChangeObserver.h"

#import <UIKit/UIKit.h>

@interface ApplicationStateChangeObserver ()

@property (nonatomic, strong, readonly) NSNotificationCenter *center;
@property (nonatomic, strong) id<ApplicationStateChangeListener> listener;

@end

@implementation ApplicationStateChangeObserver

- (instancetype)init
{
    self = [self initWithNotificationCenter:[NSNotificationCenter defaultCenter]];
    return self;
}

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)center
{
    self = [super init];

    if (self)
    {
        _center = center;
        [_center addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [_center addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }

    return self;
}

- (void)addListener:(nonnull id<ApplicationStateChangeListener>)listener
{
    self.listener = listener;
}

- (void)removeListener
{
    self.listener = nil;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self.listener onApplicationDidBecomeActive];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self.listener onApplicationDidEnterBackground];
}

- (BOOL)isCurrentAppStateBackground
{
    __block BOOL background = NO;

    dispatch_block_t block = ^{
        background = [[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground;
    };

    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }

    return background;
}

@end
