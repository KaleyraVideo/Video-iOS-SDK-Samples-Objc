//
//  Copyright © 2019 Bandyer. All rights reserved.
//

#import "AddressBook.h"
#import "Contact.h"
#import "ContactsGenerator.h"

@interface AddressBook ()

@property (nonatomic, strong, readwrite) Contact *me;
@property (nonatomic, strong, readwrite) NSArray<Contact *> *contacts;

@end

@implementation AddressBook

- (id)copyWithZone:(nullable NSZone *)zone
{
    AddressBook *copy = (AddressBook *) [[[self class] allocWithZone:zone] init];

    if (copy != nil)
    {
        copy.me = [self.me copyWithZone:zone];
        copy.contacts = [self.contacts copyWithZone:zone];
    }

    return copy;
}

+ (instancetype)createFromUserArray:(nullable NSArray<NSString *> *)users currentUser:(NSString *)currentUser
{
    NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:users.count];
    AddressBook *addressBook = [AddressBook new];

    [users enumerateObjectsUsingBlock:^(NSString *userId, NSUInteger idx, BOOL *stop) {

        Contact *contact = [ContactsGenerator generateContact];
        contact.alias = userId;

        if ([userId isEqualToString:currentUser])
        {
            addressBook.me = contact;
        } else
        {
            [contacts addObject:contact];
        }
    }];

    addressBook.contacts = [contacts copy];

    return addressBook;
}

@end
