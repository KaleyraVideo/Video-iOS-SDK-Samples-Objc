// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

#import <BandyerCommunicationCenter/BandyerCommunicationCenter.h>

#import "LoginViewController.h"

@interface LoginViewController () <BCXCallClientObserver>

@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinnerView;

@end

@implementation LoginViewController

//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)loginButtonTouched:(UIButton *)sender
{
    self.view.userInteractionEnabled = NO;
    [self.spinnerView startAnimating];

    //Once you have authenticated your user, you are ready to initialize the call client instance.
    //The call client instance is responsible for making outgoing calls and detecting incoming calls.
    //In order to do its job it must connect to Bandyer platform first.

    //This statement is needed to register the current view controller as an observer of the call client.
    //When the client has started successfully or it has stopped, it will notify its observers about its state changes.
    [BandyerCommunicationCenter.instance.callClient addObserver:self];

    //This statement is needed to initialize the call client, establishing a secure connection with Bandyer platform.
    //In order to do so, a user alias must be provided to authenticate the device.
    //A user alias is an identifier that binds users of your app with users in Bandyer platform.
    //You should have obtained user aliases from your back-end or through the Bandyer REST API.

    [BandyerCommunicationCenter.instance.callClient initialize:@"PUT LOGIN USER ALIAS HERE"];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Call Client Observer
//-------------------------------------------------------------------------------------------

- (void)callClientDidStart:(BCXCallClient *)callClient
{
    //Once the call client has established a secure connection with Bandyer platform and it has been authenticated by the back-end system
    //you are ready to make calls and receive incoming calls.

    self.view.userInteractionEnabled = YES;
    [self.spinnerView stopAnimating];

    [self presentContactsInterface];
}

- (void)callClientDidStop:(BCXCallClient *)callClient
{
    //If the call client cannot establish a connection with Bandyer platform, or it has stopped for any reason, this method will be called.

    self.view.userInteractionEnabled = YES;
    [self.spinnerView stopAnimating];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Navigation
//-------------------------------------------------------------------------------------------

- (void)presentContactsInterface
{
    if(self.presentedViewController == nil)
        [self performSegueWithIdentifier:@"showContactsSegueId" sender:self];
}


@end
