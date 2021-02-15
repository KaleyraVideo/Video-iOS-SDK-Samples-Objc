//
//  Copyright © 2019 Bandyer. All rights reserved.
//

#import "UserDetailsProvider.h"
#import "Contact.h"
#import "AddressBook.h"

#import <Bandyer/Bandyer.h>
#import <CallKit/CallKit.h>

@interface UserDetailsProvider()

@property (nonatomic, strong, readonly) NSDictionary<NSString*, Contact*> *aliasMap;

@end

@implementation UserDetailsProvider


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

- (void)provideDetails:(NSArray<NSString *> *)aliases completion:(void (^)(NSArray<BDKUserDetails *> * _Nonnull))completion
{
    NSMutableArray<BDKUserDetails *> *users = [NSMutableArray arrayWithCapacity:aliases.count];

    for (NSString *alias in aliases)
    {
        Contact *contact = self.aliasMap[alias];
        BDKUserDetails *user = [[BDKUserDetails alloc] initWithAlias:alias
                                                           firstname:contact.firstName
                                                            lastname:contact.lastName
                                                               email:contact.email
                                                            imageURL:contact.profileImageURL];
        [users addObject:user];
    }

    completion(users);
}

- (void)provideHandle:(NSArray<NSString *> *)aliases completion:(void (^)(CXHandle * _Nonnull))completion
{

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
