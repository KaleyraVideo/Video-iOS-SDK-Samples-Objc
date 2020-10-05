//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>

@class Contact;

NS_ASSUME_NONNULL_BEGIN

@interface AddressBook : NSObject <NSCopying>

@property (nonatomic, strong) Contact *me;
@property (nonatomic, strong) NSArray<Contact *> *contacts;

- (nullable Contact *)contactForAlias:(NSString *)alias;
- (void)updateFromArray:(nullable NSArray<NSString *> *)users currentUser:(NSString *)currentUser;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
