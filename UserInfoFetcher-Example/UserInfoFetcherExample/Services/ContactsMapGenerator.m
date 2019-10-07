//
//  Created by Luca Tagliabue on 07/10/2019.
//  Copyright © 2019 Bandyer. All rights reserved.
//

#import "ContactsMapGenerator.h"
#import "AddressBook.h"
#import "Contact.h"

@interface ContactsMapGenerator()

@property (nonatomic, strong, readonly) AddressBook *addressBook;

@end

@implementation ContactsMapGenerator

- (instancetype)initWithAddressBook:(AddressBook *)addressBook
{
    self = [super init];

    if (self)
    {
        _addressBook = addressBook;
    }

    return self;
}

- (NSDictionary<NSString*, Contact*> *)createAliasMap
{
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithCapacity:self.addressBook.contacts.count + 1];

    for (Contact *contact in self.addressBook.contacts)
    {
        map[contact.alias] = contact;
    }

    map[self.addressBook.me.alias] = self.addressBook.me;

    return map;
}

@end
