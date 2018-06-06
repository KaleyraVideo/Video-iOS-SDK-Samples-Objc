//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <BandyerCoreAV/BAVStream.h>
#import <BandyerCoreAV/BAVSubscriber.h>

#import "CreateSubscriberViewController.h"
#import "StreamSelectionTableViewController.h"
#import "SubscribeOptionsSelectionTableViewController.h"
#import "StreamInfoTableViewController.h"

@interface CreateSubscriberViewController () <UINavigationControllerDelegate, StreamSelectionTableViewControllerDelegate, SubscribeOptionsSelectionTableViewControllerDelegate>

@property (nonatomic, strong) BAVStream *selectedStream;
@property (nonatomic, strong) BAVStream *streamForInfo;
@property (nonatomic, strong) BAVSubscribeOptions *options;

@property (nonatomic, weak) StreamSelectionTableViewController *streamSelectionController;
@property (nonatomic, weak) SubscribeOptionsSelectionTableViewController *optionsSelectionController;

@end

@implementation CreateSubscriberViewController

- (instancetype)initWithNavigationBarClass:(nullable Class)navigationBarClass toolbarClass:(nullable Class)toolbarClass
{
    self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
    if (self)
    {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self)
    {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }

    return self;
}

- (void)commonInit
{
    self.delegate = self;
    self.options = [BAVSubscribeOptions new];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Navigation Controller
//-------------------------------------------------------------------------------------------

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([viewController isKindOfClass:StreamSelectionTableViewController.class])
    {
        self.streamSelectionController = (StreamSelectionTableViewController *) viewController;
        self.streamSelectionController.delegate = self;
        self.streamSelectionController.streams = self.streams;
    }else if([viewController isKindOfClass:SubscribeOptionsSelectionTableViewController.class])
    {
        self.optionsSelectionController = (SubscribeOptionsSelectionTableViewController *) viewController;
        self.optionsSelectionController.delegate = self;
        self.optionsSelectionController.options = self.options;
    }else if([viewController isKindOfClass:StreamInfoTableViewController.class])
    {
        StreamInfoTableViewController * streamInfoController = (StreamInfoTableViewController *) viewController;
        streamInfoController.stream = self.streamForInfo;
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Stream Selection Controller Delegate
//-------------------------------------------------------------------------------------------

- (void)streamSelectionController:(StreamSelectionTableViewController *)controller didSelectInfoForStream:(BAVStream *)stream
{
    self.streamForInfo = stream;
    [controller performSegueWithIdentifier:@"showStreamInfo" sender:self];
}

- (void)streamSelectionController:(StreamSelectionTableViewController *)controller didSelectStream:(BAVStream *)stream
{
    self.selectedStream = stream;
    [self.streamSelectionController performSegueWithIdentifier:@"showSubscribeOptions" sender:self];
}

- (void)streamSelectionController:(StreamSelectionTableViewController *)controller didDeselectStream:(BAVStream *)stream
{
    self.selectedStream = nil;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Subscribe Options Controller Delegate
//-------------------------------------------------------------------------------------------

- (void)subscribeOptionsSelectionController:(SubscribeOptionsSelectionTableViewController *)controller didChangeOptions:(BAVSubscribeOptions *)options
{
    self.options = options;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)doneBarButtonTouched:(UIBarButtonItem *)sender
{
    BAVSubscriber *subscriber = [[BAVSubscriber alloc] initWithStream:self.selectedStream];
    subscriber.subscribeOptions = self.options;
    [self.createSubscriberControllerDelegate createSubscriberController:self didCreateSubscriber:subscriber];
}

- (IBAction)cancelBarButtonTouched:(UIBarButtonItem *)sender
{
    [self.createSubscriberControllerDelegate createSubscriberControllerDidCancel:self];
}

@end
