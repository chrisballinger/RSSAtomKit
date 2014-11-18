//
//  RSSFeed.h
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import "MTLModel.h"
#import "Ono.h"

typedef NS_ENUM(NSInteger, RSSFeedType) {
    RSSFeedTypeRDF, // RDF / RSS 1.0
    RSSFeedTypeRSS, // RSS 2.0
    RSSFeedTypeAtom
};

@interface RSSFeed : MTLModel

@property (nonatomic, readonly) RSSFeedType feedType;

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSURL *linkURL;
@property (nonatomic, strong, readonly) NSString *feedDescription;

/**
 *  @warning This property will be removed.
 */
@property (nonatomic, strong, readonly) ONOXMLDocument *xmlDocument;

- (instancetype) initWithXMLDocument:(ONOXMLDocument*)xmlDocument error:(NSError**)error;

@end
