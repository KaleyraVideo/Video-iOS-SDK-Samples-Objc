// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

#import "CallViewController.h"
#import "RoomViewController.h"
#import "CalleeFormatter.h"

@interface CallViewController () <BCXCallObserver>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UIStackView *buttonsContainer;
@property (nonatomic, weak) IBOutlet UIButton *answerButton;
@property (nonatomic, weak) IBOutlet UIButton *declineButton;
@property (nonatomic, weak) IBOutlet UIButton *hangUpButton;

@end

@implementation CallViewController

- (void)setCall:(id <BCXCall>)call
{
    [_call removeObserver:self];
    _call = call;

    //This statement is needed to subscribe as a call observer. Once we are subscribed, we will be notified anytime the call changes its state.
    [_call addObserver:self];

    if (self.isViewLoaded)
    {
        [self updateCalleeLabel];
        [self updateButtons];
        [self updateImage];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateCalleeLabel];
    [self updateButtons];
    [self updateImage];
}

//-------------------------------------------------------------------------------------------
#pragma mark - View
//-------------------------------------------------------------------------------------------

- (void)updateCalleeLabel
{
    CalleeFormatter *formatter = [CalleeFormatter new];
    self.titleLabel.text = [formatter formatCallee:self.call];
}

- (void)updateButtons
{
    if (self.call.isIncoming && self.call.isRinging)
    {
        self.buttonsContainer.hidden = NO;
        self.hangUpButton.hidden = YES;
    } else
    {
        self.buttonsContainer.hidden = YES;
        self.hangUpButton.hidden = NO;
    }
}

- (void)updateImage
{
    if (self.call.isGroupCall)
    {
        self.profileImageView.image = [UIImage imageNamed:@"baseline_group_black_48pt"];
        self.profileImageView.contentMode = UIViewContentModeCenter;
    } else
    {
        self.profileImageView.image = [UIImage imageNamed:@"beautiful-blur-blurred-background-733872"];
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
}


//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)answerButtonTouched:(UIButton *)sender
{
    //We disable the user interaction because answering a call is an asynchronous process.
    self.view.userInteractionEnabled = NO;

    //Then we answer the call. The sdk will take care of notifying the other participants about our intent.
    [self.call answer];
}

- (IBAction)declineButtonTouched:(UIButton *)sender
{
    //We disable the user interaction because declining a call is an asynchronous process.
    self.view.userInteractionEnabled = NO;

    //Then we decline the call. The sdk will take care of notifying the other participants about our intent.
    [self.call decline];
}

- (IBAction)hangUpButtonTouched:(UIButton *)sender
{
    //We disable the user interaction because hanging up a call is an asynchronous process.
    self.view.userInteractionEnabled = NO;

    //Then we hang up the call. When the call has switched to ended state, we will be notified in the call observer.
    [self.call hangUp];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Call observer
//-------------------------------------------------------------------------------------------

- (void)call:(id <BCXCall>)call didChangeState:(BCXCallState)state
{
    //When the call changes its state, we update the buttons at the bottom of the screen in order to hide answer and
    //decline buttons (if we are handling an incoming call), and we show an hangup button.
    [self updateButtons];
}

- (void)callDidConnect:(id <BCXCall>)call
{
    //When the call has been connected, we can proceed to enter the virtual room where the call will take place.
    self.view.userInteractionEnabled = YES;
    [self showRoomInterface];
}

- (void)callDidEnd:(id <BCXCall>)call
{
    //When the call ends, we notify our delegate that we have finished our job and we want to be dismissed.
    [self.delegate callControllerDidEnd:self];
}

- (void)call:(id <BCXCall>)call didFailWithError:(NSError *)error
{
    //When the call fails, you are notified about the call failure and an error will be provided.
    //Here you could show an alert or a view / viewcontroller to notify the user, that an error occurred and
    //the call has been terminated.
    //Here, for simplicity reason, we notify our delegate that we want to be dismissed.
    [self.delegate callControllerDidEnd:self];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Navigation
//-------------------------------------------------------------------------------------------

- (void)showRoomInterface
{
    if (self.presentedViewController == nil)
        [self performSegueWithIdentifier:@"showRoomSegueId" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender
{
    if ([segue.identifier isEqualToString:@"showRoomSegueId"])
    {
        RoomViewController *roomController = segue.destinationViewController;
        roomController.call = BandyerCommunicationCenter.instance.callClient.ongoingCall;
    }
}


@end
