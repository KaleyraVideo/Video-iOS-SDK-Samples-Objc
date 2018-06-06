//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <UIKit/UIKit.h>

@class CreateSubscriberViewController;
@class BAVSubscriber;

NS_ASSUME_NONNULL_BEGIN

@protocol CreateSubscriberViewControllerDelegate <NSObject>

- (void)createSubscriberControllerDidCancel:(CreateSubscriberViewController *)controller;
- (void)createSubscriberController:(CreateSubscriberViewController *)controller didCreateSubscriber:(BAVSubscriber *)subscriber;

@end

@interface CreateSubscriberViewController : UINavigationController

@property (nonatomic, weak) id<CreateSubscriberViewControllerDelegate> createSubscriberControllerDelegate;
@property (nonatomic, strong) NSArray<BAVStream*> *streams;

@end

NS_ASSUME_NONNULL_END
