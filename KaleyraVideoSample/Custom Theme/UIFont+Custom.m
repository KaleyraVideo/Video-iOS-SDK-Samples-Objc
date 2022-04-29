//
//  UIFont+Custom.m
//  KaleyraVideoSample
//
//  Created by Alessandro Limardo on 29/04/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UIFont+Custom.h"

@implementation UIFont(Custom)

+ (UIFont *)robotoMedium
{
    UIFont *font = [UIFont fontWithName:@"Roboto-Medium" size:20];

    if (!font)
    {
        [NSException raise:@"MissingFont" format:@"No font found with Roboto-Medium name"];
    }

    return font;
}

+ (UIFont *)robotoLight
{
    UIFont *font = [UIFont fontWithName:@"Roboto-Light" size:11];

    if (!font)
    {
        [NSException raise:@"MissingFont" format:@"No font found with Roboto-Light name"];
    }

    return font;
}

+ (UIFont *)robotoThin
{
    UIFont *font = [UIFont fontWithName:@"Roboto-Thin" size:17];

    if (!font)
    {
        [NSException raise:@"MissingFont" format:@"No font found with Roboto-Thin name"];
    }

    return font;
}

+ (UIFont *)robotoRegular
{
    UIFont *font = [UIFont fontWithName:@"Roboto-Regular" size:17];

    if (!font)
    {
        [NSException raise:@"MissingFont" format:@"No font found with Roboto-Regular name"];
    }

    return font;
}

+ (UIFont *)robotoBold
{
    UIFont *font = [UIFont fontWithName:@"Roboto-Bold" size:17];

    if (!font)
    {
        [NSException raise:@"MissingFont" format:@"No font found with Roboto-Bold name"];
    }

    return font;
}

@end
