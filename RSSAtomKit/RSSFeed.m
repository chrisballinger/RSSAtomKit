//
//  RSSFeed.m
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import "RSSFeed.h"

@implementation RSSFeed

- (instancetype) initWithXMLDocument:(ONOXMLDocument*)xmlDocument error:(NSError**)error {
    if (self = [super init]) {
        NSError *parseError = nil;
        [self parseXMLDocument:xmlDocument error:&parseError];
        if (parseError) {
            if (*error) {
                *error = parseError;
            }
            return nil;
        }
    }
    return self;
}

- (void) parseXMLDocument:(ONOXMLDocument*)xmlDocument error:(NSError**)error {
    // Determine feed type
    ONOXMLElement *root = xmlDocument.rootElement;
    NSString *rootTag = root.tag;
    
    //Try RSS way first
    ONOXMLElement *channel = [root firstChildWithTag:@"channel"];
    if (channel) {
        ONOXMLElement *titleElement = [channel firstChildWithTag:@"title"];
        _title = [titleElement stringValue];
        ONOXMLElement *linkElement = [channel firstChildWithTag:@"link"];
        NSString *linkString = [linkElement stringValue];
        _linkURL = [NSURL URLWithString:linkString];
        ONOXMLElement *descriptionElement = [channel firstChildWithTag:@"description"];
        _feedDescription = [descriptionElement stringValue];
        _feedType = RSSFeedTypeRSS;
    }
    else if ([rootTag isEqualToString:@"feed"]) {
        ONOXMLElement *titleElement = [root firstChildWithXPath:@"/feed/title"];
        _title = [titleElement stringValue];
        ONOXMLElement *subtitleElement = [root firstChildWithXPath:@"/feed/subtitle"];
        _feedDescription = [subtitleElement stringValue];
        ONOXMLElement *linkElement = [root firstChildWithXPath:@"/feed/link"];
        NSString *linkString = [linkElement stringValue];
        _linkURL = [NSURL URLWithString:linkString];
        _feedType = RSSFeedTypeAtom;
    }
    else {
        if (!*error) {
            *error = [NSError errorWithDomain:@"RSSAtomKit" code:101 userInfo:@{NSLocalizedDescriptionKey: @"Invalid feed."}];
        }
        return;
    }
}


@end
