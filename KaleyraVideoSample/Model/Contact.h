//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(char, Gender)
{
    GenderUnknown = -1,
    GenderMale = 0,
    GenderFemale = 1,
};

@interface Contact : NSObject <NSCopying>

@property (nonatomic, strong, nullable) NSString *userID;

@property (nonatomic, strong, nullable, readonly) NSString *fullName;

@property (nonatomic, strong, nullable) NSString *firstName;

@property (nonatomic, strong, nullable) NSString *lastName;

@property (nonatomic, strong, nullable) NSString *email;

@property (nonatomic, strong, nullable) NSNumber *age;

@property (nonatomic, assign) Gender gender;

@property (nonatomic, strong, nullable) NSURL *profileImageURL;

@end

NS_ASSUME_NONNULL_END
