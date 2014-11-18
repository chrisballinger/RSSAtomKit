//
//  RSSAtomKitTests.m
//  RSSAtomKitTests
//
//  Created by Christopher Ballinger on 11/17/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "RSSAtomKit.h"
#import "Expecta.h"

@interface RSSAtomKitTests : XCTestCase
@property (nonatomic, strong) RSSAtomKit *atomKit;

@end

@implementation RSSAtomKitTests

- (void)setUp {
    [super setUp];
    self.atomKit = [[RSSAtomKit alloc] initWithSessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    [Expecta setAsynchronousTestTimeout:5];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNYTimesFeed {
    NSURL *nytimesURL = [NSURL URLWithString:@"http://www.nytimes.com/services/xml/rss/nyt/HomePage.xml"];
    __block RSSFeed *parsedFeed = nil;
    __block NSArray *parsedItems = nil;
    [self.atomKit parseFeedFromURL:nytimesURL completionBlock:^(RSSFeed *feed, NSArray *items, NSError *error) {
        if (error) {
            XCTFail(@"Error for %@: %@", nytimesURL, error);
            return;
        }
        NSLog(@"feed: %@ items: %@", feed, items);
        parsedFeed = feed;
        parsedItems = items;
    } completionQueue:nil];
    EXP_expect(parsedFeed).willNot.beNil();
    //EXP_expect(parsedItems).willNot.beNil();
}


@end
