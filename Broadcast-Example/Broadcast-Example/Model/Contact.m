//
//  Copyright © 2019-2021 Bandyer. All rights reserved.
//

#import "Contact.h"

@implementation Contact

- (NSString *)fullName
{
    if (self.firstName && self.lastName)
        return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];

    return nil;
}


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _gender = GenderUnknown;
    }

    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    Contact *copy = (Contact *) [[[self class] allocWithZone:zone] init];

    if (copy != nil)
    {
        copy.alias = [self.alias copyWithZone:zone];
        copy.firstName = [self.firstName copyWithZone:zone];
        copy.lastName = [self.lastName copyWithZone:zone];
        copy.email = [self.email copyWithZone:zone];
        copy.age = [self.age copyWithZone:zone];
        copy.gender = self.gender;
        copy.profileImageURL = [self.profileImageURL copyWithZone:zone];
    }

    return copy;
}

@end
