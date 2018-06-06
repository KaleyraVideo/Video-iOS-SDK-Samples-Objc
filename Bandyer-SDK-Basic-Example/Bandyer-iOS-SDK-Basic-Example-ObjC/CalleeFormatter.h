//
// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>
#import <BandyerCommunicationCenter/BandyerCommunicationCenter.h>


@interface CalleeFormatter : NSObject

- (NSString *)formatCallee:(id<BCXCall>)call;

@end
