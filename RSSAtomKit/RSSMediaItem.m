//
//  RSSMediaItem.m
//  Pods
//
//  Created by David Chiles on 1/20/15.
//
//

#import "RSSMediaItem.h"
#import "Ono.h"

@implementation RSSMediaItem

- (instancetype) initWithURL:(NSURL *)url
{
    if (self = [self init]) {
        _url = url;
    }
    return self;
}

- (instancetype) initWithFeedType:(RSSFeedType)feedType xmlElement:(ONOXMLElement*)xmlElement
{
    if (self = [self init]) {
        [self parseElement:xmlElement forType:feedType];
    }
    return self;
}

- (void)parseElement:(ONOXMLElement *)element forType:(RSSFeedType)feedType
{
    NSString *urlString = [element valueForAttribute:@"url"];
    if (![urlString length]) {
         urlString = [element valueForAttribute:@"href"];
    }
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _url = [NSURL URLWithString:urlString];
    
    _type = [element valueForAttribute:@"type"];
    
    NSString *lengthString = [element valueForAttribute:@"length"];
    if ([lengthString length]) {
        _length = [[element.document.numberFormatter numberFromString:lengthString] unsignedIntegerValue];
    }
    
    NSMutableArray *thumbnails = [[NSMutableArray alloc] init];
    [element enumerateElementsWithXPath:@".//media:thumbnail" usingBlock:^(ONOXMLElement *thumbnailElement, NSUInteger idx, BOOL *stop) {
        RSSMediaItem *thumbnail = [[RSSMediaItem alloc] initWithFeedType:feedType xmlElement:thumbnailElement];
        if (thumbnail) {
            [thumbnails addObject:thumbnail];
        }
    }];
    _thumbnails = thumbnails;
}

@end
