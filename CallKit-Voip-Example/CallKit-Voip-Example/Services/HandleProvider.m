// Copyright © 2020 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

#import "HandleProvider.h"
#import "AddressBook.h"
#import "Contact.h"

#import <CallKit/CallKit.h>

@interface HandleProvider()

@property (nonatomic, strong, readonly) AddressBook *addressBook;

@end

@implementation HandleProvider

- (instancetype)initWithAddressBook:(AddressBook *)addressBook
{
    self = [super init];

    if (self)
    {
        _addressBook = addressBook;
    }

    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
    return self;
}

- (void)handleForAliases:(nullable NSArray<NSString *> *)aliases completion:(nonnull void (^)(CXHandle * _Nonnull))completion
{
    if (aliases.count == 0)
    {
        completion([self _makeHandle:@"Unknown"]);
        return;
    }

    CXHandle *handle = [self _makeHandle:[self _retrieveContactNames:aliases]];
    completion(handle);
}

- (NSString *)_retrieveContactNames:(NSArray<NSString *> *)aliases
{
    NSMutableArray *names = [NSMutableArray array];

    for (NSString *alias in aliases) {
        Contact *contact = [self.addressBook contactForAlias:alias];
        NSString *name = [contact fullName];

        if (name)
            [names addObject:name];
    }

    return [names componentsJoinedByString:@", "];
}

- (CXHandle *)_makeHandle:(NSString *)value
{
    return [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:value];
}

@end
