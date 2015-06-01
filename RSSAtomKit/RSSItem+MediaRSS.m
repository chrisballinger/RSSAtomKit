//
//  RSSItem+MediaRSS.m
//  Pods
//
//  Created by Christopher Ballinger on 11/24/14.
//
//

#import "RSSItem+MediaRSS.h"

@implementation RSSItem (MediaRSS)

- (NSURL*) media_URLForElement:(ONOXMLElement*)element {
    NSString *urlString = [element valueForAttribute:@"url"];
    urlString  = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (CGSize) media_sizeForElement:(ONOXMLElement*)element {
    NSString *heightString = [element valueForAttribute:@"height"];
    NSString *widthString = [element valueForAttribute:@"width"];
    CGFloat height = [heightString floatValue];
    CGFloat width = [widthString floatValue];
    CGSize size = CGSizeMake(width, height);
    return size;
}

@end
