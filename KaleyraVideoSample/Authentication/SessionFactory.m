//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SessionFactory.h"
#import "SessionObserverImplementation.h"
#import "AccessTokenProviderMock.h"

@implementation SessionFactory

+ (BDKSession *)makeSessionFor:(NSString *)userID
{
    return [[BDKSession alloc] initWithUserId:userID
                                tokenProvider:[[AccessTokenProviderMock alloc] init]
                                     observer:[[SessionObserverImplementation alloc] init]];
}

@end
