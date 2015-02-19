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
#import "RSSMediaItem.h"
#import "Expecta.h"
#import "RSSFeed+Utilities.h"
#import "RSSPerson.h"

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


#pragma - mark RSS Tests
/**
 *  http://www.voanews.com/api/epiqq
 */
- (void)testVoiceOfAmericaFeed {
    [self runTestOnFeedName:@"VOA" expectedMediaItems:19];
}

/**
 *  http://www.theguardian.com/world/rss
 */
- (void)testGuardianWorldFeed {
    [self runTestOnFeedName:@"Guardian-World" expectedMediaItems:2];
}

/**
 *  http://feeds.washingtonpost.com/rss/world
 */
- (void)testWashingtonPostWorldFeed {
    [self runTestOnFeedName:@"WashingtonPost-World" expectedMediaItems:0];
}

/**
 *  http://www.nytimes.com/services/xml/rss/nyt/InternationalHome.xml
 */
- (void)testNYTimesInternationalFeed {
    [self runTestOnFeedName:@"NYTimes-International" expectedMediaItems:17];
}

/**
 *  http://rss.cnn.com/rss/cnn_topstories.rss
 */
- (void)testCNNTopStoriesFeed {
    [self runTestOnFeedName:@"CNN-TopStories" expectedMediaItems:70];
}

/**
 *  http://rss.cnn.com/rss/cnn_world.rss
 */
- (void)testCNNWorldFeed {
    [self runTestOnFeedName:@"CNN-World" expectedMediaItems:131];
}

/**
 *  http://www.rfa.org/tibetan/RSS
 */
- (void)testRFATibetanFeed {
    [self runTestOnFeedName:@"RFA-tibetan" expectedMediaItems:0];
}

#pragma - mark Atom Tests

/**
 *  http://googleblog.blogspot.com/
 */
- (void)testGoogleAtomFeed {
    [self runTestOnFeedName:@"google-atom" expectedMediaItems:0];
}

#pragma - mark OPML Tests

- (void)test1BasicOPML {
    [self runtOPMLTestForName:@"test_1" expectedFeeds:13];
}

- (void)test2BasicOPML {
    [self runtOPMLTestForName:@"test_2" expectedFeeds:6];
}

- (void)testSearchOPML {
    [self runtOPMLTestForName:@"search" expectedFeeds:19];
}

#pragma - mark Utility Methods

- (NSData *)dataForResource:(NSString *)name ofType:(NSString *)type
{
    NSString *feedPath = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:type];
    XCTAssertNotNil(feedPath);
    NSData *feedData = [NSData dataWithContentsOfFile:feedPath];
    XCTAssertNotNil(feedData);
    return feedData;
}

- (void)runtOPMLTestForName:(NSString *)name expectedFeeds:(NSUInteger)numberOfFeeds
{
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"OPML - %@",name]];
    NSData *opmlData = [self dataForResource:name ofType:@"opml"];
    [self.parser feedsFromOPMLData:opmlData completionBlock:^(NSArray *feeds, NSError *error) {
        XCTAssertNotNil(feeds);
        XCTAssertGreaterThan([feeds count], 0, @"No feeds found");
        XCTAssertEqual([feeds count], numberOfFeeds, @"Did not find all the feeds");
        XCTAssertNil(error);
        
        [feeds enumerateObjectsUsingBlock:^(RSSFeed *feed, NSUInteger idx, BOOL *stop) {
            XCTAssertNotNil(feed.title);
            XCTAssertNotNil(feed.xmlURL);
        }];
        
        [expectation fulfill];
    } completionQueue:nil];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)runTestOnFeedName:(NSString*)feedName expectedMediaItems:(NSUInteger)expectedMediaItems {
    NSData *feedData = [self dataForResource:feedName ofType:@"xml"];
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
        XCTAssertNotNil(parsedFeed.htmlURL);
        if(parsedFeed.xmlURL) {
            NSLog(@"%@ - has self xmlUrl",parsedFeed.title);
        }
        __block NSUInteger foundMediaItems = 0;
        [items enumerateObjectsUsingBlock:^(RSSItem *item, NSUInteger idx, BOOL *stop) {
            XCTAssertNotNil(item.title);
            XCTAssertNotNil(item.publicationDate);
            XCTAssertNotNil(item.itemDescription);
            XCTAssertNotNil(item.linkURL);
            
            if (item.author) {
                XCTAssertNotNil(item.author.email);
            }
            
            [item.mediaItems enumerateObjectsUsingBlock:^(RSSMediaItem *mediaItem, NSUInteger idx, BOOL *stop) {
                foundMediaItems += 1;
                XCTAssertNotNil(mediaItem.url);
            }];
            NSLog(@"Parsed item from %@: %@", feedName, item.title);
        }];
        XCTAssertEqual(foundMediaItems, expectedMediaItems);
    } completionQueue:nil];
    EXP_expect(parsedFeed).willNot.beNil();
    EXP_expect(parsedItems).willNot.beNil();
}


@end
