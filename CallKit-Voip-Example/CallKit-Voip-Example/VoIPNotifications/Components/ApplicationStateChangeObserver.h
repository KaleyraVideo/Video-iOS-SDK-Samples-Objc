//
// Copyright © 2018-Present. Kaleyra S.p.a. All Rights Reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ApplicationStateChangeListener

- (void)onApplicationDidBecomeActive;
- (void)onApplicationDidEnterBackground;

@end

@protocol ApplicationStateChangeObservable

@property (nonatomic, assign, readonly, getter=isCurrentAppStateBackground) BOOL currentAppStateBackground;

- (void)addListener:(id <ApplicationStateChangeListener>)listener;
- (void)removeListener;

@end

NS_EXTENSION_UNAVAILABLE_IOS("This method uses APIs marked as unavailable for app extensions")
@interface ApplicationStateChangeObserver : NSObject <ApplicationStateChangeObservable>

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)center;

@end

NS_ASSUME_NONNULL_END
