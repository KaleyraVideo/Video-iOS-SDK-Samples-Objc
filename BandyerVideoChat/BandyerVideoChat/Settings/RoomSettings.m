//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <BandyerFoundation/BandyerFoundationMacro.h>

#import "RoomSettings.h"


#define TYPE_KEY @"type"
#define RECORDING_KEY @"recording"
#define USER_ROLE_KEY @"userRole"
#define URL_KEY @"url"

FOUNDATION_EXPORT NSString *NSStringFromRoomType(RoomType roomType)
{
    switch (roomType)
    {
        case RoomTypeRelayed:
            return @"Relayed";
        case RoomTypeRouted:
            return @"Routed";
    }
    return @"Unknown";
}

FOUNDATION_EXPORT NSString *NSStringFromUserRole(UserRole userRole)
{
    switch (userRole)
    {
        case UserRolePresenter:
            return @"Presenter";
        case UserRoleViewer:
            return @"Viewer";
        case UserRolePublishOnly:
            return @"Publish Only";
        case UserRoleViewerWithData:
            return @"Viewer With Data";
    }

    return @"Unknown";
}

@implementation RoomSettings

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _url = @"https://develop.bandyer.com:3004/createToken/";
        _type = RoomTypeRelayed;
        _recording = NO;
        _userRole = UserRolePresenter;
    }

    return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        self.url = [coder decodeObjectForKey:URL_KEY];
        self.type = (RoomType) [coder decodeIntForKey:TYPE_KEY];
        self.recording = [coder decodeBoolForKey:RECORDING_KEY];
        self.userRole = (UserRole) [coder decodeIntForKey:USER_ROLE_KEY];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.url forKey:URL_KEY];
    [coder encodeInt:self.type forKey:TYPE_KEY];
    [coder encodeBool:self.recording forKey:RECORDING_KEY];
    [coder encodeInt:self.userRole forKey:USER_ROLE_KEY];
}


- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"url: %@", self.url];
    [description appendFormat:@", type: %@", NSStringFromRoomType(self.type)];
    [description appendFormat:@", recording: %@", BDFBoolToNSString(self.recording)];
    [description appendFormat:@", userRole: %@", NSStringFromUserRole(self.userRole)];
    [description appendString:@">"];
    return description;
}


@end
