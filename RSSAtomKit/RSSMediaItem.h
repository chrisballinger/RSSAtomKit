//
//  RSSMediaItem.h
//  Pods
//
//  Created by David Chiles on 1/20/15.
//
//

#import "MTLModel+NSCoding.h"
#import "RSSFeed.h"
@class ONOXMLElement;

@interface RSSMediaItem : MTLModel

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSString *type;
@property (nonatomic, readonly) NSUInteger length;

/**
 * An array of RSSMediaItem thumbnails ordered by importance
 * http://www.rssboard.org/media-rss#media-thumbnails
 */
@property (nonatomic, strong, readonly) NSArray *thumbnails;

- (instancetype) initWithURL:(NSURL *)url;

- (instancetype) initWithFeedType:(RSSFeedType)feedType xmlElement:(ONOXMLElement*)xmlElement;

@end
