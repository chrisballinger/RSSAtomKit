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
        _xmlDocument = xmlDocument;
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
    if ([rootTag isEqualToString:@"rss"]) {
        _feedType = RSSFeedTypeRSS;
        ONOXMLElement *channel = [root firstChildWithTag:@"channel"];
        ONOXMLElement *titleElement = [channel firstChildWithTag:@"title"];
        _title = [titleElement stringValue];
        ONOXMLElement *linkElement = [root firstChildWithXPath:@"/rss/channel/link"];
        NSString *linkString = [linkElement stringValue];
        _linkURL = [NSURL URLWithString:linkString];
        ONOXMLElement *descriptionElement = [channel firstChildWithTag:@"description"];
        _feedDescription = [descriptionElement stringValue];
    } else if ([rootTag isEqualToString:@"rdf:RDF"]) {
        _feedType = RSSFeedTypeRDF;
    } else if ([rootTag isEqualToString:@"feed"]) {
        _feedType = RSSFeedTypeAtom;
        ONOXMLElement *titleElement = [root firstChildWithXPath:@"/feed/title"];
        _title = [titleElement stringValue];
        ONOXMLElement *subtitleElement = [root firstChildWithXPath:@"/feed/subtitle"];
        _feedDescription = [subtitleElement stringValue];
        ONOXMLElement *linkElement = [root firstChildWithXPath:@"/feed/link"];
        NSString *linkString = [linkElement stringValue];
        _linkURL = [NSURL URLWithString:linkString];
    } else {
        if (*error) {
            *error = [NSError errorWithDomain:@"RSSAtomKit" code:101 userInfo:@{NSLocalizedDescriptionKey: @"Invalid feed."}];
        }
        return;
    }
}


@end
