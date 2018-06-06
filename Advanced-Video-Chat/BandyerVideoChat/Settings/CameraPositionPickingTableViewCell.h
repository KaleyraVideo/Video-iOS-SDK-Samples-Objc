//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CameraPositionPickingTableViewCell;

@protocol CameraPositionPickingTableViewCellDelegate <NSObject>

- (void)cell:(CameraPositionPickingTableViewCell *)cell didSelectCameraPosition:(AVCaptureDevicePosition)position;

@end

@interface CameraPositionPickingTableViewCell : UITableViewCell

@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;
@property (nonatomic, weak, nullable) id<CameraPositionPickingTableViewCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
