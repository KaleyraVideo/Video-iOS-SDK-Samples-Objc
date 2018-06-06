//
// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information
//

#import "CalleeFormatter.h"


@implementation CalleeFormatter

- (NSString *)formatCallee:(id <BCXCall>)call
{
    if (call.isOutgoing)
        return [self formatCalleeForOutgoingCall:call];
    else
        return [self formatCalleeForIncomingCall:call];
}

- (NSString *)formatCalleeForOutgoingCall:(id <BCXCall>)call
{
    NSArray<id <BCXUser>> *users = [call.participants.callees bdf_map:^id(id <BCXCallParticipant> p) {
        return p.user;
    }];

    NSMutableString *text = [NSMutableString new];
    [text appendString:@"You are calling: "];
    for (NSUInteger i = 0; i < users.count; i++)
    {
        [text appendString:[self nameForUser:users[i]]];

        if (i < users.count - 1)
            [text appendString:@", "];
    }

    return text;
}

- (NSString *)formatCalleeForIncomingCall:(id <BCXCall>)call
{
    NSMutableString *text = [NSMutableString new];
    [text appendString:[self nameForUser:call.participants.caller.user]];
    [text appendString:@" is calling "];

    NSArray<id <BCXCallParticipant>> *callees = [call.participants.callees bdf_select:^BOOL(id <BCXCallParticipant> p) {
        return ![p.user.alias isEqualToString:BandyerCommunicationCenter.instance.callClient.user.alias];
    }];

    for (id <BCXCallParticipant> callee in callees)
        [text appendString:[self nameForUser:callee.user]];

    return text;
}

- (NSString *)nameForUser:(id <BCXUser>)user
{
    if ([user.alias isEqualToString:BandyerCommunicationCenter.instance.callClient.user.alias])
        return @"you";
    else
        return [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
}

@end
