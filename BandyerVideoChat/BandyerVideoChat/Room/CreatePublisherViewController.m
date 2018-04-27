//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import "CreatePublisherViewController.h"
#import "PublishOptionsSelectionTableViewController.h"

@interface CreatePublisherViewController () <UINavigationControllerDelegate, PublishOptionsSelectionTableViewControllerDelegate>

@end

@implementation CreatePublisherViewController

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
    self.options = [BAVPublishOptions new];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Navigation Controller Delegate
//-------------------------------------------------------------------------------------------

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([viewController isKindOfClass:PublishOptionsSelectionTableViewController.class])
    {
        PublishOptionsSelectionTableViewController *controller = (PublishOptionsSelectionTableViewController *) viewController;
        controller.delegate = self;
        controller.options = self.options;
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Publish Options Selection Delegate
//-------------------------------------------------------------------------------------------

- (void)publishOptionsSelectionController:(PublishOptionsSelectionTableViewController *)controller didChangeOptions:(BAVPublishOptions *)options
{
    self.options = options;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)cancelBarButtonTouched:(UIBarButtonItem *)sender
{
    [self.createPublisherControllerDelegate createPublisherControllerDidCancel:self];
}

- (IBAction)doneBarButtonTouched:(UIBarButtonItem *)sender
{
    BAVPublisher *publisher = [[BAVPublisher alloc] init];
    publisher.publishOptions = self.options;

    [self.createPublisherControllerDelegate createPublisherController:self didCreatePublisher:publisher];
}

@end
