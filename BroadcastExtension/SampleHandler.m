//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import "SampleHandler.h"
#import "Constants.h"

#import <BandyerBroadcastExtension/BandyerBroadcastExtension.h>

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo
{
    __weak __typeof__(self) _wself = self;
    [BBEBroadcastExtension.instance startWithAppGroupIdentifier:[Constants appGroupIdentifier] setupInfo:setupInfo errorHandler:^(NSError * _Nonnull error) {
        __strong __typeof__(_wself) sself = _wself;
        [sself finishBroadcastWithError:error];
    }];
}

- (void)broadcastPaused
{
    [BBEBroadcastExtension.instance pause];
}

- (void)broadcastResumed
{
    [BBEBroadcastExtension.instance resume];
}

- (void)broadcastFinished
{
    [BBEBroadcastExtension.instance finish];
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType
{
    [BBEBroadcastExtension.instance processSampleBuffer:sampleBuffer ofType:sampleBufferType];
}

@end
