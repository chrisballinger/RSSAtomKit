//
//  RSSItem.h
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import "MTLModel.h"
#import "RSSFeed.h"
#import "Ono.h"

@class RSSPerson;

/**
 `RSSItem` base object of an item in a RSS or Atom feed. This is normally the nodes with tags 'item' or 'entry'.
*/
@interface RSSItem : MTLModel

@property (nonatomic, readonly) RSSFeedType feedType;

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *itemDescription;
@property (nonatomic, strong, readonly) NSDate *publicationDate;
@property (nonatomic, strong, readonly) NSURL *linkURL;
@property (nonatomic, strong, readonly) RSSPerson *author;

// Media RSS
@property (nonatomic, strong, readonly) NSURL *thumbnailURL;
@property (nonatomic, readonly) CGSize thumbnailSize;

@property (nonatomic, strong, readonly) NSArray *mediaItems;

/**
 Creates an RSSItemObject from an ONOXMLElemnt with a feed type hint
 
 @param xmlElement the xmlElement that all the properties will be derived from
 @param feedtype a hint at what type of feed the xml element is from
 @return an initialized RSSItem
 */
- (instancetype) initWithFeedType:(RSSFeedType)feedType xmlElement:(ONOXMLElement*)xmlElement;

/**
 Creates an array of RSSItem(s) from an entire xml Document. For RSS it looks at all items that match the path /rss/channel/item and for Atom it looks at /feed/entry
 
 @param feedType the type of feed
 @return xmlDocumetn the docuement to be parsed
 */
+ (NSArray*) itemsWithFeedType:(RSSFeedType)feedType xmlDocument:(ONOXMLDocument*)xmlDocument;

@end
