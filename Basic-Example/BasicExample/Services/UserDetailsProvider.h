//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bandyer/Bandyer.h>

@class AddressBook;

NS_ASSUME_NONNULL_BEGIN

@interface UserDetailsProvider : NSObject <BDKUserDetailsProvider>

@property (nonatomic, strong, readonly) AddressBook *addressBook;

- (instancetype)initWithAddressBook:(AddressBook *)addressBook;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
