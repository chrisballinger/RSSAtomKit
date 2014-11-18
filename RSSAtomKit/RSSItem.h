//
//  RSSItem.h
//  Pods
//
//  Created by Christopher Ballinger on 11/17/14.
//
//

#import "MTLModel.h"
#import "Ono.h"

@interface RSSItem : MTLModel

/**
 *  @warning This property will be removed.
 */
@property (nonatomic, strong, readonly) ONOXMLElement *xmlElement;

- (instancetype) initWithXMLElement:(ONOXMLElement*)xmlElement;

+ (NSArray*) itemsWithXMLDocument:(ONOXMLDocument*)xmlDocument;

@end
