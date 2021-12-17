//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import "AddressBook.h"
#import "Contact.h"
#import "ContactsGenerator.h"

@interface AddressBook ()

@property (nonatomic, strong) Contact *me;
@property (nonatomic, strong) NSArray<Contact *> *contacts;

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

- (Contact *)contactForAlias:(NSString *)alias
{
    for (Contact *contact in self.contacts) {
        if ([contact.alias isEqualToString:alias])
            return contact;
    }

    return nil;
}

- (void)updateFromArray:(nullable NSArray<NSString *> *)users currentUser:(NSString *)currentUser
{
    NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:users.count];

    [users enumerateObjectsUsingBlock:^(NSString *userId, NSUInteger idx, BOOL *stop) {

        Contact *contact = [ContactsGenerator generateContact];
        contact.alias = userId;

        if ([userId isEqualToString:currentUser])
        {
            self.me = contact;
        } else
        {
            [contacts addObject:contact];
        }
    }];

    self.contacts = [contacts copy];
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static AddressBook *instance;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

@end
