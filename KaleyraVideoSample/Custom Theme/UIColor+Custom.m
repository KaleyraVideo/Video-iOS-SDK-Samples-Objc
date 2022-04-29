//
//  UIColor+Custom.m
//  KaleyraVideoSample
//
//  Created by Alessandro Limardo on 29/04/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UIColor+Custom.h"

@implementation UIColor(Custom)

+ (UIColor *)accentColor
{
    UIColor *color;

    if (@available(iOS 11.0, *))
    {
        UIColor *accent = [UIColor colorNamed:@"AccentColor"];
        if (accent)
        {
            color = accent;
        }
        else
        {
            color = [[UIColor alloc] initWithRed:0 green:107/255 blue:128/255 alpha:1];
        }
    }
    else
    {
        color = [[UIColor alloc] initWithRed:0 green:107/255 blue:128/255 alpha:1];
    }

    return color;
}

+ (UIColor *)customBackground
{
    UIColor *color;

    if (@available(iOS 13.0, *))
    {
        color = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
            {
                return [[UIColor alloc] initWithRed:0 green:139/255 blue:139/255 alpha:1];
            }
            else
            {
                return [[UIColor alloc] initWithRed:175/255 green:238/255 blue:238/255 alpha:1];
            }
        }];
    }
    else
    {
        color = [[UIColor alloc] initWithRed:175/255 green:238/255 blue:238/255 alpha:1];
    }

    return color;
}

+ (UIColor *)customSecondary
{
    UIColor *color;

    if (@available(iOS 13.0, *))
    {
        color = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
            {
                return [[UIColor alloc] initWithRed:60/255 green:180/255 blue:150/255 alpha:1];
            }
            else
            {
                return [[UIColor alloc] initWithRed:60/255 green:179/255 blue:113/255 alpha:1];
            }
        }];
    }
    else
    {
        color = [[UIColor alloc] initWithRed:60/255 green:179/255 blue:113/255 alpha:1];
    }

    return color;
}

+ (UIColor *)customTertiary
{
    UIColor *color;

    if (@available(iOS 13.0, *))
    {
        color = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark)
            {
                return [[UIColor alloc] initWithRed:183/255 green:180/255 blue:186/255 alpha:1];
            }
            else
            {
                return [[UIColor alloc] initWithRed:183/255 green:194/255 blue:183/255 alpha:1];
            }
        }];
    }
    else
    {
        color = [[UIColor alloc] initWithRed:183/255 green:194/255 blue:183/255 alpha:1];
    }

    return color;
}

+ (UIColor *)customBarTintColor
{
    return [[UIColor alloc] initWithRed:169/255 green:146/255 blue:166/255 alpha:1];;
}

@end
