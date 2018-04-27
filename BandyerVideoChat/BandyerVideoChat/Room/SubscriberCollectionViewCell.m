//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <BandyerCoreAV/BAVVideoView.h>
#import <BandyerCoreAV/BAVStream.h>

#import "SubscriberCollectionViewCell.h"

@interface SubscriberCollectionViewCell ()

@property (nonatomic, weak) IBOutlet BAVVideoView *videoView;
@property (nonatomic, weak) IBOutlet UIView *controlsOverlayView;
@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *overlayTapGestureRecognizer;

@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *unsubscribeBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *audioBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *videoBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *videoFittingBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *videoQualityBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *infoBarButtonItem;

@end

@implementation SubscriberCollectionViewCell

@dynamic videoFittingMode;

- (void)setStream:(BAVStream *)stream
{
    [self stopRendering];
    _stream = stream;
    self.videoView.stream = stream;

    [self updateViews];
}

- (BAVVideoSizeFittingMode)videoFittingMode
{
    return self.videoView.videoSizeFittingMode;
}

- (void)setVideoFittingMode:(BAVVideoSizeFittingMode)videoFittingMode
{
    self.videoView.videoSizeFittingMode = videoFittingMode;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.controlsOverlayView.hidden = YES;

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayTapGestureRecognizerTouched:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    self.overlayTapGestureRecognizer = tapGestureRecognizer;
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    [self.videoView stopRendering];
    self.delegate = nil;
    self.stream = nil;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Rendering
//-------------------------------------------------------------------------------------------

- (void)startRendering
{
    [self.videoView startRendering];
}

- (void)stopRendering
{
    [self.videoView stopRendering];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Subviews
//-------------------------------------------------------------------------------------------

- (void)updateViews
{
    [self updateAudioButton];
    [self updateVideoButton];
}

- (void)updateAudioButton
{
    self.audioBarButtonItem.enabled = self.stream.hasAudio;

    UIImage *image;
    if (!self.audioBarButtonItem.isEnabled)
    {
        image = [UIImage imageNamed:@"mic_not_available"];
    } else if (self.stream.hasAudioEnabled)
    {
        image = [UIImage imageNamed:@"mic_enabled"];
    } else
    {
        image = [UIImage imageNamed:@"mic_disabled"];
    }

    [self.audioBarButtonItem setImage:image];
}

- (void)updateVideoButton
{
    self.videoBarButtonItem.enabled = self.stream.hasVideo;

    UIImage *image;
    if (!self.videoBarButtonItem.isEnabled)
    {
        image = [UIImage imageNamed:@"video_not_available"];
    } else if (self.stream.hasVideoEnabled)
    {
        image = [UIImage imageNamed:@"video_enabled"];
    } else
    {
        image = [UIImage imageNamed:@"video_disabled"];
    }

    [self.videoBarButtonItem setImage:image];
}


//-------------------------------------------------------------------------------------------
#pragma mark - Actions
//-------------------------------------------------------------------------------------------

- (IBAction)overlayTapGestureRecognizerTouched:(UITapGestureRecognizer *)sender
{
    self.controlsOverlayView.hidden = !self.controlsOverlayView.hidden;
}

- (IBAction)unsubscribeButtonTouched:(id)sender
{
    [self.delegate subscriberCellDidTouchUnSubscribe:self];
}

- (IBAction)videoQualityButtonTouched:(id)sender
{
    [self.delegate subscriberCellDidTouchVideoQuality:self];
}

- (IBAction)infoButtonTouched:(id)sender
{
    [self.delegate subscriberCellDidTouchInfo:self];
}

- (IBAction)fittingModeButtonTouched:(id)sender
{
    [self.delegate subscriberCellDidTouchVideoFittingMode:self];
}

- (IBAction)audioButtonTouched:(id)sender
{
    self.stream.hasAudioEnabled ? [self.stream disableAudio] : [self.stream enableAudio];
    [self updateAudioButton];
}

- (IBAction)videoButtonTouched:(id)sender
{
    self.stream.hasVideoEnabled ? [self.stream disableVideo] : [self.stream enableVideo];
    [self updateVideoButton];
}


@end
