//
//  RSSItem+MediaRSS.h
//  Pods
//
//  Created by Christopher Ballinger on 11/24/14.
//
//

#import "RSSItem.h"

@interface RSSItem (MediaRSS)

- (NSURL*) media_URLForElement:(ONOXMLElement*)element;
- (CGSize) media_sizeForElement:(ONOXMLElement*)element;

@end
