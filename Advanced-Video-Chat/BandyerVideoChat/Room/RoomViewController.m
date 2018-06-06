//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPVolumeView.h>

#import <BandyerCoreAV/BAVRoom.h>
#import <BandyerCoreAV/BAVSubscriber.h>
#import <BandyerCoreAV/BAVSubscribeOptions.h>
#import <BandyerCoreAV/BAVStream.h>
#import <BandyerCoreAV/BAVPublisher.h>
#import <BandyerCoreAV/BAVPublisherIdentity.h>
#import <BandyerCoreAV/BAVPublishOptions.h>
#import <BandyerCoreAV/BAVPublisherObserver.h>
#import <BandyerCoreAV/BAVFileVideoCapturer.h>
#import <BandyerCoreAV/BAVCameraCapturer.h>
#import <BandyerCoreAV/BAVVideoView.h>
#import <BandyerCoreAV/BAVCameraPreviewView.h>
#import <BandyerCoreAV/BAVAudioSession.h>
#import <BandyerCoreAV/BAVAudioSessionConfiguration.h>

#import "RoomViewController.h"
#import "SettingsRepository.h"
#import "RoomDetailsViewController.h"
#import "SubscriberCollectionViewCell.h"
#import "VideoQualitySelectionTableViewController.h"
#import "VideoModeSelectionTableViewController.h"
#import "SubscriberInfoTableViewController.h"
#import "PublishSettings.h"
#import "SubscribeSettings.h"
#import "ArrayDataProvider.h"
#import "SubscriberCollectionViewDataSource.h"
#import "CreateSubscriberViewController.h"
#import "CreatePublisherViewController.h"
#import "PublishSettings+BAVPublishOptions.h"
#import "SubscribeSettings+BAVSubscribeOptions.h"
#import "AudioSessionSettings.h"

#define SHOW_ROOM_DETAILS_SEGUE @"showRoomDetailsSegue"
#define SHOW_VIDEO_QUALITY_SELECTION_SEGUE @"showVideoQualitySelectionSegue"
#define SHOW_VIDEO_FITTING_MODE_SELECTION_SEGUE @"showVideoFittingModeSelectionSegue"
#define SHOW_SUBSCRIBER_INFO_SEGUE @"showSubscriberInfoSegue"
#define SHOW_ADD_SUBSCRIBER_SEGUE @"showAddSubscriberSegue"
#define SHOW_ADD_PUBLISHER_SEGUE @"showAddPublisherSegue"

#define SUBSCRIBER_CELL_ID @"subscriberCellId"

@interface RoomViewController () <BAVRoomObserver, BAVSubscriberObserver, BAVPublisherObserver, UICollectionViewDelegateFlowLayout, SubscriberCollectionViewCellDelegate, VideoQualitySelectionTableViewControllerDelegate, VideoModeSelectionTableViewControllerDelegate, UIPopoverPresentationControllerDelegate, CreateSubscriberViewControllerDelegate, CreatePublisherViewControllerDelegate, BAVVideoViewDelegate, BAVAudioSessionObserver>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *infoBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *addSubscriberBarButtonItem;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *publishBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *firstSpaceBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *secondSpaceBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *unpublishBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *toggleCameraBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *volumeBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *micBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *videoBarButtonItem;
@property (nonatomic, weak) IBOutlet UICollectionView *remoteCollectionView;
@property (nonatomic, weak) IBOutlet UIView *volumeViewContainerView;
@property (nonatomic, weak) IBOutlet MPVolumeView *volumeView;

@property (nonatomic, weak) NSLayoutConstraint *previewViewAspectConstraint;

@property (nonatomic, weak) SubscriberCollectionViewCell *selectedCell;

@property (nonatomic, weak) UIPopoverPresentationController *videoFittingModePopoverPresentationController;
@property (nonatomic, weak) UIPopoverPresentationController *videoQualityPopoverPresentationController;

#if TARGET_IPHONE_SIMULATOR
@property (nonatomic, strong) BAVVideoView *localVideoView;
#else
@property (nonatomic, strong) BAVCameraPreviewView *localVideoView;
#endif

@property (nonatomic, strong) BAVRoom * room;
@property (nonatomic, strong) BAVPublisher *publisher;
@property (nonatomic, strong) SettingsRepository *settingsRepository;
@property (nonatomic, strong) PublishSettings *publishSettings;
@property (nonatomic, strong) SubscribeSettings *subscribeSettings;
@property (nonatomic, strong) AudioSessionSettings *audioSessionSettings;
@property (nonatomic, strong) ArrayDataProvider<BAVSubscriber *> *subscriberDataProvider;
@property (nonatomic, strong) SubscriberCollectionViewDataSource *subscriberDataSource;

