//
//  RSSItem.h
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import "MTLModel.h"
#import "RSSFeed.h"
#import "Ono.h"

@interface RSSItem : MTLModel

@property (nonatomic, readonly) RSSFeedType feedType;

/**
 *  @warning This property will be removed.
 */
@property (nonatomic, strong, readonly) ONOXMLElement *xmlElement;

- (instancetype) initWithFeedType:(RSSFeedType)feedType xmlElement:(ONOXMLElement*)xmlElement;

+ (NSArray*) itemsWithFeedType:(RSSFeedType)feedType xmlDocument:(ONOXMLDocument*)xmlDocument;

@end
