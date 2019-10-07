//
//  Created by Luca Tagliabue on 07/10/2019.
//  Copyright © 2019 Bandyer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AddressBook;
@class Contact;

NS_ASSUME_NONNULL_BEGIN

@interface ContactsMapGenerator : NSObject

- (instancetype)initWithAddressBook:(AddressBook *)addressBook;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (NSDictionary<NSString*, Contact*> *)createAliasMap;

@end

NS_ASSUME_NONNULL_END
