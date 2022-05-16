//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import "UserDetailsProvider.h"
#import "Contact.h"
#import "AddressBook.h"

#import <Bandyer/Bandyer.h>
#import <CallKit/CallKit.h>

@interface UserDetailsProvider()

@property (nonatomic, strong, readonly) NSDictionary<NSString*, Contact*> *userIdsMap;

@end

@implementation UserDetailsProvider


- (instancetype)initWithAddressBook:(AddressBook *)addressBook
{
    self = [super init];

    if (self)
    {
        _addressBook = addressBook;
        _userIdsMap = [self.class createUserIdsMap:addressBook];
    }

    return self;
}

- (void)provideDetails:(NSArray<NSString *> *)userIds completion:(void (^)(NSArray<BDKUserDetails *> * _Nonnull))completion
{
    NSMutableArray<BDKUserDetails *> *users = [NSMutableArray arrayWithCapacity:userIds.count];

    for (NSString *userId in userIds)
    {
        Contact *contact = self.userIdsMap[userId];
        BDKUserDetails *user = [[BDKUserDetails alloc] initWithUserID:userId
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

+ (NSDictionary<NSString*, Contact*> *)createUserIdsMap:(AddressBook *)addressBook
{
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithCapacity:addressBook.contacts.count + 1];

    for (Contact *contact in addressBook.contacts)
    {
        map[contact.userID] = contact;
    }

    map[addressBook.me.userID] = addressBook.me;

    return map;
}

@end
