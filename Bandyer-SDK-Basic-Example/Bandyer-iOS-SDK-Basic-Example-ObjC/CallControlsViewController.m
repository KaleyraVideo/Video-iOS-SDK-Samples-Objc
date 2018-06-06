// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

#import <BandyerCoreAV/BandyerCoreAV.h>

#import "CallControlsViewController.h"
#import "CalleeFormatter.h"

@interface CallControlsViewController () <BAVAudioSessionObserver, BAVRoomObserver, BAVPublisherObserver>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *switchCameraButton;
@property (nonatomic, weak) IBOutlet UIButton *micButton;
@property (nonatomic, weak) IBOutlet UIButton *hangUpButton;
@property (nonatomic, weak) IBOutlet UIButton *videoButton;
@property (nonatomic, weak) IBOutlet UIButton *speakerButton;

@property (nonatomic, assign) BOOL canOverrideAudioOutput;
@property (nonatomic, assign, getter=isOverridingAudioOutput) BOOL overridingAudioOutput;
@property (nonatomic, assign, getter=isOverridingAudioOnSpeaker) BOOL overridingAudioOnSpeaker;

@end

@implementation CallControlsViewController

- (void)setCall:(id <BCXCall>)call
{
    [_call.room removeObserver:self];
    _call = call;
    [_call.room addObserver:self];

    if (self.isViewLoaded)
    {
        [self updateCalleeLabel];
        [self updateButtons];
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - View
//-------------------------------------------------------------------------------------------


- (void)viewDidLoad
{
    [super viewDidLoad];

    //This view controller is responsible for handling the user interaction with the user.
    //The user can interact with the controls provided by this view controller, for switching between the front and back cameras (if present),
    //muting/unmuting the microphone, enabling/disabling the local video stream, changing the audio output device.

    [BAVAudioSession.instance addObserver:self];

#if TARGET_OS_IPHONE
    //iOS audio session is a bit tricky. When the user wants to override the audio output from
    //the built-in receiver (earpiece) to the loud speaker, we must change the audio output route on the audio session.
    //To do it so we must call "overrideAudioOutputPort:" method on the audio session singleton instance specifying "AVAudioSessionPortOverrideNone"
    //as method argument if we want route the audio output to the built-in receiver, or "AVAudioSessionPortOverrideSpeaker" as method argument
    //if we want route the audio output to the loud speaker. However, only iPhone devices have support for a built-in receiver,
    //on iPads and on Simulators there is not such a device.
    //To make things easy, we allow changing the audio route only on iPhone devices.
    self.canOverrideAudioOutput = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
#endif

    [self updateCalleeLabel];
    [self updateButtons];
}

- (void)updateCalleeLabel
{
    CalleeFormatter *formatter = [CalleeFormatter new];
    self.titleLabel.text = [formatter formatCallee:self.call];
}

- (void)updateButtons
{
    [self updateSwitchCameraButton];
    [self updateMicButton];
    [self updateVideoButton];
    [self updateSpeakerButton];
}

- (void)updateSwitchCameraButton
{
    //On simulators, camera support is missing, so we disable the switch camera button altogether.
#if TARGET_IPHONE_SIMULATOR
    [self.switchCameraButton setEnabled:NO];
#endif
}

- (void)updateMicButton
{
    BAVStream *localStream = self.call.room.publisher.stream;
    UIImage *image = [UIImage imageNamed:localStream.hasAudioEnabled ? @"baseline_mic_white_24pt" : @"baseline_mic_off_white_24pt"];

    [self.micButton setImage:image forState:UIControlStateNormal];
}

- (void)updateVideoButton
{
    BAVStream *localStream = self.call.room.publisher.stream;
    UIImage *image = [UIImage imageNamed:localStream.hasVideoEnabled ? @"baseline_videocam_white_24pt" : @"baseline_videocam_off_white_24pt"];

    [self.videoButton setImage:image forState:UIControlStateNormal];
}

- (void)updateSpeakerButton
{
    UIImage *image = [UIImage imageNamed:self.isOverridingAudioOnSpeaker ? @"baseline_volume_up_white_24pt" : @"baseline_speaker_phone_white_24pt" ];
    [self.speakerButton setImage:image forState:UIControlStateNormal];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)switchCameraButtonTouched:(UIButton *)sender
{
    //Please note that changing the camera position is NOT a synchronous process, it takes some time because the camera capture session
    //must be stopped, updated and restarted. All of these operations are executed on background queue asynchronously.
    //So you should disable the switch camera button for a while, in order to prevent the user from tapping on it when the camera capture session
    //is still restarting.
#if !TARGET_IPHONE_SIMULATOR
    [(BAVCameraCapturer *) self.call.room.publisher.capturer toggleCameraPosition];
#endif
}

- (IBAction)micButtonTouched:(UIButton *)sender
{
    BAVStream *localStream = self.call.room.publisher.stream;

    //Muting or unmuting the local audio is a pretty straightforward process, you just need to disable or enabled the audio of the publisher's stream.
    if(localStream.hasAudioEnabled)
    {
        [localStream disableAudio];
    } else
    {
        [localStream enableAudio];
    }

    [self updateMicButton];
}

- (IBAction)hangUpButtonTouched:(UIButton *)sender
{
    [self.call hangUp];
}

- (IBAction)videoButtonTouched:(UIButton *)sender
{
    BAVStream *localStream = self.call.room.publisher.stream;

    //Disabling or enabling the local video feed is a pretty straightforward process, you just need to disable or enabled the video of the publisher's stream.
    if(localStream.hasVideoEnabled)
    {
        [localStream disableVideo];
    } else
    {
        [localStream enableVideo];
    }

    [self updateVideoButton];
}

- (IBAction)speakerButtonTouched:(UIButton *)sender
{
    if (self.canOverrideAudioOutput && !self.isOverridingAudioOutput)
    {
        //Here we override temporarily the current audio output route. This is an asynchronous process and success or
        //failure will be reported in the audio session observer methods below.

        self.overridingAudioOutput = YES;
        if (self.isOverridingAudioOnSpeaker)
        {
            [BAVAudioSession.instance overrideAudioOutputPort:AVAudioSessionPortOverrideNone];
        } else
        {
            [BAVAudioSession.instance overrideAudioOutputPort:AVAudioSessionPortOverrideSpeaker];
        }
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Audio Session Observer
//-------------------------------------------------------------------------------------------

- (void)audioSession:(BAVAudioSession *)audioSession didOverrideOutputPort:(AVAudioSessionPortOverride)override
{
    //This method is invoked whenever the current audio output route is overridden successfully.
    //Please note that this method will be invoked only when we ask to override the audio output port explicitly on the audio session.
    //When audio route changes for any other reason this method won't be invoked, you must implement "audioSessionDidChangeRoute:reason:previousRoute:"
    //method if you want to be notified about audio route changes.

    self.overridingAudioOutput = NO;
    self.overridingAudioOnSpeaker = !(override == AVAudioSessionPortOverrideNone);

    [self updateSpeakerButton];
}

- (void)audioSession:(BAVAudioSession *)audioSession didFailToOverrideOutputPortWithError:(NSError *)error
{
    //This method is invoked whenever an override of the audio output port has failed.
    self.overridingAudioOutput = NO;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Room Observer
//-------------------------------------------------------------------------------------------


- (void)roomDidConnect:(BAVRoom *)room
{

}

- (void)roomDidDisconnect:(BAVRoom *)room
{

}

- (void)room:(BAVRoom *)room didFailWithError:(NSError *)error
{

}

- (void)room:(BAVRoom *)room didAddStream:(BAVStream *)stream
{

}

- (void)room:(BAVRoom *)room didRemoveStream:(BAVStream *)stream
{

}

- (void)room:(BAVRoom *)room didAddPublisher:(BAVPublisher *)publisher
{
    [publisher addObserver:self];
}

- (void)room:(BAVRoom *)room didRemovePublisher:(BAVPublisher *)publisher
{
    [publisher removeObserver:self];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Publisher Observer
//-------------------------------------------------------------------------------------------

- (void)publisherDidCreateStream:(BAVPublisher *)publisher
{
    [self updateButtons];
}

- (void)publisher:(BAVPublisher *)publisher didFailWithError:(NSError *)error
{

}


@end
