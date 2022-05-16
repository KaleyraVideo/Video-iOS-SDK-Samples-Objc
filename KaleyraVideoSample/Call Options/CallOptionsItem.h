//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import <Bandyer/Bandyer.h>

NS_ASSUME_NONNULL_BEGIN

@interface CallOptionsItem : NSObject <NSCopying>

@property (nonatomic, assign) BDKCallType type;
@property (nonatomic, assign) BDKCallRecordingType recordingType;
@property (nonatomic, assign) NSUInteger maximumDuration;

@end

NS_ASSUME_NONNULL_END
