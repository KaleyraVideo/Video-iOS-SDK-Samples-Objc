//
//  SessionFactory.m
//  KaleyraVideoSample
//
//  Created by Alessandro Limardo on 29/04/22.
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
