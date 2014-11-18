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

+ (NSArray*) itemsWithFeedType:(RSSFeedType)feedType xmlDocument:(ONOXMLDocument*)xmlDocument {
    return nil;
}

@end
