//
//  RSSAtomKit.m
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import "RSSAtomKit.h"

@interface RSSAtomKit()
@property (nonatomic, strong, readonly) NSURLSession *urlSession;
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
        self.urlSessionConfiguration = configuration;
        _parser = [[RSSParser alloc] init];
    }
    return self;
}

- (instancetype) init {
    return [self initWithSessionConfiguration:nil];
}

- (void)setUrlSessionConfiguration:(NSURLSessionConfiguration *)urlSessionConfiguration
{
    if (!urlSessionConfiguration) {
        urlSessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    }
    if (![urlSessionConfiguration isEqual:self.urlSessionConfiguration]) {
        [self.urlSession invalidateAndCancel];
        _urlSession = [NSURLSession sessionWithConfiguration:urlSessionConfiguration];
    }
}

- (NSURLSessionConfiguration *)urlSessionConfiguration
{
    return self.urlSession.configuration;
}

#pragma - mark Public Methods
/**
 *  Fetches and parses the feed at feedURL into an RSSFeed object
 *  and array of RSSItems.
 *
 *  @param feedURL feed url to fetch and parse
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
    
    RSSParser *parser = self.parser;
    [self fetchData:feedURL completion:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        if (error) {
            dispatch_async(completionQueue, ^{
                completionBlock(nil, nil, error);
            });
        } else {
            [parser feedFromXMLData:responseData sourceURL:response.URL completionBlock:completionBlock completionQueue:completionQueue];
        }
    }];
}

/**
 Fetches and prarses the OPML document at the url location into a NSArray of RSSFeeds
 
 @param opmlURL opml document url to fetch and parse
 @param completionBlock feeds or error
 @param completionQueue if nil, defaults to main queue
 */
- (void) parseFeedsFromOPMLURL:(NSURL*)opmlURL
               completionBlock:(void (^)(NSArray *feeds, NSError *error))completionBlock
               completionQueue:(dispatch_queue_t)completionQueue
{
    NSParameterAssert(opmlURL);
    NSParameterAssert(completionBlock);
    if (!opmlURL || !completionBlock) {
        return;
    }
    if (!completionQueue) {
        completionQueue = dispatch_get_main_queue();
    }
    
    __block RSSParser *parser = self.parser;
    [self fetchData:opmlURL completion:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        if (error) {
            dispatch_async(completionQueue, ^{
                completionBlock(nil,error);
            });
        } else {
            [parser feedsFromOPMLData:responseData completionBlock:completionBlock completionQueue:completionQueue];
        }
    }];
}

#pragma - mark Private Methods

- (void)fetchData:(NSURL *)url completion:(void (^)(NSURLResponse *response, NSData *responseData, NSError *error))completion {
    if (!completion) {
        return;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error) {
        if (error) {
            completion(response,nil,error);
        } else {
            completion(response, data, error);
        }
    }];
    [dataTask resume];
}
                                           

@end
