//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
//

#import "UserRepository.h"


@interface UserRepository()

@property (nonatomic, strong, nullable) NSURLSessionDataTask* task;
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSString *apiKey;

@end

@implementation UserRepository

- (dispatch_queue_t)notificationQueue
{
    if (!_notificationQueue)
    {
        _notificationQueue = dispatch_get_main_queue();
    }

    return _notificationQueue;
}

- (BOOL)isFetching
{
    return self.task != nil && self.task.state != NSURLSessionTaskStateCompleted;
}

- (instancetype)init
{
    self = [super init];

    if (self)
    {
#error "Here we are retrieving user information from the Bandyer servers. In order to retrieve user information you must provide a Bandyer REST Api Key and a REST Endpoint. Beware your app should retrieve user information from YOUR backend system not directly from ours."
        _url = [NSURL URLWithString:@"REST URL"];
        _apiKey = @"REST API KEY";
    }

    return self;
}

- (void)fetchAllUsers:(void (^)(NSArray<NSString *> *userIds, NSError *error))completion
{
    NSAssert(self.url, @"An url must be provided");
    NSAssert(self.apiKey, @"An api key must be provided");
    NSCParameterAssert(completion);

    if (self.isFetching)
    {
        dispatch_async(self.notificationQueue, ^{
            completion(nil, [NSError errorWithDomain:@"com.acme.error" code:1 userInfo:@{NSLocalizedFailureReasonErrorKey : @"Already fetching users"}]);
        });

        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
    [request addValue:self.apiKey forHTTPHeaderField:@"apikey"];
    NSURLSession *session = [NSURLSession sharedSession];

    self.task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (error)
        {
            NSLog(@"An error occurred while fetching users");

            dispatch_async(self.notificationQueue, ^{
                completion(nil, [NSError errorWithDomain:@"com.acme.error" code:2 userInfo:@{NSLocalizedFailureReasonErrorKey : @"An error occurred while fetching users", NSUnderlyingErrorKey : error}]);
            });
            return;
        }

        NSError *parseError;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];

        if (parseError)
        {
            NSLog(@"An error occurred while parsing users");

            dispatch_async(self.notificationQueue, ^{
                completion(nil, [NSError errorWithDomain:@"com.acme.error" code:3 userInfo:@{NSLocalizedFailureReasonErrorKey : @"An error occurred while parsing users", NSUnderlyingErrorKey : parseError}]);
            });
            return;
        }

        dispatch_async(self.notificationQueue, ^{
            completion(jsonDictionary[@"user_id_list"], nil);
        });
    }];

    [self.task resume];
}

@end
