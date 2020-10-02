//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE.txt for licensing information
//

#import "UIFont+Custom.h"

@implementation UIFont (Custom)

+ (UIFont *)robotoMedium
{
    return [UIFont fontWithName:@"Roboto-Medium" size:20];
}

+ (UIFont *)robotoLight
{
    return [UIFont fontWithName:@"Roboto-Light" size:11];
}

+ (UIFont *)robotoThin
{
    return [UIFont fontWithName:@"Roboto-Thin" size:17];
}

+ (UIFont *)robotoRegular
{
    return [UIFont fontWithName:@"Roboto-Regular" size:17];
}

+ (UIFont *)robotoBold
{
    return [UIFont fontWithName:@"Roboto-Bold" size:17];
}

@end
