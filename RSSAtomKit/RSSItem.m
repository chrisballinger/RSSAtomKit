//
//  RSSItem.m
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import "RSSItem.h"
#import "RSSItem+MediaRSS.h"

@implementation RSSItem


- (instancetype) initWithFeedType:(RSSFeedType)feedType xmlElement:(ONOXMLElement*)xmlElement {
    if (self = [super init]) {
        _feedType = feedType;
        _xmlElement = xmlElement;
        [self parseFeedFromElement:xmlElement];
    }
    return self;
}

- (void) parseFeedFromElement:(ONOXMLElement*)element {
    switch (_feedType) {
        case RSSFeedTypeRSS:
            [self parseRSSFeedFromElement:element];
            break;
        default:
            NSAssert(NO, @"Feed type currently unsupported.");
            break;
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
    _publicationDate = [pubDateElement dateValue];
    
    // Media RSS
    ONOXMLElement *thumbnailElement = [element firstChildWithTag:@"thumbnail" inNamespace:@"media"];
    if (thumbnailElement) {
        _thumbnailURL = [self media_URLForElement:thumbnailElement];
        _thumbnailSize = [self media_sizeForElement:thumbnailElement];
    }
}



#pragma mark Static Methods

+ (NSArray*) parseRSSItemsWithXPath:(NSString*)XPath
                           feedType:(RSSFeedType)feedType
                           document:(ONOXMLDocument*)document {
    NSMutableArray *items = [NSMutableArray array];
    [document enumerateElementsWithXPath:XPath usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
        RSSItem *item = [[RSSItem alloc] initWithFeedType:feedType xmlElement:element];
        [items addObject:item];
    }];
    return items;
}

+ (NSArray*) itemsWithFeedType:(RSSFeedType)feedType xmlDocument:(ONOXMLDocument*)xmlDocument {
    switch (feedType) {
        case RSSFeedTypeRSS:
            return [self parseRSSItemsWithXPath:@"/rss/channel/item" feedType:feedType document:xmlDocument];
            break;
        default:
            return nil;
            break;
    }
    return nil;
}

@end
