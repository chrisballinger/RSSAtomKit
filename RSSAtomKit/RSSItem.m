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

@implementation RSSItem


- (instancetype) initWithFeedType:(RSSFeedType)feedType xmlElement:(ONOXMLElement*)xmlElement {
    if (self = [super init]) {
        _feedType = feedType;
        [self parseFeedFromElement:xmlElement];
    }
    return self;
}

- (void) parseFeedFromElement:(ONOXMLElement*)element {
    
    [self parseRSSFeedFromElement:element];
    
    if (self.feedType == RSSFeedTypeAtom) {
        [self parseAtomFeedFromElement:element];
    }
    
}

- (void) parseAtomFeedFromElement:(ONOXMLElement *)element
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
    
    NSArray *tempMediaItems = [self mediaItemsFromElement:element withXPath:[NSString stringWithFormat:@".//%@:link[@rel = 'enclosure' and @href",kRSSFeedAtomPrefix]];
    if ([tempMediaItems count]) {
        //Not sure if there's a feed out there with both but oh well we catch it
        _mediaItems = [tempMediaItems arrayByAddingObjectsFromArray:self.mediaItems];
    }
}

- (void) parseRSSFeedFromElement:(ONOXMLElement*)element {
    ONOXMLElement *titleElement = [element firstChildWithTag:@"title"];
    _title = [titleElement stringValue];
    ONOXMLElement *linkElement = [element firstChildWithTag:@"link"];
    NSString *linkString = [linkElement stringValue];
    if (linkString) {
        _linkURL = [NSURL URLWithString:linkString];
    }
    ONOXMLElement *descriptionElement = [element firstChildWithTag:@"description"];
    _itemDescription = [descriptionElement stringValue];
    ONOXMLElement *pubDateElement = [element firstChildWithTag:@"pubDate"];
    NSString *dateString = [pubDateElement stringValue];
    if ([dateString length]) {
        _publicationDate = [NSDate dateFromInternetDateTimeString:dateString formatHint:DateFormatHintRFC822];
    }
    
    
    // Media RSS
    ONOXMLElement *thumbnailElement = [element firstChildWithTag:@"thumbnail" inNamespace:@"media"];
    if (thumbnailElement) {
        _thumbnailURL = [self media_URLForElement:thumbnailElement];
        _thumbnailSize = [self media_sizeForElement:thumbnailElement];
    }
    
    NSArray *tempMediaItems = [self mediaItemsFromElement:element withXPath:@".//enclosure[@url]"];
    
    if ([tempMediaItems count]) {
        _mediaItems = tempMediaItems;
    }
}

- (NSArray *)mediaItemsFromElement:(ONOXMLElement *)element withXPath:(NSString *)xPath
{
    NSMutableArray *tempMediaItems = [NSMutableArray array];
    [element enumerateElementsWithXPath:xPath usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
        RSSMediaItem *item = [[RSSMediaItem alloc] initWithFeedType:self.feedType xmlElement:element];
        if (item) {
            [tempMediaItems addObject:item];
        }
    }];
    return tempMediaItems;
}


#pragma mark Static Methods

+ (NSArray*) parseRSSItemsWithXPath:(NSString*)XPath
                           feedType:(RSSFeedType)feedType
                           document:(ONOXMLDocument*)document {
    NSMutableArray *items = [NSMutableArray array];
    [document enumerateElementsWithXPath:XPath usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
        RSSItem *item = [[[self class] alloc] initWithFeedType:feedType xmlElement:element];
        [items addObject:item];
    }];
    return items;
}

+ (NSArray*) itemsWithFeedType:(RSSFeedType)feedType xmlDocument:(ONOXMLDocument*)xmlDocument {
    switch (feedType) {
        case RSSFeedTypeRSS:
            return [self parseRSSItemsWithXPath:@"/rss/channel/item" feedType:feedType document:xmlDocument];
            break;
        case RSSFeedTypeAtom:
            return [self parseRSSItemsWithXPath:[NSString stringWithFormat:@"/%@:feed/%@:entry",kRSSFeedAtomPrefix,kRSSFeedAtomPrefix] feedType:feedType document:xmlDocument];
            break;
        
        default:
            return nil;
            break;
    }
    return nil;
}

@end
