//
//  RSSFeed+Utilities.m
//  Pods
//
//  Created by Christopher Ballinger on 11/24/14.
//
//

#import "RSSFeed+Utilities.h"

@implementation RSSFeed (Utilities)

+ (NSString*) stringForFeedType:(RSSFeedType)feedType {
    switch (feedType) {
        case RSSFeedTypeAtom:
            return @"Atom";
            break;
        case RSSFeedTypeRDF:
            return @"RDF";
            break;
        case RSSFeedTypeRSS:
            return @"RSS";
            break;
        case RSSFeedTypeUnknown:
            return nil;
            break;
    }
    return nil;
}

@end
