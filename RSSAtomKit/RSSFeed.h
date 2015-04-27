//
//  RSSFeed.h
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import "MTLModel.h"
#import "Ono.h"

typedef NS_ENUM(NSUInteger, RSSFeedType) {
    RSSFeedTypeUnknown, // Parse Error
    RSSFeedTypeRDF, // RDF / RSS 1.0
    RSSFeedTypeRSS, // RSS 2.0
    RSSFeedTypeAtom // Atom 1.0
};

extern NSString *const kRSSFeedAtomPrefix;
extern NSString *const kRSSFeedAtomNameSpace;

extern NSString *const kRSSFeedRSSPrefix;
extern NSString *const kRSSFeedRSSNameSpace;

@interface RSSFeed : MTLModel

/**
 The feed type. Based on weather the parser finds 'feeds' or 'channel'. If 'channel is found first it is RSSFeedTypeRSS
 */
@property (nonatomic, readonly) RSSFeedType feedType;

/**
 The feed title
 RSS: first child in 'channel' with tag 'title'
 Atom: first child in 'feed' with tag 'title'
 */
@property (nonatomic, strong, readonly) NSString *title;

/**
 The feeds html url
 RSS: first child in 'channel' with tag 'link'
 Atom: first child in 'feed' with tag link and attributes rel = alternate and type = text/html
 */
@property (nonatomic, strong, readonly) NSURL *htmlURL;

/**
 This is the 'self' url not all xml documents will have this, especially RSS so it may need to be set manually if known
 RSS: tries the atom method with type = 'applicatoin/rss+xml'. Can handle strange namespaces
 Atom: tries tag atom:link with attributes rel = self and type = application/atom+xml and href
 */
@property (nonatomic, strong) NSURL *xmlURL;

/**
 The feeds description
 RSS: first child in 'channel' with tag 'description'
 Atom: first child in 'feed' with tag 'subtitle'
 */
@property (nonatomic, strong, readonly) NSString *feedDescription;

/**
 Creates and returns a RSSFeed object from an ONOXMLDocument
 
 @param xmlDocument the xml document that will be parsed
 @param error any errors encountered parsing the document
 @return An initialized RSSFeed object
 */
- (instancetype) initWithXMLDocument:(ONOXMLDocument*)xmlDocument
                               error:(NSError**)error;

/**
 Creates an array of feeds from an OPML document
 
 @param xmlDocument the xml document that will be parsed
 @param error any errers encountered parsing the document
 @return An array of RSSFeed objects derivied from the data in the OPML document
 */
+ (NSArray *) feedsFromOPMLDocument:(ONOXMLDocument*)xmlDocument
                              error:(NSError**)error;

@end
