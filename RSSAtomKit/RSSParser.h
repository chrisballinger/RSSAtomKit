//
//  RSSParser.h
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import <Foundation/Foundation.h>
#import "RSSFeed.h"
#import "RSSItem.h"

@interface RSSParser : NSObject

@property (nonatomic, strong, readonly) Class feedClass;
@property (nonatomic, strong, readonly) Class itemClass;

/**
 *  You can register a custom subclass of RSSFeed.
 *
 *  @param modelClass RSSFeed subclass
 */
- (void) registerFeedClass:(Class)feedClass;

/**
 *  You can register a custom subclass of RSSItem.
 *
 *  @param modelClass RSSItem subclass
 */
- (void) registerItemClass:(Class)itemClass;

/**
 *  Parses xmlData into an RSSFeed object and array of RSSItems.
 *
 *  @param xmlData UTF-8 feed data to parse
 *  @param completionBlock feed & items, or error
 *  @param completionQueue if nil, defaults to main queue
 */
- (void) feedFromXMLData:(NSData*)xmlData
         completionBlock:(void (^)(RSSFeed *feed, NSArray *items, NSError *error))completionBlock
         completionQueue:(dispatch_queue_t)completionQueue;

@end
