//
//  RSSAtomKit.h
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import <Foundation/Foundation.h>
#import "RSSParser.h"

@interface RSSAtomKit : NSObject

/**
 *  You can set custom subclasses for parsed RSSFeed and RSSItems.
 *  @see RSSParser
 */
@property (nonatomic, strong, readonly) RSSParser *parser;

/**
 *  Set custom NSURLSession settings, such as SOCKS proxy.
 *
 *  @param if nil, defaults to ephemeralSessionConfiguration
 *
 *  @return parser
 */
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration;

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
          completionQueue:(dispatch_queue_t)completionQueue;

@end
