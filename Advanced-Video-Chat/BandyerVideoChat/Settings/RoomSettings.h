//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RoomType)
{
    RoomTypeRelayed = 0,
    RoomTypeRouted
};

typedef NS_ENUM(NSInteger, UserRole)
{
    UserRolePresenter = 0,
    UserRoleViewer,
    UserRolePublishOnly,
    UserRoleViewerWithData,
};

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *NSStringFromRoomType(RoomType roomType);
FOUNDATION_EXPORT NSString *NSStringFromUserRole(UserRole userRole);

@interface RoomSettings : NSObject <NSCoding>

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) RoomType type;
@property (nonatomic, assign, getter=isRecording) BOOL recording;
@property (nonatomic, assign) UserRole userRole;

@end

NS_ASSUME_NONNULL_END
