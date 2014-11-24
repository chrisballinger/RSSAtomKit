//
//  RSSItem.m
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import "RSSItem.h"

@implementation RSSItem


- (instancetype) initWithFeedType:(RSSFeedType)feedType xmlElement:(ONOXMLElement*)xmlElement {
    if (self = [super init]) {
        _feedType = feedType;
        _xmlElement = xmlElement;
    }
    return self;
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
