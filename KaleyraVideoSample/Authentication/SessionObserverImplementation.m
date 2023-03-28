//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SessionObserverImplementation.h"

// You can observe for authentication event implementing a SessionObserver protocol conform object and
// passing it to the Session object during the initialization process
@implementation SessionObserverImplementation

- (void)sessionWillAuthenticate:(BDKSession * _Nonnull)session
{
    NSLog(@"session %@ will authenticate", session);
}

- (void)sessionDidAuthenticate:(BDKSession * _Nonnull)session
{
    NSLog(@"session %@ did authenticate", session);
}

- (void)sessionWillRefresh:(BDKSession * _Nonnull)session
{
    NSLog(@"session %@ did refresh", session);
}

- (void)sessionDidRefresh:(BDKSession * _Nonnull)session
{
    NSLog(@"session %@ did refresh", session);
}

- (void)session:(BDKSession * _Nonnull)session didFailWith:(NSError * _Nonnull)error
{
    NSLog(@"session %@ didFailWith %@", session, error);
}

@end
