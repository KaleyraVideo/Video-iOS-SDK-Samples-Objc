//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <UIKit/UIKit.h>
#import <BandyerCoreAV/BAVPublisher.h>
#import <BandyerCoreAV/BAVPublishOptions.h>

@class CreatePublisherViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol CreatePublisherViewControllerDelegate <NSObject>

- (void)createPublisherControllerDidCancel:(CreatePublisherViewController *)controller;
- (void)createPublisherController:(CreatePublisherViewController *)controller didCreatePublisher:(BAVPublisher *)publisher;

@end

@interface CreatePublisherViewController : UINavigationController

@property (nonatomic, weak) id<CreatePublisherViewControllerDelegate> createPublisherControllerDelegate;
@property (nonatomic, strong) BAVPublishOptions *options;

@end

NS_ASSUME_NONNULL_END
