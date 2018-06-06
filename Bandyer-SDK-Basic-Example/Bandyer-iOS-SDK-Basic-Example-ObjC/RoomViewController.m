// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

#import "RoomViewController.h"
#import "CallControlsViewController.h"
#import "StreamsCollectionViewController.h"

@interface RoomViewController () <BAVRoomObserver, BAVPublisherObserver>

@property (nonatomic, weak) StreamsCollectionViewController *streamsViewController;
@property (nonatomic, weak) CallControlsViewController *controlsViewController;

@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *overlayGestureRecognizer;

@property (nonatomic, strong) NSTimer *overlayAutoDismissTimer;
@property (nonatomic, strong) BAVRoom *room;
@property (nonatomic, strong) BAVPublisher *publisher;

#if TARGET_IPHONE_SIMULATOR
@property (nonatomic, strong) BAVFileVideoCapturer *capturer;
@property (nonatomic, strong) BAVVideoView *localPreviewView;
#else
@property (nonatomic, strong) BAVCameraCapturer *capturer;
@property (nonatomic, strong) BAVCameraPreviewView *localPreviewView;
#endif

@property (nonatomic, strong) NSLayoutConstraint *topFullScreenLayoutConstraint;
@property (nonatomic, strong) NSLayoutConstraint *leftFullScreenLayoutConstraint;
@property (nonatomic, strong) NSLayoutConstraint *rightFullScreenLayoutConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomFullScreenLayoutConstraint;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

@end

@implementation RoomViewController

- (void)setCall:(id <BCXCall>)call
{
    _call = call;
    self.room = call.room;
}


- (void)setRoom:(BAVRoom *)room
{
    [_room removeObserver:self];
    _room = room;
    [_room addObserver:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    //This view controller will take care of handling the actual video call process.
    //The steps taken so far, were needed to contact the other participants and manage the call signaling. From this moment on, the actual
    //call can begin and we can start talking and seeing the other participants.

    //Please note, that you must add an NSCameraUsageDescription and an NSMicrophoneUsageDescription keys to your app's Info.plist, otherwise
    //on devices with iOS 10.0 or above installed, the app will crash as soon as the sdk tries to access the camera or the microphone.
    //Please also note that you must take care of camera and microphone permissions. If the user doesn't grant or revokes the permission
    //to access one of those two resources, the sdk will not complain and local video or audio streams will not be sent to the remote parties.
    //So you must check that the user has granted camera and microphone permissions before joining a room.

    [self setupAudioSession];
    [self setupCapturer];
    [self setupVideoPreview];

    [self addStreamsController];
    [self addOverlayController];
}

- (void)setupAudioSession
{
    //One of the first thing to do is setup the audio session, specifying the settings we want to use.
    //If we use the default settings, as in this case, the following statements could be skipped altogether.
    //If you don't setup an audio session, one will be setup automatically for you, with the default configuration and it will be started
    //automatically when needed.

    BAVAudioSession.instance.notificationQueue = dispatch_get_main_queue();
    BAVAudioSession.instance.manualAudio = NO;
    [BAVAudioSession.instance configureWithBlock:^(BAVAudioSessionConfiguration *configuration) {

    }];
}

- (void)setupCapturer
{
    //In the next step, we setup a capturer for a video source.

#if TARGET_IPHONE_SIMULATOR

    //The simulator doesn't provide camera support, so we must use a fake capturer that captures video frames from a video file.
    self.capturer = [[BAVFileVideoCapturer alloc] initWithFileNamed:@"SampleVideo_640x360_10mb" withExtension:@"mp4" inBundle:[NSBundle bundleForClass:self.class]];
#else
    //If we run the application on a real device, we have camera support, so we setup a camera capturer specifying the starting camera position
    //and a capture format. Although, you can use the default camera capture format and position.
    //Please note, that you must add an NSCameraUsageDescription key in you app's Info.plist. From iOS 10.0 and above this key is needed to access
    //the device camera, failing to do so will crash the app.
    //Once started, the system will prompt the user with a system alert asking the permission to use the camera.
    //Please note that the sdk will NOT take care of denied permissions, that is, in case of camera permissions denied, black frames will be
    //sent to other participants. You must take care of camera and microphone permissions before starting a call or before joining a room.
    AVCaptureDevicePosition position = AVCaptureDevicePositionFront;
    BAVVideoFormat *videoFormat = BAVVideoFormat.defaultFormat;
    self.capturer = [[BAVCameraCapturer alloc] initWithCameraPosition:position videoFormat:videoFormat];
#endif

    [self.capturer start];
}

- (void)setupVideoPreview
{
    //In order to see our camera feed we must add a camera preview view to our view hierarchy.
#if TARGET_IPHONE_SIMULATOR
    //If we run the app on the simulator we cannot use the camera capturer, and as a result we cannot use the camera preview view
    //so a video view must be created instead.
    //As a side note, this view will render the frame that will be sent to the other participants.
    self.localPreviewView = [[BAVVideoView alloc] initWithFrame:CGRectZero];
#else
    //The camera preview view will render the local camera feed.
    self.localPreviewView = [[BAVCameraPreviewView alloc] initWithFrame:CGRectZero];

    //Don't forget to set the capture session on the view, otherwise nothing will be rendered.
    self.localPreviewView.captureSession = self.capturer.captureSession;
#endif

    [self.view addSubview:self.localPreviewView];

    self.localPreviewView.translatesAutoresizingMaskIntoConstraints = NO;

    if (@available(iOS 11.0, *))
    {
        self.topFullScreenLayoutConstraint = [self.localPreviewView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor];
        self.leftFullScreenLayoutConstraint = [self.localPreviewView.leftAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leftAnchor];
        self.rightFullScreenLayoutConstraint = [self.localPreviewView.rightAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.rightAnchor];
        self.bottomFullScreenLayoutConstraint = [self.localPreviewView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor];
    } else
    {
        self.topFullScreenLayoutConstraint = [self.localPreviewView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor];
        self.leftFullScreenLayoutConstraint = [self.localPreviewView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor];
        self.rightFullScreenLayoutConstraint = [self.localPreviewView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor];
        self.bottomFullScreenLayoutConstraint = [self.localPreviewView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor];
    }

    self.widthConstraint = [self.localPreviewView.widthAnchor constraintEqualToConstant:120];
    self.heightConstraint = [self.localPreviewView.heightAnchor constraintEqualToConstant:120];

    self.topFullScreenLayoutConstraint.active = YES;
    self.leftFullScreenLayoutConstraint.active = YES;
    self.rightFullScreenLayoutConstraint.active = YES;
    self.bottomFullScreenLayoutConstraint.active = YES;
}

- (void)addStreamsController
{
    //Here we are using view controller containment to add a collection view controller that will take care of showing remotes participants
    //video feeds.
    StreamsCollectionViewController * streamsController = [self.storyboard instantiateViewControllerWithIdentifier:@"streamsController"];
    [self addChildViewController:streamsController];
    streamsController.room = self.room;
    streamsController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:streamsController.view];
    [streamsController didMoveToParentViewController:self];
    self.streamsViewController = streamsController;
}

