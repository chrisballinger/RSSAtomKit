//
//  RSSFeed.h
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import "MTLModel.h"
#import "Ono.h"

typedef NS_ENUM(NSUInteger, RSSFeedType) {
    RSSFeedTypeUnknown, // Parse Error
    RSSFeedTypeRDF, // RDF / RSS 1.0
    RSSFeedTypeRSS, // RSS 2.0
    RSSFeedTypeAtom // Atom 1.0
};

extern NSString *const kRSSFeedAtomPrefix;
extern NSString *const kRSSFeedAtomNameSpace;

@interface RSSFeed : MTLModel

@property (nonatomic, readonly) RSSFeedType feedType;

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSURL *linkURL;
@property (nonatomic, strong, readonly) NSString *feedDescription;

- (instancetype) initWithXMLDocument:(ONOXMLDocument*)xmlDocument error:(NSError**)error;

+ (NSArray *) feedsFromOPMLDocutment:(ONOXMLDocument*)xmlDocument error:(NSError**)error;

@end
