//
//  Constants.m
//  KaleyraVideoSample
//
//  Created by Alessandro Limardo on 29/04/22.
//

#import <Foundation/Foundation.h>

#import "Constants.h"

@implementation Constants

#error "Please change these constants with you own values"

+ (NSString *) appId
{
    // The app id identifies your company in the Kaleyra video ecosystem
    return @"PUT YOUR APP ID HERE";
}

+ (NSString *) apiKey
{
    // When integrating the SDK in your app you are not required to provide an api key
    // We are using the api key in this app only to retrieve the user list for your company
    // for simplicity and demonstration purpose only
    return @"PUT YOUR API KEY HERE";
}

+ (NSString *) restURL
{
    // A URL pointing to a REST API on your backend where retrieve users informations.
    return @"REST URL";
}

+ (NSString *) appGroupIdentifier
{
    // The App group identifier is needed by the SDK and the BroadcastExtension in order to communicate
    // If you plan to not opt-in for the Broadcast screen sharing feature you can leave this field as is
    return @"PUT THE APP GROUP IDENTIFIER HERE";
}

+ (NSString *) broadcastExtensionBundleId
{
    // The broadcast upload app extension bundle identifier is needed by the SDK and in order to tell
    // the system picker to list only your broadcast upload extension among those that are installed on the
    // device capable of handling a broadcast upload.
    // If you plan to not opt-in for the Broadcast screen sharing feature you can leave this field as is
    return @"PUT THE BROADCAST EXTENSION BUNDLE ID HERE";
}

@end
