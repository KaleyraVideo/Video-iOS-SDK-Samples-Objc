//
//  Copyright © 2020 Bandyer. All rights reserved.
//  See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>

@class Contact;

NS_ASSUME_NONNULL_BEGIN

@interface ContactsGenerator : NSObject

+ (Contact *)generateContact;

@end

NS_ASSUME_NONNULL_END
