//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import <Bandyer/Bandyer.h>

@interface SessionFactory : NSObject

+ (BDKSession *)makeSessionFor:(NSString *)userID;

@end
