//
//  RSSItem.m
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import "RSSItem.h"
#import "RSSItem+MediaRSS.h"
#import "NSDate+InternetDateTime.h"
#import "RSSMediaItem.h"
#import "RSSPerson.h"

@implementation RSSItem


- (instancetype) initWithFeedType:(RSSFeedType)feedType xmlElement:(ONOXMLElement*)xmlElement mediaItemClass:(Class)mediaItemClass {
    if (self = [super init]) {
        _feedType = feedType;
        [self parseFeedFromElement:xmlElement mediaItemClass:mediaItemClass];
    }
    return self;
}

- (void) parseFeedFromElement:(ONOXMLElement*)element mediaItemClass:(Class)mediaItemClass {
    
    [self parseRSSFeedFromElement:element mediaItemClass:mediaItemClass];
    
    if (self.feedType == RSSFeedTypeAtom) {
        [self parseAtomFeedFromElement:element mediaItemClass:mediaItemClass];
    }
}

- (void) parseAtomFeedFromElement:(ONOXMLElement *)element mediaItemClass:(Class)mediaItemClass
{
    ONOXMLElement *dateElement = [element firstChildWithTag:@"published"];
    NSString *dateString = [dateElement stringValue];
    if ([dateString length]) {
        _publicationDate = [NSDate dateFromInternetDateTimeString:dateString formatHint:DateFormatHintRFC3339];
    }
    
    ONOXMLElement *linkElement = [element firstChildWithXPath:[NSString stringWithFormat:@".//%@:link[@type = 'text/html']",kRSSFeedAtomPrefix]];
    NSString *linkString = [linkElement valueForAttribute:@"href"];
    if ([linkString length]) {
        _linkURL = [NSURL URLWithString:linkString];
    }
    
    ONOXMLElement *contentElement = [element firstChildWithXPath:[NSString stringWithFormat:@".//%@:content",kRSSFeedAtomPrefix]];
    _itemDescription = [contentElement stringValue];
    
    NSArray *tempMediaItems = [self mediaItemsFromElement:element withXPath:[NSString stringWithFormat:@".//%@:link[@rel = 'enclosure' and @href",kRSSFeedAtomPrefix] mediaItemClass:(Class)mediaItemClass];
    if ([tempMediaItems count]) {
        //Not sure if there's a feed out there with both but oh well we catch it
        _mediaItems = [tempMediaItems arrayByAddingObjectsFromArray:self.mediaItems];
    }
}

- (void) parseRSSFeedFromElement:(ONOXMLElement*)element mediaItemClass:(Class)mediaItemClass{
    ONOXMLElement *titleElement = [element firstChildWithTag:@"title"];
    _title = [titleElement stringValue];
    
    //Picks up on both Atom and RSS methods for links <link> and <atom:link> prefer rss way
    __block NSString *stringURL = nil;
    [[element childrenWithTag:@"link"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ONOXMLElement *linkElement = (ONOXMLElement *)obj;
        stringURL = [linkElement stringValue];
        if ([stringURL length]) {
            *stop = YES;
        }
    }];
    
    if (stringURL) {
        _linkURL = [NSURL URLWithString:stringURL];
    }
    ONOXMLElement *descriptionElement = [element firstChildWithTag:@"description"];
    _itemDescription = [descriptionElement stringValue];
    ONOXMLElement *pubDateElement = [element firstChildWithTag:@"pubDate"];
    NSString *dateString = [pubDateElement stringValue];
    if ([dateString length]) {
        _publicationDate = [NSDate dateFromInternetDateTimeString:dateString formatHint:DateFormatHintRFC822];
    }
    
    ONOXMLElement *authorElement = [element firstChildWithXPath:@"./author"];
    if (!authorElement) {
        authorElement = [element firstChildWithXPath:[NSString stringWithFormat:@"./%@:author",kRSSFeedAtomPrefix]];
    }
    
    if (authorElement) {
        _author = [[RSSPerson alloc] initWithXMLElement:authorElement];
    }
    
    
    // Media RSS
    ONOXMLElement *thumbnailElement = [element firstChildWithTag:@"thumbnail" inNamespace:@"media"];
    if (thumbnailElement) {
        _thumbnailURL = [self media_URLForElement:thumbnailElement];
        _thumbnailSize = [self media_sizeForElement:thumbnailElement];
    }
    
    //These have to happen with seperate XPath searches because some documents don't contain the media prefix and would error on the whole XPath otherwise
    NSArray *tempMediaItems = [self mediaItemsFromElement:element withXPath:@".//enclosure[@url]" mediaItemClass:(Class)mediaItemClass];
    if (!tempMediaItems) {
        tempMediaItems = @[];
    }
    tempMediaItems = [tempMediaItems arrayByAddingObjectsFromArray:[self mediaItemsFromElement:element withXPath:@".//media:content[@url]" mediaItemClass:mediaItemClass]];
    
    if ([tempMediaItems count]) {
        _mediaItems = tempMediaItems;
    }
}

- (NSArray *)mediaItemsFromElement:(ONOXMLElement *)element withXPath:(NSString *)xPath mediaItemClass:(Class)mediaItemClass
{
    NSMutableArray *tempMediaItems = [NSMutableArray array];
    [element enumerateElementsWithXPath:xPath usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
        RSSMediaItem *item = [[mediaItemClass alloc] initWithFeedType:self.feedType xmlElement:element];
        if (item) {
            [tempMediaItems addObject:item];
        }
    }];
    return tempMediaItems;
}


#pragma mark Static Methods

+ (NSArray*) parseRSSItemsWithXPath:(NSString*)XPath
                           feedType:(RSSFeedType)feedType
                           document:(ONOXMLDocument*)document
                     mediaItemClass:(Class)mediaItemClass {
    NSMutableArray *items = [NSMutableArray array];
    [document enumerateElementsWithXPath:XPath usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
        RSSItem *item = [[[self class] alloc] initWithFeedType:feedType xmlElement:element mediaItemClass:mediaItemClass];
        [items addObject:item];
    }];
    return items;
}

+ (NSArray*) itemsWithFeedType:(RSSFeedType)feedType xmlDocument:(ONOXMLDocument*)xmlDocument mediaItemClass:(Class)mediaItemClass
{
    switch (feedType) {
        case RSSFeedTypeRSS:
            return [self parseRSSItemsWithXPath:@"/rss/channel/item" feedType:feedType document:xmlDocument mediaItemClass:mediaItemClass];
            break;
        case RSSFeedTypeAtom:
            return [self parseRSSItemsWithXPath:[NSString stringWithFormat:@"/%@:feed/%@:entry",kRSSFeedAtomPrefix,kRSSFeedAtomPrefix] feedType:feedType document:xmlDocument mediaItemClass:mediaItemClass];
            break;
            
        default:
            return nil;
            break;
    }     
}

+ (NSArray*) itemsWithFeedType:(RSSFeedType)feedType xmlDocument:(ONOXMLDocument*)xmlDocument {
    return [self itemsWithFeedType:feedType xmlDocument:xmlDocument mediaItemClass:[RSSMediaItem class]];
}

@end
