//
//  RSSAtomKitTests.m
//  RSSAtomKitTests
//
//  Created by Christopher Ballinger on 11/17/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "RSSParser.h"
#import "Expecta.h"
#import "RSSFeed+Utilities.h"

/**
 *  Runs tests on the following RSS feeds:
 *   * Voice of America
 *   * The Guardian - World News
 *   * The Washington Post - World News
 *   * The New York Times - International Home
 *   * CNN - Top Stories
 *   * CNN - World
 */
@interface RSSAtomKitTests : XCTestCase
@property (nonatomic, strong) RSSParser *parser;

@end

@implementation RSSAtomKitTests

- (void)setUp {
    [super setUp];
    self.parser = [[RSSParser alloc] init];
    [Expecta setAsynchronousTestTimeout:5];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/**
 *  http://www.voanews.com/api/epiqq
 */
- (void)testVoiceOfAmericaFeed {
    [self runTestOnFeedName:@"VOA"];
}

/**
 *  http://www.theguardian.com/world/rss
 */
- (void)testGuardianWorldFeed {
    [self runTestOnFeedName:@"Guardian-World"];
}

/**
 *  http://feeds.washingtonpost.com/rss/world
 */
- (void)testWashingtonPostWorldFeed {
    [self runTestOnFeedName:@"WashingtonPost-World"];
}

/**
 *  http://www.nytimes.com/services/xml/rss/nyt/InternationalHome.xml
 */
- (void)testNYTimesInternationalFeed {
    [self runTestOnFeedName:@"NYTimes-International"];
}

/**
 *  http://rss.cnn.com/rss/cnn_topstories.rss
 */
- (void)testCNNTopStoriesFeed {
    [self runTestOnFeedName:@"CNN-TopStories"];
}

/**
 *  http://rss.cnn.com/rss/cnn_world.rss
 */
- (void)testCNNWorldFeed {
    [self runTestOnFeedName:@"CNN-World"];
}

/**
 *  http://www.rfa.org/tibetan/RSS
 */
- (void)testRFATibetanFeed {
    [self runTestOnFeedName:@"RFA-tibetan"];
}

/**
 *  http://googleblog.blogspot.com/
 */
- (void)testGoogleAtomFeed {
    [self runTestOnFeedName:@"google-atom"];
}


- (void)runTestOnFeedName:(NSString*)feedName {
    NSString *feedPath = [[NSBundle bundleForClass:[self class]] pathForResource:feedName ofType:@"xml"];
    XCTAssertNotNil(feedPath);
    NSData *feedData = [NSData dataWithContentsOfFile:feedPath];
    XCTAssertNotNil(feedData);
    __block RSSFeed *parsedFeed = nil;
    __block NSArray *parsedItems = nil;
    [self.parser feedFromXMLData:feedData completionBlock:^(RSSFeed *feed, NSArray *items, NSError *error) {
        if (error) {
            XCTFail(@"Error for %@: %@", feedName, error);
            return;
        }
        NSLog(@"Parsed %@ %@ feed with %lu items.", feedName, [RSSFeed stringForFeedType:feed.feedType], (unsigned long)items.count);
        parsedFeed = feed;
        parsedItems = items;
        
        XCTAssertNotNil(parsedFeed.title);
        XCTAssertNotNil(parsedFeed.feedDescription);
        XCTAssertNotNil(parsedFeed.linkURL);
        [items enumerateObjectsUsingBlock:^(RSSItem *item, NSUInteger idx, BOOL *stop) {
            XCTAssertNotNil(item.title);
            XCTAssertNotNil(item.publicationDate);
            XCTAssertNotNil(item.itemDescription);
            XCTAssertNotNil(item.linkURL);
            NSLog(@"Parsed item from %@: %@", feedName, item.title);
        }];
    } completionQueue:nil];
    EXP_expect(parsedFeed).willNot.beNil();
    EXP_expect(parsedItems).willNot.beNil();
}


@end
