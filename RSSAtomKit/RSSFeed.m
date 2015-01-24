//
//  RSSFeed.m
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import "RSSFeed.h"

NSString *const kRSSFeedAtomPrefix = @"atom";
NSString *const kRSSFeedAtomNameSpace = @"http://www.w3.org/2005/Atom";

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
        [xmlDocument definePrefix:kRSSFeedAtomPrefix forDefaultNamespace:kRSSFeedAtomNameSpace];
        ONOXMLElement *titleElement = [root firstChildWithXPath:[NSString stringWithFormat:@"/%@:feed/%@:title",kRSSFeedAtomPrefix,kRSSFeedAtomPrefix]];
        _title = [titleElement stringValue];
        ONOXMLElement *subtitleElement = [root firstChildWithTag:@"subtitle"];
        _feedDescription = [subtitleElement stringValue];
        ONOXMLElement *linkElement = [root firstChildWithTag:@"link"];
        NSString *linkString = [linkElement valueForAttribute:@"href"];
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

- (void)parseOPMLOutlineElement:(ONOXMLElement *)element
{
    if ([element.tag isEqualToString:@"outline"]) {
        _title = [element valueForAttribute:@"title"];
        if (![self.title length]) {
            _title = [element valueForAttribute:@"text"];
        }
        _feedDescription = [element valueForAttribute:@"description"];
        NSString *xmlURLString = [element valueForAttribute:@"xmlUrl"];
        if ([xmlURLString length]) {
            _linkURL = [NSURL URLWithString:xmlURLString];
        }
        
    }
}

+ (NSArray *) feedsFromOPMLDocutment:(ONOXMLDocument*)xmlDocument error:(NSError**)error
{
    NSMutableArray *feeds = [NSMutableArray array];
    [xmlDocument enumerateElementsWithXPath:@"//outline[@xmlUrl]" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
        RSSFeed *feed = [[[self class] alloc] init];
        [feed parseOPMLOutlineElement:element];
        if (feed) {
            [feeds addObject:feed];
        }
    }];
    return feeds;
}


@end
