//
//  RSSPerson.m
//  Pods
//
//  Created by David Chiles on 1/21/15.
//
//

#import "RSSPerson.h"
#import "Ono.h"

@implementation RSSPerson

- (instancetype) initWithXMLElement:(ONOXMLElement *)xmlElement
{
    if (self = [self init]) {
        [self parseElement:xmlElement];
    }
    return self;
}

- (void)parseElement:(ONOXMLElement *)element
{
    //Atom method
    _name = [[element firstChildWithXPath:[NSString stringWithFormat:@"./%@:name",kRSSFeedAtomPrefix]] stringValue];
    _email = [[element firstChildWithXPath:[NSString stringWithFormat:@"./%@:email",kRSSFeedAtomPrefix]] stringValue];
    NSString *urlString = [[element firstChildWithXPath:[NSString stringWithFormat:@"./%@:uri",kRSSFeedAtomPrefix]] stringValue];
    if ([urlString length]) {
        _URL = [NSURL URLWithString:urlString];
    }
    
    //fallback to rss method
    if (![self.email length]) {
        _email = [element stringValue];
    }
    
    //Dublin Core standard
    if  (!self.name.length) {
        _name = [[element firstChildWithXPath:[NSString stringWithFormat:@"./%@:creator",kRSSfeedDublinCorePrefix]] stringValue];
    }
}

@end
