//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE.txt for licensing information
//

#import <Bandyer/Bandyer.h>

#import "UserInfoFetcher.h"
#import "Contact.h"
#import "AddressBook.h"

@interface UserInfoFetcher()

@property (nonatomic, strong, readonly) NSDictionary<NSString*, Contact*> *aliasMap;

@end

@implementation UserInfoFetcher


- (instancetype)initWithAddressBook:(AddressBook *)addressBook
{
    self = [super init];

    if (self)
    {
        _addressBook = addressBook;
        _aliasMap = [self.class createAliasMap:addressBook];
    }

    return self;
}

- (void)fetchUsers:(NSArray<NSString *> *)aliases completion:(void (^)(NSArray<BDKUserInfoDisplayItem *> *_Nullable items))completion
{
    NSMutableArray<BDKUserInfoDisplayItem *> *items = [NSMutableArray arrayWithCapacity:aliases.count];

    for (NSString *alias in aliases)
    {
        Contact *contact = self.aliasMap[alias];
        BDKUserInfoDisplayItem *item = [[BDKUserInfoDisplayItem alloc] initWithAlias:alias];
        item.firstName = contact.firstName;
        item.lastName = contact.lastName;
        item.email = contact.email;
        item.imageURL = contact.profileImageURL;
        [items addObject:item];
    }

    completion(items);
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    UserInfoFetcher *copy = (UserInfoFetcher *) [[[self class] allocWithZone:zone] init];

    if (copy != nil)
    {
        copy->_addressBook = [_addressBook copyWithZone:zone];
        copy->_aliasMap = [_aliasMap copyWithZone:zone];
    }

    return copy;
}


+ (NSDictionary<NSString*, Contact*> *)createAliasMap:(AddressBook *)addressBook
{
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithCapacity:addressBook.contacts.count + 1];

    for (Contact *contact in addressBook.contacts)
    {
        map[contact.alias] = contact;
    }

    map[addressBook.me.alias] = addressBook.me;

    return map;
}

@end
