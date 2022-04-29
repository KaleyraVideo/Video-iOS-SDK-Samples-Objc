//
//  SessionFactory.h
//  KaleyraVideoSample
//
//  Created by Alessandro Limardo on 29/04/22.
//

#import <Bandyer/Bandyer.h>

@interface SessionFactory : NSObject

+ (BDKSession *)makeSessionFor:(NSString *)userID;

@end
