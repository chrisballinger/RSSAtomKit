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

NSString *const kRSSFeedRSSPrefix = @"rss1";
NSString *const kRSSFeedRSSNameSpace = @"http://purl.org/rss/1.0/";

NSString *const kRSSfeedDublinCorePrefix = @"dc";
NSString *const kRSSFeedDublinCoreNameSpace = @"http://purl.org/dc/elements/1.1/";

@implementation RSSFeed

- (instancetype) initWithXMLDocument:(ONOXMLDocument*)xmlDocument sourceURL:(NSURL *)sourceURL error:(NSError**)error {
    if (self = [super init]) {
        NSError *parseError = nil;
        [self parseXMLDocument:xmlDocument error:&parseError];
        _sourceURL = sourceURL;
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
    
    ONOXMLElement *channel = nil;
    if ( [rootTag isEqualToString:@"feed"] ) {
        channel = root;
        _feedType = RSSFeedTypeAtom;
        [xmlDocument definePrefix:kRSSFeedAtomPrefix forDefaultNamespace:kRSSFeedAtomNameSpace];
    } else {
        channel = [root firstChildWithTag:@"channel"];
        
        [xmlDocument definePrefix:kRSSfeedDublinCorePrefix forDefaultNamespace:kRSSFeedDublinCoreNameSpace];
        
        if([root.tag isEqualToString:@"RDF"]) {
            [xmlDocument definePrefix:kRSSFeedRSSPrefix forDefaultNamespace:kRSSFeedRSSNameSpace];
            _feedType = RSSFeedTypeRDF;
        } else {
            _feedType = RSSFeedTypeRSS;
        }
    }
    
    if (!channel) {
        if (!*error) {
            *error = [NSError errorWithDomain:@"RSSAtomKit" code:101 userInfo:@{NSLocalizedDescriptionKey: @"Invalid feed."}];
        }
        return;
    }
    
    
    _title = [self titleFromChannelOrFeedElement:channel];
    _htmlURL = [self htmlURLFromChannelOrFeedElement:channel];
    _feedDescription = [self descriptionFromChannelOrFeedElement:channel];
    _xmlURL = [self xmlURLFromChannelOrFeedElement:channel];
}



- (NSString *)descriptionFromChannelOrFeedElement:(ONOXMLElement *)channelElement
{
    NSString *feedDescription = nil;
    
    ONOXMLElement *descriptionElement = [channelElement firstChildWithTag:@"description"];
    feedDescription = [descriptionElement stringValue];
    
    if (![feedDescription length]) {
        ONOXMLElement *subtitleElement = [channelElement firstChildWithTag:@"subtitle"];
        feedDescription = [subtitleElement stringValue];
    }
    
    
    return feedDescription;
}

- (NSString *)titleFromChannelOrFeedElement:(ONOXMLElement *)channelElement
{
    NSString *title = nil;
    
    ONOXMLElement *titleElement = [channelElement firstChildWithTag:@"title"];
    title = [titleElement stringValue];
    if (![title length]) {
        ONOXMLElement *titleElement = [channelElement firstChildWithXPath:[NSString stringWithFormat:@"/%@:feed/%@:title",kRSSFeedAtomPrefix,kRSSFeedAtomPrefix]];
        title = [titleElement stringValue];
    }
    
    return title;
}

- (NSURL *)xmlURLFromChannelOrFeedElement:(ONOXMLElement *)channelElement
{
    //Try on all feeds because many rss feeds have atom inside
    ONOXMLElement *selfLinkElement = [channelElement firstChildWithXPath:@"./*[contains(local-name(), 'link')][@rel = 'self' and @type = 'application/rss+xml' and @href]"];
    
    NSString *xmlLInkString = [selfLinkElement valueForAttribute:@"href"];
    if ([xmlLInkString length]) {
        xmlLInkString = [xmlLInkString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
         return [NSURL URLWithString:xmlLInkString];
    }
    return nil;
}

- (NSURL *)htmlURLFromChannelOrFeedElement:(ONOXMLElement *)channelElement
{
    
    __block NSString *urlString = nil;
    [channelElement enumerateElementsWithXPath:@"./*[contains(local-name(), 'link')]" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
        
        //Normal RSS method
        urlString = [element stringValue];
        if ([urlString length]) {
            *stop = YES;
        } else if (![[element valueForAttribute:@"rel"] isEqualToString:@"self"]) {
            urlString = [element valueForAttribute:@"href"];
            *stop = YES;
        }
    }];
    
    
    
    if([urlString length]) {
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return [NSURL URLWithString:urlString];
    }
    return nil;
}

- (void)parseOPMLOutlineElement:(ONOXMLElement *)element
{
    if ([element.tag isEqualToString:@"outline"]) {
        _title = [element valueForAttribute:@"title"];
        if (![self.title length]) {
            _title = [element valueForAttribute:@"text"];
        }
        _feedDescription = [element valueForAttribute:@"description"];
        if (_feedDescription == nil)
            _feedDescription = @"";
        NSString *xmlURLString = [element valueForAttribute:@"xmlUrl"];
        if ([xmlURLString length]) {
            xmlURLString = [xmlURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            _xmlURL = [NSURL URLWithString:xmlURLString];
        }
        
        NSString *htmlURLString = [element valueForAttribute:@"htmlUrl"];
        if (htmlURLString) {
            htmlURLString = [htmlURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            _htmlURL = [NSURL URLWithString:htmlURLString];
        }
        if (_feedCategory == nil)
            _feedCategory = @"";
    }
}

- (void) setFeedCategory:(NSString *)feedCategory
{
    _feedCategory = feedCategory;
}

+ (NSArray *) feedsFromOPMLDocument:(ONOXMLDocument *)xmlDocument
                              error:(NSError **)error
{
    NSMutableArray *feeds = [NSMutableArray array];
    [xmlDocument enumerateElementsWithXPath:@"//outline[not(parent::outline)]" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
        if ([element valueForAttribute:@"xmlUrl"] != nil)
        {
            RSSFeed *feed = [[[self class] alloc] init];
            [feed parseOPMLOutlineElement:element];
            if (feed) {
                [feeds addObject:feed];
            }
        }
        else
        {
            // Top level outline. Pick up the category from this.
            NSString *category = [element valueForAttribute:@"text"];
            
            [element enumerateElementsWithXPath:@".//outline[@xmlUrl]" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
                RSSFeed *feed = [[[self class] alloc] init];
                [feed setFeedCategory:category];
                [feed parseOPMLOutlineElement:element];
                if (feed) {
                    [feeds addObject:feed];
                }
            }];
        }
    }];
    return feeds;
}


@end
