//
//  Copyright © 2019 Bandyer. All rights reserved.
//

#import <Bandyer/Bandyer.h>

NS_ASSUME_NONNULL_BEGIN

@interface CallOptionsItem : NSObject <NSCopying>

@property (nonatomic, assign) BDKCallType type;
@property (nonatomic, assign) BOOL record;
@property (nonatomic, assign) NSUInteger maximumDuration;

@end

NS_ASSUME_NONNULL_END
