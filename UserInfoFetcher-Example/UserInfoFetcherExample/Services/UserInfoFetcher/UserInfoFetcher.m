//
//  Created by Luca Tagliabue on 07/10/2019.
//  Copyright © 2019 Bandyer. All rights reserved.
//

#import "UserInfoFetcher.h"
#import "AddressBook.h"
#import "Contact.h"
#import "ContactsMapGenerator.h"

@interface UserInfoFetcher()

@property (nonatomic, strong, readonly) AddressBook *addressBook;
@property (nonatomic, strong, readonly) NSDictionary<NSString*, Contact*> *aliasMap;

@end

@implementation UserInfoFetcher


- (instancetype)initWithAddressBook:(AddressBook *)addressBook
{
    self = [super init];

    if (self)
    {
        _addressBook = addressBook;
        _aliasMap = [[[ContactsMapGenerator alloc] initWithAddressBook:addressBook] createAliasMap];
    }

    return self;
}

- (void)fetchUsers:(NSArray<NSString *> *)aliases completion:(void (^)(NSArray<BDKUserInfoDisplayItem *> *_Nullable items))completion
{
    NSMutableArray<BDKUserInfoDisplayItem *> *items = [NSMutableArray arrayWithCapacity:aliases.count];

    for (NSString *alias in aliases)
    {
        Contact *contact = self.aliasMap[alias];
        //Suppose we want to have all the fields available.
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

@end
