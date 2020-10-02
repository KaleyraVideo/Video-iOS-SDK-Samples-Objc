//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE.txt for licensing information
//

#import "UIColor+Custom.h"

@implementation UIColor (Custom)

+ (UIColor *)accentColor
{
    UIColor *color;
    if (@available(iOS 11.0, *))
    {
        UIColor *colorNamed = [UIColor colorNamed:@"AccentColor"];
        if (colorNamed)
        {
            color = colorNamed;
        } else
        {
            color = [UIColor colorWithRed:0 green:107/255.0f blue:128/255.0f alpha:1];
        }
    } else
    {
        color = [UIColor colorWithRed:0 green:107/255.0f blue:128/255.0f alpha:1];
    }
    
    return color;
}

+ (UIColor *)customBackground
{
    UIColor *color;
    if (@available(iOS 13.0, *))
    {
        color = [[UIColor alloc] initWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
            switch (traitCollection.userInterfaceStyle) {
                case UIUserInterfaceStyleDark:
                    return [UIColor colorWithRed:0  green:139/255.0f blue:139/255.0f alpha:1];
                default:
                    return [UIColor colorWithRed:175/255.0f  green:238/255.0f blue:238/255.0f alpha:1];
            }
        }];
    } else
    {
        color = [UIColor colorWithRed:175/255.0f  green:238/255.0f blue:238/255.0f alpha:1];
    }
    return color;
}

+ (UIColor *)customSecondary
{
    UIColor *color;
    if (@available(iOS 13.0, *))
    {
        color = [[UIColor alloc] initWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
            switch (traitCollection.userInterfaceStyle) {
                case UIUserInterfaceStyleDark:
                    return [UIColor colorWithRed:60/255.0f  green:180/255.0f blue:150/255.0f alpha:1];
                default:
                    return [UIColor colorWithRed:60/255.0f  green:179/255.0f blue:113/255.0f alpha:1];
            }
        }];
    } else
    {
        color = [UIColor colorWithRed:60/255.0f  green:179/255.0f blue:113/255.0f alpha:1];
    }
    return color;
}

+ (UIColor *)customTertiary
{
    UIColor *color;
    if (@available(iOS 13.0, *))
    {
        color = [[UIColor alloc] initWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
            switch (traitCollection.userInterfaceStyle) {
                case UIUserInterfaceStyleDark:
                    return [UIColor colorWithRed:183/255.0f  green:180/255.0f blue:186/255.0f alpha:1];
                default:
                    return [UIColor colorWithRed:183/255.0f  green:194/255.0f blue:183/255.0f alpha:1];
            }
        }];
    } else
    {
        color = [UIColor colorWithRed:183/255.0f  green:194/255.0f blue:183/255.0f alpha:1];
    }
    return color;
}

+ (UIColor *)customBarTintColor
{
    return [UIColor colorWithRed:169/255.0f green:146/255.0f blue:166/255.0f alpha:1];
}

@end
