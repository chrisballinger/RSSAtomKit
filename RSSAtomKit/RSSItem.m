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
    _title = [self titleFromElement:element];
    _publicationDate = [self publicationDateFromElement:element];
    _linkURL = [self linkURLFromElement:element];
    _itemDescription = [self itemDescriptionFromElement:element];
    _author = [self authorFromElement:element];
    
    ONOXMLElement *thumbnailElement = [element firstChildWithTag:@"thumbnail" inNamespace:@"media"];
    if (thumbnailElement) {
        _thumbnailURL = [self media_URLForElement:thumbnailElement];
        _thumbnailSize = [self media_sizeForElement:thumbnailElement];
    }
}

- (NSDate *)publicationDateFromElement:(ONOXMLElement *)element
{
    ONOXMLElement *dateElement = nil;
    NSString *dateString = nil;
    
    //RSS
    dateElement = [element firstChildWithTag:@"pubDate"];
    dateString = [dateElement stringValue];
    if ([dateString length]) {
        return [NSDate dateFromInternetDateTimeString:dateString formatHint:DateFormatHintRFC822];
    }
    
    //RDF
    dateElement = [element firstChildWithTag:@"date"];
    dateString = [dateElement stringValue];
    if ([dateString length]) {
        return [NSDate dateFromInternetDateTimeString:dateString formatHint:DateFormatHintRFC3339];
    }
    
    //Atom
    dateElement = [element firstChildWithTag:@"updated"];
    if (!dateElement) {
        dateElement = [element firstChildWithTag:@"published"];
    }
    dateString = [dateElement stringValue];
    if ([dateString length]) {
        return [NSDate dateFromInternetDateTimeString:dateString formatHint:DateFormatHintRFC3339];
    }
    
    return nil;
}

- (NSURL *)linkURLFromElement:(ONOXMLElement *)element
{
    //Picks up on both Atom and RSS methods for links <link> and <atom:link> prefer rss way
    __block NSString *stringURL = nil;
    
    
    NSString* (^linkExtractorBlock)(ONOXMLElement *) = ^NSString *(ONOXMLElement *linkElement) {
        NSString *string = [[linkElement stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([string length]) {
            return string;
        }
        
        return [linkElement valueForAttribute:@"href"];
        
    };
    
    NSArray *links = [element childrenWithTag:@"link"];
    if ([links count] == 1) {
        stringURL = linkExtractorBlock([links firstObject]);
    }
    
    [links enumerateObjectsUsingBlock:^(ONOXMLElement *linkElement, NSUInteger idx, BOOL *stop) {
        if (![[linkElement valueForAttribute:@"rel"] isEqualToString:@"self"]) {
            stringURL = linkExtractorBlock(linkElement);
            *stop = YES;
        }
        
    }];
    
    if ([stringURL length]) {
        stringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return [NSURL URLWithString:stringURL];
    }
    return nil;
}

- (NSString *)itemDescriptionFromElement:(ONOXMLElement *)element
{
    NSString *itemDescription = nil;
    ONOXMLElement *descriptionElement = [element firstChildWithTag:@"description"];
    itemDescription = [descriptionElement stringValue];
    
    if (![itemDescription length]) {
        NSString *xPath = [NSString stringWithFormat:@".//%@:content | .//%@:summary",kRSSFeedAtomPrefix,kRSSFeedAtomPrefix];
        ONOXMLElement *contentElement = [element firstChildWithXPath:xPath];
        itemDescription = [contentElement stringValue];
    }
    
    
    return itemDescription;
}

- (NSString *)titleFromElement:(ONOXMLElement *)element
{
    ONOXMLElement *titleElement = [element firstChildWithTag:@"title"];
    return [titleElement stringValue];
}

- (RSSPerson *)authorFromElement:(ONOXMLElement *)element
{
    ONOXMLElement *authorElement = [element firstChildWithXPath:@"./author"];
    if (!authorElement) {
        authorElement = [element firstChildWithXPath:[NSString stringWithFormat:@"./%@:author",kRSSFeedAtomPrefix]];
    }
    
    if (!authorElement) {
        authorElement = element;
    }
    
    if (authorElement) {
        return [[RSSPerson alloc] initWithXMLElement:authorElement];
    }
    return nil;
}

- (void) parseAtomFeedFromElement:(ONOXMLElement *)element mediaItemClass:(Class)mediaItemClass
{
    NSArray *tempMediaItems = [self mediaItemsFromElement:element withXPath:[NSString stringWithFormat:@".//%@:link[@rel = 'enclosure' and @href",kRSSFeedAtomPrefix] mediaItemClass:(Class)mediaItemClass];
    if ([tempMediaItems count]) {
        //Not sure if there's a feed out there with both but oh well we catch it
        _mediaItems = [tempMediaItems arrayByAddingObjectsFromArray:self.mediaItems];
    }
}

- (void) parseRSSFeedFromElement:(ONOXMLElement*)element mediaItemClass:(Class)mediaItemClass
{
    //These have to happen with seperate XPath searches because some documents don't contain the media prefix and would error on the whole XPath otherwise
    NSArray *tempMediaItems = [self mediaItemsFromElement:element withXPath:@".//enclosure[@url]" mediaItemClass:(Class)mediaItemClass];
    if (!tempMediaItems) {
        tempMediaItems = @[];
    }
    tempMediaItems = [tempMediaItems arrayByAddingObjectsFromArray:[self mediaItemsFromElement:element withXPath:@".//media:content" mediaItemClass:mediaItemClass]];
    
    if ([tempMediaItems count]) {
        _mediaItems = tempMediaItems;
    }
}

- (NSArray *)mediaItemsFromElement:(ONOXMLElement *)element withXPath:(NSString *)xPath mediaItemClass:(Class)mediaItemClass
{
    NSMutableArray *tempMediaItems = [NSMutableArray array];
    [element enumerateElementsWithXPath:xPath usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
        RSSMediaItem *item = [[mediaItemClass alloc] initWithFeedType:self.feedType xmlElement:element];
        if ([item.url.absoluteString length] || [item.thumbnails count]) {
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
        case RSSFeedTypeRDF:
            return [self parseRSSItemsWithXPath:[NSString stringWithFormat:@"/rdf:RDF/%@:item",kRSSFeedRSSPrefix] feedType:feedType document:xmlDocument mediaItemClass:mediaItemClass];
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
