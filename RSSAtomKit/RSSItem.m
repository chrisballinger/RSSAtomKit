//
//  RSSItem.m
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import "RSSItem.h"

@implementation RSSItem

- (instancetype) initWithXMLElement:(ONOXMLElement*)xmlElement {
    if (self = [super init]) {
        _xmlElement = xmlElement;
    }
    return self;
}

+ (NSArray*) itemsWithXMLDocument:(ONOXMLDocument*)xmlDocument {
    return nil;
}

@end
