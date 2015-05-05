//
//  RSSParser.m
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import "RSSParser.h"
#import "Ono.h"

@implementation RSSParser

- (instancetype) init {
    if (self = [super init]) {
        _feedClass = [RSSFeed class];
        _itemClass = [RSSItem class];
        _mediaItemClass = [RSSMediaItem class];
    }
    return self;
}

/**
 *  You can register a custom subclass of RSSFeed.
 *
 *  @param modelClass RSSFeed subclass
 */
- (void) registerFeedClass:(Class)feedClass {
    if ([feedClass isSubclassOfClass:[RSSFeed class]]) {
        _feedClass = feedClass;
    }
}

/**
 *  You can register a custom subclass of RSSItem.
 *
 *  @param modelClass RSSItem subclass
 */
- (void) registerItemClass:(Class)itemClass {
    if ([itemClass isSubclassOfClass:[RSSItem class]]) {
        _itemClass = itemClass;
    }
}

/**
 *  You can register a custom subclass of RSSMediaItem.
 *
 *  @param modelClass RSSMediaItem subclass
 */
- (void) registerMediaItemClass:(Class)mediaItemClass {
    if ([mediaItemClass isSubclassOfClass:[RSSMediaItem class]]) {
        _mediaItemClass = mediaItemClass;
    }
}

/**
 *  Parses xmlData into an RSSFeed object and array of RSSItems.
 *
 *  @param xmlData UTF-8 feed data to parse
 *  @param completionBlock feed & items, or error
 *  @param completionQueue if nil, defaults to main queue
 */
- (void) feedFromXMLData:(NSData*)xmlData
               sourceURL:(NSURL *)sourceURL
         completionBlock:(void (^)(RSSFeed *feed, NSArray *items, NSError *error))completionBlock
         completionQueue:(dispatch_queue_t)completionQueue {
    NSParameterAssert(xmlData);
    NSParameterAssert(completionBlock);
    if (!xmlData || !completionBlock) {
        return;
    }
    if (!completionQueue) {
        completionQueue = dispatch_get_main_queue();
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithData:xmlData error:&error];
        if (error) {
            dispatch_async(completionQueue, ^{
                completionBlock(nil, nil, error);
            });
            return;
        }
        RSSFeed *feed = [[self.feedClass alloc] initWithXMLDocument:document sourceURL:sourceURL error:&error];
        if (error) {
            dispatch_async(completionQueue, ^{
                completionBlock(nil, nil, error);
            });
        }
        NSArray *items = [self.itemClass itemsWithFeedType:feed.feedType xmlDocument:document mediaItemClass:self.mediaItemClass];
        dispatch_async(completionQueue, ^{
            completionBlock(feed, items, nil);
        });
    });
}

- (void)feedsFromOPMLData:(NSData *)opmlData
          completionBlock:(void (^)(NSArray *, NSError *))completionBlock

          completionQueue:(dispatch_queue_t)completionQueue {
    
    NSParameterAssert(opmlData);
    NSParameterAssert(completionBlock);
    if (!opmlData || !completionBlock) {
        return;
    }
    if (!completionQueue) {
        completionQueue = dispatch_get_main_queue();
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithData:opmlData error:&error];
        if (error) {
            dispatch_async(completionQueue, ^{
                completionBlock(nil,error);
            });
            return;
        }
        
        NSArray *feeds = [self.feedClass feedsFromOPMLDocument:document error:&error];
        if (error) {
            dispatch_async(completionQueue, ^{
                completionBlock(nil,error);
            });
            return;
        }
        
        dispatch_async(completionQueue, ^{
            completionBlock(feeds,nil);
        });
        
    });
}


@end
