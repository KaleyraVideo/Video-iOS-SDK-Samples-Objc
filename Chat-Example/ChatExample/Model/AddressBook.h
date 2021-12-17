//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Contact;

NS_ASSUME_NONNULL_BEGIN

@interface AddressBook : NSObject <NSCopying>

@property (nonatomic, strong, readonly) Contact *me;
@property (nonatomic, strong, readonly) NSArray<Contact *> *contacts;

+ (instancetype)createFromUserArray:(nullable NSArray<NSString*> *)users currentUser:(NSString *)currentUser;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
