//
//  RSSFeed+Utilities.h
//  Pods
//
//  Created by Christopher Ballinger on 11/24/14.
//
//

#import "RSSFeed.h"

@interface RSSFeed (Utilities)

/**
 *  Returns the string value of the feedType ("RDF", "RSS", "Atom")
 */
+ (NSString*) stringForFeedType:(RSSFeedType)feedType;

@end
