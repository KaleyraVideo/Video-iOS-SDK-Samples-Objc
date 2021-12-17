//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import "SampleHandler.h"

#import <BandyerBroadcastExtension/BandyerBroadcastExtension.h>

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo
{
#error "Replace APP_GROUP_IDENTIFIER_GOES_HERE placeholder with your app group identifier"
    __weak __typeof__(self) _wself = self;
    [BBEBroadcastExtension.instance startWithAppGroupIdentifier:@"APP_GROUP_IDENTIFIER_GOES_HERE" setupInfo:setupInfo errorHandler:^(NSError * _Nonnull error) {
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
