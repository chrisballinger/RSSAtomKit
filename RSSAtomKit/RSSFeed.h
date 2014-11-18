//
//  RSSFeed.h
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import "MTLModel.h"
#import "Ono.h"

@interface RSSFeed : MTLModel

/**
 *  @warning This property will be removed.
 */
@property (nonatomic, strong, readonly) ONOXMLDocument *xmlDocument;

- (instancetype) initWithXMLDocument:(ONOXMLDocument*)xmlDocument;

@end
