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

@import CoreGraphics.CGGeometry;

@interface RSSItem : MTLModel
    
@property (nonatomic, readonly) RSSFeedType feedType;

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *itemDescription;
@property (nonatomic, strong, readonly) NSDate *publicationDate;
@property (nonatomic, strong, readonly) NSURL *linkURL;

// Media RSS
@property (nonatomic, strong, readonly) NSURL *thumbnailURL;
@property (nonatomic, readonly) CGSize thumbnailSize;

- (instancetype) initWithFeedType:(RSSFeedType)feedType xmlElement:(ONOXMLElement*)xmlElement;

+ (NSArray*) itemsWithFeedType:(RSSFeedType)feedType xmlDocument:(ONOXMLDocument*)xmlDocument;

@end
