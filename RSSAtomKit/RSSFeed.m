//
//  RSSFeed.m
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import "RSSFeed.h"

@implementation RSSFeed

- (instancetype) initWithXMLDocument:(ONOXMLDocument*)xmlDocument {
    if (self = [super init]) {
        _xmlDocument = xmlDocument;
    }
    return self;
}

@end
