//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import "CameraPositionPickingTableViewCell.h"

@interface CameraPositionPickingTableViewCell() <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) IBOutlet UIPickerView *positionPickerView;

@end

@implementation CameraPositionPickingTableViewCell

- (void)setCameraPosition:(AVCaptureDevicePosition)cameraPosition
{
    _cameraPosition = cameraPosition;

    NSInteger selectedRow = 0;
    if(cameraPosition == AVCaptureDevicePositionFront)
        selectedRow = 1;
    else if(cameraPosition == AVCaptureDevicePositionBack)
        selectedRow = 2;

    [self.positionPickerView selectRow:selectedRow
                           inComponent:0
                              animated:NO];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (row)
    {
        case 0:
            return @"Camera Position";
        case 1:
            return @"Front";
        case 2:
            return @"Back";
        default:
            return nil;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (row)
    {
        case 1:
            [self.delegate cell:self didSelectCameraPosition:AVCaptureDevicePositionFront];
            break;
        case 2:
            [self.delegate cell:self didSelectCameraPosition:AVCaptureDevicePositionBack];
            break;
        default:
            break;
    }
}


@end
