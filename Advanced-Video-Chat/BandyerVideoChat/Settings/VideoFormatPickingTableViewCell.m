//
// Copyright © 2018 Bandyer S.r.l. All Rights Reserved.
// See LICENSE.txt for licensing information
//

#import "VideoFormatPickingTableViewCell.h"

@interface VideoFormatPickingTableViewCell () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *widthsArray;
@property (nonatomic, strong) NSArray *heightsArray;
@property (nonatomic, strong) NSArray *frameRatesArray;

@end

@implementation VideoFormatPickingTableViewCell

- (void)setVideoFormat:(BAVVideoFormat *)videoFormat
{
    if([_videoFormat isEqual:videoFormat])
        return;

    _videoFormat = videoFormat;
    [self updatePickerView];
}

- (void)updatePickerView
{
    NSInteger widthRow = [self.widthsArray indexOfObject:[@(self.videoFormat.width) stringValue]];
    if(widthRow != NSNotFound)
        [self.pickerView selectRow:widthRow + 1 inComponent:0 animated:NO];

    NSInteger heightRow = [self.heightsArray indexOfObject:[@(self.videoFormat.height) stringValue]];
    if(heightRow != NSNotFound)
        [self.pickerView selectRow:heightRow + 1 inComponent:1 animated:NO];

    NSInteger frameRateRow = [self.frameRatesArray indexOfObject:[@(self.videoFormat.frameRate) stringValue]];
    if(frameRateRow != NSNotFound)
        [self.pickerView selectRow:frameRateRow + 1 inComponent:2 animated:NO];
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }

    return self;
}

- (void)commonInit
{
    _widthsArray = @[@"1920", @"1280", @"640", @"320"];
    _heightsArray = @[@"1080", @"720", @"480", @"240"];
    _frameRatesArray = @[@"7", @"15", @"30", @"60"];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Picker Datasource
//-------------------------------------------------------------------------------------------


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
        return self.widthsArray.count + 1;
    else if (component == 1)
        return self.heightsArray.count + 1;
    else if (component == 2)
        return self.frameRatesArray.count + 1;

    return 0;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
        return [self titleForRowInWidthsComponent:row];

    if (component == 1)
        return [self titleForRowInHeightsComponent:row];

    if (component == 2)
        return [self titleForRowInFrameRatesComponent:row];

    return nil;
}

- (NSString *)titleForRowInWidthsComponent:(NSInteger)row
{
    if (row == 0)
        return @"Width";
    else if (row <= self.widthsArray.count)
        return self.widthsArray[row - 1];
    else
        return nil;
}

- (NSString *)titleForRowInHeightsComponent:(NSInteger)row
{
    if (row == 0)
        return @"Height";
    else if (row <= self.heightsArray.count)
        return self.heightsArray[row - 1];
    else
        return nil;
}

- (NSString *)titleForRowInFrameRatesComponent:(NSInteger)row
{
    if (row == 0)
        return @"Fps";
    else if (row <= self.frameRatesArray.count)
        return [NSString stringWithFormat:@"%@ fps", self.frameRatesArray[row - 1]];
    else
        return nil;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Picker Delegate
//-------------------------------------------------------------------------------------------

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(row > 0)
    {
        NSUInteger width = self.videoFormat.width;
        NSUInteger height = self.videoFormat.height;
        NSUInteger frameRate = self.videoFormat.frameRate;

        if(component == 0 && row <= self.widthsArray.count)
            width = (NSUInteger) [self.widthsArray[row - 1] longLongValue];
        
        if(component == 1 && row <= self.heightsArray.count)
            height = (NSUInteger) [self.heightsArray[row - 1] longLongValue];
        
        if(component == 2 && row <= self.frameRatesArray.count)
            frameRate = (NSUInteger) [self.frameRatesArray[row - 1] longLongValue];

        self.videoFormat = [BAVVideoFormat formatWithWidth:width height:height frameRate:frameRate];
        [self.delegate cell:self didSelectVideoFormat:self.videoFormat];
    }
}


@end
