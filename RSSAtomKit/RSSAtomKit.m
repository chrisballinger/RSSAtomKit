//
//  RSSAtomKit.m
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import "RSSAtomKit.h"
#import "AFNetworking.h"

@interface RSSAtomKit()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@end

@implementation RSSAtomKit

/**
 *  Set custom NSURLSession settings, such as SOCKS proxy.
 *
 *  @param if nil, defaults to ephemeralSessionConfiguration
 *
 *  @return parser
 */
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    if (self = [super init]) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
        serializer.acceptableContentTypes  = [NSSet setWithObjects:@"application/xml",
                                                        @"text/xml",
                                                        @"application/rss+xml",
                                                        @"application/atom+xml",
                                                        nil];
        self.sessionManager.responseSerializer = serializer;
        _parser = [[RSSParser alloc] init];
    }
    return self;
    
}

- (instancetype) init {
    if (self = [self initWithSessionConfiguration:nil]) {
    }
    return self;
}

/**
 *  Fetches and parses the feed at feedURL into an RSSFeed object
 *  and array of RSSItems.
 *
 *  @param xmlDocument     feed to parse
 *  @param completionBlock feed & items, or error
 *  @param completionQueue if nil, defaults to main queue
 */
- (void) parseFeedFromURL:(NSURL*)feedURL
          completionBlock:(void (^)(RSSFeed *feed, NSArray *items, NSError *error))completionBlock
          completionQueue:(dispatch_queue_t)completionQueue {
    NSParameterAssert(feedURL);
    NSParameterAssert(completionBlock);
    if (!feedURL || !completionBlock) {
        return;
    }
    if (!completionQueue) {
        completionQueue = dispatch_get_main_queue();
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:feedURL];
    RSSParser *parser = self.parser;
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            dispatch_async(completionQueue, ^{
                completionBlock(nil, nil, error);
            });
            return;
        }
        NSAssert([responseObject isKindOfClass:[NSData class]], @"responseObject must be NSData!");
        if (![responseObject isKindOfClass:[NSData class]]) {
            dispatch_async(completionQueue, ^{
                completionBlock(nil, nil, [NSError errorWithDomain:@"RSSAtomKit" code:100 userInfo:@{NSLocalizedDescriptionKey: @"responseObject must be NSData!"}]);
            });
            return;
        }
        [parser feedFromXMLData:responseObject completionBlock:completionBlock completionQueue:completionQueue];
    }];
    [dataTask resume];
}

@end