- (void)addOverlayController
{
    //Here we are using view controller containment to add an overlay view controller that will the interaction with the user.
    CallControlsViewController *controlsController = [self.storyboard instantiateViewControllerWithIdentifier:@"controlsController"];
    [self addChildViewController:controlsController];
    controlsController.call = self.call;
    controlsController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:controlsController.view];
    [controlsController didMoveToParentViewController:self];
    self.controlsViewController = controlsController;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setNeedsStatusBarAppearanceUpdate];

    //Once the view is going to appear on screen, we will start joining the virtual room. This must be done only once.
    if (self.room.state != BAVRoomStateConnected)
        [self.room join];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self startOverlayAutoDismissTimer];
}

- (void)dealloc
{
    //Don't forget to stop the capturer, once the view controller is not needed anymore.
    [self.capturer stop];
    [self stopOverlayAutoDismissTimer];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Layout
//-------------------------------------------------------------------------------------------

- (void)resizeLocalPreview:(BOOL)fullscreen
{
    if (fullscreen)
        [self updateConstraintsForPreviewInFullScreen];
    else
        [self updateConstraintsForPreviewAsThumbnail];


    [UIView animateWithDuration:1 animations:^{
        [self.view layoutIfNeeded];
    }];

    [self.view bringSubviewToFront:self.localPreviewView];
}

- (void)updateConstraintsForPreviewInFullScreen
{
    self.topFullScreenLayoutConstraint.constant = 0;
    self.bottomFullScreenLayoutConstraint.constant = 0;

    self.widthConstraint.active = NO;
    self.heightConstraint.active = NO;

    self.topFullScreenLayoutConstraint.active = YES;
    self.leftFullScreenLayoutConstraint.active = YES;
    self.rightFullScreenLayoutConstraint.active = YES;
    self.bottomFullScreenLayoutConstraint.active = YES;
}

- (void)updateConstraintsForPreviewAsThumbnail
{
    self.topFullScreenLayoutConstraint.constant = -25;
    self.bottomFullScreenLayoutConstraint.constant = -90;

    self.widthConstraint.active = YES;
    self.heightConstraint.active = YES;

    self.topFullScreenLayoutConstraint.active = NO;
    self.leftFullScreenLayoutConstraint.active = NO;
    self.rightFullScreenLayoutConstraint.active = YES;
    self.bottomFullScreenLayoutConstraint.active = YES;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Room Observer
//-------------------------------------------------------------------------------------------


- (void)roomDidConnect:(BAVRoom *)room
{
    //When the room is successfully connected, we are ready to publish our audio and video streams.
    //We create a publisher that is responsible for interacting with the room.
    //The publisher will take care of streaming our video and audio feeds to the other participants in the room.
    self.publisher = [[BAVPublisher alloc] init];
    self.publisher.capturer = self.capturer;
    self.publisher.user = BandyerCommunicationCenter.instance.callClient.user;
    [self.publisher addObserver:self];

    //Once a publisher has been setup, we must publish its stream in the room.
    //Publishing is an asynchronous process. If something goes wrong while starting the publish process, an error will be set in the error object pointer
    //provided as argument. Otherwise if the publish process can be started, any error occurred will be reported
    //to the observers registered on the publisher object.
    NSError *error;
    [room publish:self.publisher error:&error];

    if (error)
        [self showPublishErrorAlert:error];
}

- (void)showPublishErrorAlert:(NSError *)error
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Publish Failed!" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL];
    [controller addAction:cancelAction];

    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)roomDidDisconnect:(BAVRoom *)room
{
    //When the room disconnects this method will be invoked on any room observer.
    //Here, we do nothing because the call will fail and the call view controller, and in turn this view controller, will be dismissed.
    //If your navigation flow is different you could for example prompt an error message to the user.
}

- (void)room:(BAVRoom *)room didFailWithError:(NSError *)error
{
    //When the room detects a fatal error, this method will be invoked on any room observer.
    //Here, we do nothing because the call will fail and the call view controller (and in turn this view controller) will be dismissed.
}

- (void)room:(BAVRoom *)room didAddStream:(BAVStream *)stream
{
    //When a new stream is added to the room this method will be invoked. Here we have the chance to subscribe to the stream just added.

    //First we check that the stream added is not our local stream, if so we ignore it because we cannot subscribe to our local stream.
    if([stream.streamId isEqualToString:self.publisher.stream.streamId])
        return;

    [self resizeLocalPreview:NO];

    //If a remote stream is added to the room we subscribe to it, creating a subscriber object that is responsible for handling the process
    //of subscribing to the remote audio and video feeds.
    BAVSubscriber *subscriber = [[BAVSubscriber alloc] initWithStream:stream];

    //Once a subscriber has been setup, we signal the room we are ready to subscribe to the remote stream.
    //Subscribing to a remote stream is an asynchronous process. If something goes wrong while starting the subscribe process an error will be
    //set in the error object pointer provided as argument. Otherwise, the subscribing process is started and any error occurring from this moment on
    //will be reported to the observers registered on the observer object.
    NSError *error;
    [self.room subscribe:subscriber error:&error];

    if (error)
        [self showSubscribeError:error];
}

- (void)showSubscribeError:(NSError *)error
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Subscribe Failed!" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL];
    [controller addAction:cancelAction];

    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)room:(BAVRoom *)room didRemoveStream:(BAVStream *)stream
{
    //When a stream is removed from the room, this method will be invoked. Here you have the chance to update your user interface or perform
    //other tasks

    //Here, for example, we update our local preview showing it in fullscreen.
    if(room.subscribers.count == 0)
        [self resizeLocalPreview:YES];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Publisher Observer
//-------------------------------------------------------------------------------------------

- (void)publisherDidCreateStream:(BAVPublisher *)publisher
{
    //When the publisher has created its stream, this method will be invoked.
    //Here we are adding the stream to the local preview view in order to render it. We do it only on simulator because on a real device
    //the camera feed is available as soon as the capture session starts.
#if TARGET_IPHONE_SIMULATOR
    self.localPreviewView.stream = publisher.stream;
    [self.localPreviewView startRendering];
#endif
}

- (void)publisher:(BAVPublisher *)publisher didFailWithError:(NSError *)error
{
    [self showPublishErrorAlert:error];
}


//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)overlayGestureRecognizerTapped:(UITapGestureRecognizer *)sender
{
    if(self.controlsViewController.isViewLoaded && self.controlsViewController.view.isHidden)
    {
        if(self.controlsViewController.view.isHidden)
        {
            [self showOverlay];
            [self startOverlayAutoDismissTimer];
        } else
        {
            [self hideOverlay];
            [self stopOverlayAutoDismissTimer];
        }
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Overlay
//-------------------------------------------------------------------------------------------

- (void)startOverlayAutoDismissTimer
{
    self.overlayAutoDismissTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(overlayDismissalTimerFired:) userInfo:nil repeats:NO];
}

- (void)stopOverlayAutoDismissTimer
{
    [self.overlayAutoDismissTimer invalidate];
    self.overlayAutoDismissTimer = nil;
}

- (void)overlayDismissalTimerFired:(NSTimer *)timer
{
    [self hideOverlay];
}

- (void)showOverlay
{
    [self.view bringSubviewToFront:self.controlsViewController.view];
    self.controlsViewController.view.hidden = NO;
}

- (void)hideOverlay
{
    [self.view sendSubviewToBack:self.controlsViewController.view];
    self.controlsViewController.view.hidden = YES;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Status Bar Style
//-------------------------------------------------------------------------------------------

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end
