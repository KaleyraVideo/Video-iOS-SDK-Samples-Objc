//
//  Created by Luca Tagliabue on 07/10/2019.
//  Copyright © 2019 Bandyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BandyerSDK/BandyerSDK.h>

@class AddressBook;

NS_ASSUME_NONNULL_BEGIN

@interface GlobalUserInfoFetcher : NSObject <BDKUserInfoFetcher>

@property (nonatomic, strong) AddressBook *addressBook;

+ (GlobalUserInfoFetcher* _Nullable)instance;

@end

NS_ASSUME_NONNULL_END