#if TARGET_IPHONE_SIMULATOR
@property (nonatomic, strong) BAVFileVideoCapturer *capturer;
#else
@property (nonatomic, strong) BAVCameraCapturer *capturer;
#endif

@end

@implementation RoomViewController

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
    _settingsRepository = [SettingsRepository sharedInstance];
    _subscriberDataProvider = [ArrayDataProvider new];
    _subscriberDataSource = [[SubscriberCollectionViewDataSource alloc] initWithDataProvider:_subscriberDataProvider subscriberCellDelegate:self];
    _publishSettings = [_settingsRepository retrievePublishSettings];
    _subscribeSettings = [_settingsRepository retrieveSubscribeSettings];
    _audioSessionSettings = [_settingsRepository retrieveAudioSessionSettings];
#if TARGET_IPHONE_SIMULATOR
    _capturer = [[BAVFileVideoCapturer alloc] initWithFileNamed:@"SampleVideo_640x360_10mb" withExtension:@"mp4" inBundle:[NSBundle bundleForClass:self.class]];
#else
    AVCaptureDevicePosition position = [_settingsRepository retrieveCameraPosition];
    BAVVideoFormat *videoFormat = [_settingsRepository retrieveVideoFormat];
    _capturer = [[BAVCameraCapturer alloc] initWithCameraPosition:position videoFormat:videoFormat];
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.remoteCollectionView registerNib:[UINib nibWithNibName:@"SubscriberCollectionViewCell" bundle:[NSBundle bundleForClass:self.class]] forCellWithReuseIdentifier:SUBSCRIBER_CELL_ID];
    self.remoteCollectionView.dataSource = self.subscriberDataSource;

    [BAVAudioSession.instance addObserver:self];
    BAVAudioSession.instance.notificationQueue = dispatch_get_main_queue();
    BAVAudioSession.instance.manualAudio = self.audioSessionSettings.isManual;
    [BAVAudioSession.instance configureWithBlock:^(BAVAudioSessionConfiguration *configuration) {
        configuration.categoryOptions = self.audioSessionSettings.options;
    }];

    self.room = [[BAVRoom alloc] initWithToken:self.token];
    [self.room addObserver:self];
    [self.room join];

    self.toggleCameraBarButtonItem.enabled = [self.capturer isKindOfClass:BAVCameraCapturer.class];
}

- (void)dealloc
{
    [self.capturer stop];
    [self.room leave];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)toggleCameraPositionTouched:(UIBarButtonItem *)sender
{
#if !TARGET_IPHONE_SIMULATOR
    [self.capturer toggleCameraPosition];
#endif
}

- (IBAction)publishBarButtonTouched:(UIBarButtonItem *)sender
{
    if(self.publisher)
        return;

    [self performSegueWithIdentifier:SHOW_ADD_PUBLISHER_SEGUE sender:self];
}

- (IBAction)unpublishBarButtonTouched:(UIBarButtonItem *)sender
{
    if(!self.publisher)
        return;

    [self.room unpublish:self.publisher error:NULL];
}

- (IBAction)addSubscriberBarButtonTouched:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:SHOW_ADD_SUBSCRIBER_SEGUE sender:self];
}

- (IBAction)volumeBarButtonTouched:(UIBarButtonItem *)sender
{
    self.volumeViewContainerView.hidden = !self.volumeViewContainerView.isHidden;

    if(self.volumeViewContainerView.isHidden)
    {
        [self.view sendSubviewToBack:self.volumeViewContainerView];
    } else
    {
        [self.view bringSubviewToFront:self.volumeViewContainerView];
    }
}

- (IBAction)micBarButtonTouched:(UIBarButtonItem *)sender
{
    if(self.publisher.stream)
    {
        if(self.publisher.stream.hasAudioEnabled)
            [self.publisher.stream disableAudio];
        else
            [self.publisher.stream enableAudio];
    }

    [self updateLocalStreamBarItems];
}

