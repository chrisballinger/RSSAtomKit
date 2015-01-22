//
//  RSSPerson.h
//  Pods
//
//  Created by David Chiles on 1/21/15.
//
//

#import "MTLModel.h"
#import "RSSFeed.h"

@class ONOXMLElement;

@interface RSSPerson : MTLModel

/**
 The person's email address supported by RSS 2.0 and Atom
 Atom: https://tools.ietf.org/html/rfc4287#section-4.2.1
 RSS: http://validator.w3.org/feed/docs/rss2.html
 */
@property (nonatomic, strong, readonly) NSString *email;

/**
 The name of the person. Only supported by Atom
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 The URL to the person, normally a profile
 */
@property (nonatomic, strong, readonly) NSURL *URL;


- (instancetype) initWithXMLElement:(ONOXMLElement*)xmlElement;

@end
