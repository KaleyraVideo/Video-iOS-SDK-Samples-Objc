//
//  Created by Luca Tagliabue on 07/10/2019.
//  Copyright © 2019 Bandyer. All rights reserved.
//

#import "GlobalUserInfoFetcher.h"
#import "AddressBook.h"
#import "Contact.h"
#import "ContactsMapGenerator.h"

static GlobalUserInfoFetcher* DefaultInstance = nil;

@interface GlobalUserInfoFetcher()

@property (nonatomic, strong, readonly) NSDictionary<NSString*, Contact*> *aliasMap;

@end

@implementation GlobalUserInfoFetcher

+ (GlobalUserInfoFetcher*)instance {
    return DefaultInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if(!DefaultInstance) {
            DefaultInstance = self;
        }
    }
    return self;
}

- (void)setAddressBook:(AddressBook *)updatedAddressBook {
    if (_addressBook == updatedAddressBook) return;
    
    _aliasMap = [[[ContactsMapGenerator alloc] initWithAddressBook:updatedAddressBook] createAliasMap];
    
    _addressBook = updatedAddressBook;
}

- (void)fetchUsers:(NSArray<NSString *> *)aliases completion:(void (^)(NSArray<BDKUserInfoDisplayItem *> *_Nullable items))completion
{
    NSMutableArray<BDKUserInfoDisplayItem *> *items = [NSMutableArray arrayWithCapacity:aliases.count];

    for (NSString *alias in aliases)
    {
        Contact *contact = self.aliasMap[alias];
        //Suppose globally we want to have all the fields available.
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
    GlobalUserInfoFetcher *copy = (GlobalUserInfoFetcher *) [[[self class] allocWithZone:zone] init];

    if (copy != nil)
    {
        copy->_addressBook = [_addressBook copyWithZone:zone];
        copy->_aliasMap = [_aliasMap copyWithZone:zone];
    }

    return copy;
}

@end
