//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <UIKit/UIKit.h>

@class BAVStream;

NS_ASSUME_NONNULL_BEGIN

@interface StreamInfoTableViewController : UITableViewController

@property (nonatomic, strong) BAVStream *stream;

@end

NS_ASSUME_NONNULL_END