- (IBAction)videoBarButtonTouched:(UIBarButtonItem *)sender
{
    if(self.publisher.stream)
    {
        if(self.publisher.stream.hasVideoEnabled)
            [self.publisher.stream disableVideo];
        else
            [self.publisher.stream enableVideo];
    }

    [self updateLocalStreamBarItems];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Toolbar
//-------------------------------------------------------------------------------------------

- (void)updateToolbarWithPublishButton
{
#if TARGET_IPHONE_SIMULATOR
    NSArray<UIBarButtonItem *> *items = @[self.toggleCameraBarButtonItem, self.firstSpaceBarButtonItem, self.micBarButtonItem, self.videoBarButtonItem, self.publishBarButtonItem];
#else
    NSArray<UIBarButtonItem *> *items = @[self.toggleCameraBarButtonItem, self.firstSpaceBarButtonItem, self.volumeBarButtonItem, self.secondSpaceBarButtonItem, self.micBarButtonItem, self.videoBarButtonItem, self.publishBarButtonItem];
#endif

    [self updateToolBarWithItems:items animated:YES];
    [self updateLocalStreamBarItems];
}

- (void)updateToolbarWithUnpublishButton
{

#if TARGET_IPHONE_SIMULATOR
    NSArray<UIBarButtonItem *> *items = @[self.toggleCameraBarButtonItem, self.firstSpaceBarButtonItem, self.micBarButtonItem, self.videoBarButtonItem, self.unpublishBarButtonItem];
#else
    NSArray<UIBarButtonItem *> *items = @[self.toggleCameraBarButtonItem, self.firstSpaceBarButtonItem, self.volumeBarButtonItem, self.secondSpaceBarButtonItem, self.micBarButtonItem, self.videoBarButtonItem, self.unpublishBarButtonItem];
#endif
    [self updateToolBarWithItems:items animated:YES];
    [self updateLocalStreamBarItems];
}

- (void)updateToolBarWithItems:(NSArray<UIBarButtonItem*>*)items animated:(BOOL)animated
{
    [self.toolbar setItems:items animated:animated];
}

- (void)updateLocalStreamBarItems
{
    self.micBarButtonItem.enabled = self.publisher.stream.hasAudio;

    if (!self.micBarButtonItem.isEnabled)
    {
        [self.micBarButtonItem setImage:[UIImage imageNamed:@"mic_not_available"]];
    }
    else
    {
        if (self.publisher.stream.hasAudioEnabled)
        {
            [self.micBarButtonItem setImage:[UIImage imageNamed:@"mic_disabled"]];
        } else
        {
            [self.micBarButtonItem setImage:[UIImage imageNamed:@"mic_enabled"]];
        }
    }


    self.videoBarButtonItem.enabled = self.publisher.stream.hasVideo;

    if(!self.videoBarButtonItem.isEnabled)
    {
        [self.videoBarButtonItem setImage:[UIImage imageNamed:@"video_not_available"]];
    } else
    {
        if (self.publisher.stream.hasVideoEnabled)
        {
            [self.videoBarButtonItem setImage:[UIImage imageNamed:@"video_disabled"]];
        } else
        {
            [self.videoBarButtonItem setImage:[UIImage imageNamed:@"video_enabled"]];
        }
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Segue
//-------------------------------------------------------------------------------------------


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender
{
    if([segue.identifier isEqualToString:SHOW_ROOM_DETAILS_SEGUE])
    {
        RoomDetailsViewController *controller = segue.destinationViewController;
        controller.room = self.room;
    } else if([segue.identifier isEqualToString:SHOW_VIDEO_QUALITY_SELECTION_SEGUE])
    {
        VideoQualitySelectionTableViewController *controller = segue.destinationViewController;
        BAVSubscriber *subscriber = [self.room subscriberForStream:self.selectedCell.stream];
        controller.quality = subscriber.videoQuality;
        controller.delegate = self;

        self.videoQualityPopoverPresentationController = controller.popoverPresentationController;
        self.videoQualityPopoverPresentationController.delegate = self;
        self.videoQualityPopoverPresentationController.sourceView = self.selectedCell;

    } else if([segue.identifier isEqualToString:SHOW_VIDEO_FITTING_MODE_SELECTION_SEGUE])
    {
        VideoModeSelectionTableViewController *controller = segue.destinationViewController;
        controller.videoFittingMode = self.selectedCell.videoFittingMode;
        controller.delegate = self;

        self.videoFittingModePopoverPresentationController = controller.popoverPresentationController;
        self.videoFittingModePopoverPresentationController.delegate = self;
        self.videoFittingModePopoverPresentationController.sourceView = self.selectedCell;

    } else if ([segue.identifier isEqualToString:SHOW_SUBSCRIBER_INFO_SEGUE])
    {
        SubscriberInfoTableViewController *controller = segue.destinationViewController;
        BAVSubscriber *subscriber = [self.room subscriberForStream:self.selectedCell.stream];
        controller.subscriber = subscriber;
    }else if ([segue.identifier isEqualToString:SHOW_ADD_SUBSCRIBER_SEGUE])
    {
        CreateSubscriberViewController *controller = segue.destinationViewController;
        controller.streams = [self.room availableStreams];
        controller.createSubscriberControllerDelegate = self;
    }else if ([segue.identifier isEqualToString:SHOW_ADD_PUBLISHER_SEGUE])
    {
        CreatePublisherViewController *controller = segue.destinationViewController;
        controller.createPublisherControllerDelegate = self;
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - UIPopoverPresentationController Delegate
//-------------------------------------------------------------------------------------------

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Room Observer
//-------------------------------------------------------------------------------------------

- (void)roomDidConnect:(BAVRoom *)room
{
    self.addSubscriberBarButtonItem.enabled = YES;
    if(self.publishSettings.mode == PublishModeAuto)
    {
        [self publish:[[BAVPublisher alloc] init] withOptions:[self.publishSettings publishOptions]];
    } else
    {
        [self updateToolbarWithPublishButton];
    }
}

- (void)publish:(BAVPublisher *)publisher withOptions:(BAVPublishOptions *)options
{
    BAVPublisherIdentity *identity = [BAVPublisherIdentity identityWithAlias:@"alias"
                                                                   firstName:@"John"
                                                                    lastName:@"Appleseed"
                                                                       email:@"john.appleseed@bandyer.com"
                                                                      avatar:@"avatar_1.jpg"];
    publisher.publishOptions = options;
    publisher.publisherIdentity = identity;
    publisher.capturer = self.capturer;
    [publisher addObserver:self];

#if !TARGET_IPHONE_SIMULATOR
    BAVCameraPreviewView *view = [[BAVCameraPreviewView alloc] initWithFrame:CGRectZero];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:view];
    [self.view bringSubviewToFront:view];
    self.localVideoView = view;
    self.localVideoView.captureSession = self.capturer.captureSession;

    [view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.2].active = YES;
    [view.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.3].active = YES;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if([self.view respondsToSelector:@selector(safeAreaLayoutGuide)])
        [view.rightAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.rightAnchor].active = YES;
    else
#endif
        [view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;

    [view.bottomAnchor constraintEqualToAnchor:self.toolbar.topAnchor].active = YES;

    //TODO: AUDIO AND VIDEO PERMISSION MUST BE ALLOWED BEFORE WEBRTC STARTS ACCESSING VIDEO OR AUDIO RESOURCES

    [self.capturer start];
    self.toggleCameraBarButtonItem.enabled = YES;
#endif

    [self.room publish:publisher error:NULL];
}

- (void)roomDidDisconnect:(BAVRoom *)room
{
    self.addSubscriberBarButtonItem.enabled = NO;
    self.publishBarButtonItem.enabled = NO;
    self.toggleCameraBarButtonItem.enabled = NO;
    //TODO: ALERT !
}

- (void)room:(BAVRoom *)room didFailWithError:(NSError *)error
{
    self.addSubscriberBarButtonItem.enabled = NO;
    self.publishBarButtonItem.enabled = NO;
    self.toggleCameraBarButtonItem.enabled = NO;
    //TODO: ALERT !
}

- (void)room:(BAVRoom *)room didAddStream:(BAVStream *)stream
{
    if([stream.streamId isEqualToString:self.publisher.stream.streamId])
        return;

    if(self.subscribeSettings.mode == SubscribeModeAuto)
    {
        [self subscribe:stream];
    }
}

- (void)subscribe:(BAVStream *)stream
{
    BAVSubscriber *subscriber = [[BAVSubscriber alloc] initWithStream:stream];
    subscriber.subscribeOptions = [self.subscribeSettings subscribeOptions];
    [subscriber addObserver:self];

    [self.room subscribe:subscriber error:NULL];
}

- (void)room:(BAVRoom *)room didRemoveStream:(BAVStream *)stream
{

}

- (void)room:(BAVRoom *)room didAddPublisher:(BAVPublisher *)publisher
{
    self.publisher = publisher;
    [self updateToolbarWithUnpublishButton];
}


- (void)room:(BAVRoom *)room didRemovePublisher:(BAVPublisher *)publisher
{
    self.publisher = nil;
    [self.localVideoView removeFromSuperview];
    [self updateToolbarWithPublishButton];
}

- (void)room:(BAVRoom *)room didAddSubscriber:(BAVSubscriber *)subscriber
{
    [self.subscriberDataProvider append:subscriber];
    NSIndexPath *indexPath = [self.subscriberDataProvider indexPathForItem:subscriber];

    if(indexPath)
        [self.remoteCollectionView insertItemsAtIndexPaths:@[indexPath]];
}

- (void)room:(BAVRoom *)room didRemoveSubscriber:(BAVSubscriber *)subscriber
{
    NSIndexPath *indexPath = [self.subscriberDataProvider indexPathForItem:subscriber];
    [self.subscriberDataProvider remove:subscriber];

    if(indexPath)
        [self.remoteCollectionView deleteItemsAtIndexPaths:@[indexPath]];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Audio Session Observer
//-------------------------------------------------------------------------------------------

- (void)audioSessionDidChangeRoute:(BAVAudioSession *)session reason:(AVAudioSessionRouteChangeReason)reason previousRoute:(AVAudioSessionRouteDescription *)previousRoute
{
    NSLog(@"Audio Session Did Change Route - Reason %@, Current Route: %@ Old Route: %@", [self stringFromAVAudioSessionRouteChangeReason:reason], session.session.currentRoute, previousRoute);
}

- (NSString *)stringFromAVAudioSessionRouteChangeReason:(AVAudioSessionRouteChangeReason)reason
{
    switch (reason)
    {
        case AVAudioSessionRouteChangeReasonUnknown:break;
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            return @"New Device Available";
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            return @"Old Device Unavailable";
        case AVAudioSessionRouteChangeReasonCategoryChange:
            return @"Category Change";
        case AVAudioSessionRouteChangeReasonOverride:
            return @"Output Override";
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            return @"Wake from Sleep";
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            return @"No Suitable Route for category";
        case AVAudioSessionRouteChangeReasonRouteConfigurationChange:
            return @"Route Configuration Change";
    }
    return @"Unknown";
}

- (void)audioSession:(BAVAudioSession *)audioSession didOverrideOutputPort:(AVAudioSessionPortOverride)override
{
}

- (void)audioSession:(BAVAudioSession *)audioSession didFailToOverrideOutputPortWithError:(NSError *)error
{
}

- (void)audioSessionDidStartPlayOrRecord:(BAVAudioSession *)session
{
    [BAVAudioSession.instance enableAudio];
}

- (void)audioSessionDidStopPlayOrRecord:(BAVAudioSession *)session
{
    [BAVAudioSession.instance disableAudio];
}


//-------------------------------------------------------------------------------------------
#pragma mark - Publisher Observer
//-------------------------------------------------------------------------------------------

- (void)publisherDidCreateStream:(BAVPublisher *)publisher
{
#if TARGET_IPHONE_SIMULATOR
    [self.capturer start];

    BAVVideoView * view = [[BAVVideoView alloc] initWithFrame:CGRectZero];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:view];
    [self.view bringSubviewToFront:view];
    self.localVideoView = view;

    [view setBackgroundColor:UIColor.clearColor];
    [view.widthAnchor constraintLessThanOrEqualToAnchor:self.view.widthAnchor multiplier:0.5].active = YES;
    [view.heightAnchor constraintLessThanOrEqualToAnchor:self.view.heightAnchor multiplier:0.5].active = YES;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if([self.view respondsToSelector:@selector(safeAreaLayoutGuide)])
        [view.rightAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.rightAnchor].active = YES;
    else
#endif
        [view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;

    [view.bottomAnchor constraintEqualToAnchor:self.toolbar.topAnchor].active = YES;
    view.delegate = self;

    view.stream = publisher.stream;
    [view startRendering];
#endif

    [self updateLocalStreamBarItems];
}

- (void)publisher:(BAVPublisher *)publisher didFailWithError:(NSError *)error
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Publisher Failed" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:NULL];

    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:NULL];

    [self updateLocalStreamBarItems];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Video View Delegate
//-------------------------------------------------------------------------------------------

- (void)videoView:(BAVVideoView *)view didChangeVideoSize:(CGSize)size
{
    if(self.previewViewAspectConstraint)
        self.previewViewAspectConstraint.active = NO;

    NSLayoutConstraint *constraint = [view.widthAnchor constraintEqualToAnchor:view.heightAnchor multiplier:size.width / size.height];
    constraint.active = YES;
    self.previewViewAspectConstraint = constraint;
}


//-------------------------------------------------------------------------------------------
#pragma mark - Subscriber Observer
//-------------------------------------------------------------------------------------------

- (void)subscriberDidConnectToStream:(BAVSubscriber *)subscriber
{
    NSIndexPath *indexPath = [self.subscriberDataProvider indexPathForItem:subscriber];
    if(!indexPath)
        return;

    SubscriberCollectionViewCell *cell = (SubscriberCollectionViewCell *) [self.remoteCollectionView cellForItemAtIndexPath:indexPath];
    cell.stream = subscriber.stream;
    [cell startRendering];
}

- (void)subscriberDidDisconnectFromStream:(BAVSubscriber *)subscriber
{

}

- (void)subscriber:(BAVSubscriber *)subscriber didFailWithError:(NSError *)error
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Subscriber Failed" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:NULL];

    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:NULL];
}

//-------------------------------------------------------------------------------------------
#pragma mark - UICollectionView Layout Delegate
//-------------------------------------------------------------------------------------------

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;

    if([self.subscriberDataProvider itemCountInSection:section] == 1)
    {
        return collectionView.frame.size;
    }
    else if([self.subscriberDataProvider itemCountInSection:section] == 2)
    {
        if(collectionView.bounds.size.width < collectionView.bounds.size.height)
            return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.height / 2);
        else
            return CGSizeMake(collectionView.bounds.size.width / 2 , collectionView.bounds.size.height);
    } else
    {
        return CGSizeMake(collectionView.bounds.size.width / 2 , collectionView.bounds.size.height / 2);
    }

}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Subscriber Cell Delegate
//-------------------------------------------------------------------------------------------

- (void)subscriberCellDidTouchUnSubscribe:(SubscriberCollectionViewCell *)cell
{
    NSIndexPath *path = [self.remoteCollectionView indexPathForCell:cell];
    BAVSubscriber *subscriber = [self.subscriberDataProvider itemAtIndexPath:path];

    if(subscriber)
        [self.room unsubscribe:subscriber error:NULL];
}

- (void)subscriberCellDidTouchVideoQuality:(SubscriberCollectionViewCell *)cell
{
    self.selectedCell = cell;
    [self performSegueWithIdentifier:SHOW_VIDEO_QUALITY_SELECTION_SEGUE sender:self];
}

- (void)subscriberCellDidTouchVideoFittingMode:(SubscriberCollectionViewCell *)cell
{
    self.selectedCell = cell;
    [self performSegueWithIdentifier:SHOW_VIDEO_FITTING_MODE_SELECTION_SEGUE sender:self];
}

- (void)subscriberCellDidTouchInfo:(SubscriberCollectionViewCell *)cell
{
    self.selectedCell = cell;
    [self performSegueWithIdentifier:SHOW_SUBSCRIBER_INFO_SEGUE sender:self];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Video Quality Selection Delegate
//-------------------------------------------------------------------------------------------

- (void)videoQualitySelectionController:(VideoQualitySelectionTableViewController *)controller didSelectQuality:(BAVVideoQuality *)quality
{
    if(self.selectedCell == nil || self.selectedCell.stream == nil)
        return;

    BAVSubscriber *subscriber = [self.room subscriberForStream:self.selectedCell.stream];
    [subscriber updateVideoQuality:quality];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Video Fitting Mode Selection Delegate
//-------------------------------------------------------------------------------------------

- (void)videoModeSelectionController:(VideoModeSelectionTableViewController *)controller didChangeVideoFittingMode:(BAVVideoSizeFittingMode)mode
{
    if(self.selectedCell == nil)
        return;

    self.selectedCell.videoFittingMode = mode;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Add Subscriber Delegate
//-------------------------------------------------------------------------------------------


- (void)createSubscriberControllerDidCancel:(CreateSubscriberViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)createSubscriberController:(CreateSubscriberViewController *)controller didCreateSubscriber:(BAVSubscriber *)subscriber
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    //TODO: CHECK ROOM HAS STREAM WITH ID

    [subscriber addObserver:self];
    [self.room subscribe:subscriber error:NULL];
}


//-------------------------------------------------------------------------------------------
#pragma mark - Add Publisher Delegate
//-------------------------------------------------------------------------------------------

- (void)createPublisherControllerDidCancel:(CreatePublisherViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)createPublisherController:(CreatePublisherViewController *)controller didCreatePublisher:(BAVPublisher *)publisher
{
    [self dismissViewControllerAnimated:YES completion:NULL];

    [self publish:publisher withOptions:publisher.publishOptions];
}


@end
