//
//  AccessTokenProviderMock.m
//  KaleyraVideoSample
//
//  Created by Alessandro Limardo on 29/04/22.
//

#import <Foundation/Foundation.h>

#import "AccessTokenProviderMock.h"

@implementation AccessTokenProviderMock

// The Kaleyra Video platform now uses a strong authentication mechanism based on JWT tokens while authenticating
// its clients. You are required to provide an object conforming to the AccessTokenProvider protocol to the Session
// object before connecting the SDK. The Kaleyra Video SDK will call the provideAccessToken(userId:completion:) method
// every time it needs an access token.
- (void)provideAccessTokenWithUserId:(NSString * _Nonnull)userId success:(void (^ _Nonnull)(NSString * _Nonnull))success error:(void (^ _Nonnull)(NSError * _Nonnull))error
{
    #error "Please change this token with a valid one"
    // Here you are supposed to request a new access token to your backend system
    NSString *newAccessToken = @"FRESH NEW TOKEN";

    // Once you obtained back an Access Token from your backend you should call the success completion block passing it as argument.
    // If an error occurred in your token retrieve process call the error completion block with the occurred error.
    success(newAccessToken);
}

@end
