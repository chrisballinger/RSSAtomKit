//
//  RSSAtomKitTests.m
//  RSSAtomKitTests
//
//  Created by Christopher Ballinger on 11/17/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RSSParser.h"
#import "RSSMediaItem.h"
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
    [self runTestOnFeedName:@"VOA" feedItems:20 expectedTotalMediaItems:19 hasDescription:YES];
}

/**
 *  http://www.theguardian.com/world/rss
 */
- (void)testGuardianWorldFeed {
    [self runTestOnFeedName:@"Guardian-World" feedItems:88 expectedTotalMediaItems:2 hasDescription:YES];
}

/**
 *  http://feeds.washingtonpost.com/rss/world
 */
- (void)testWashingtonPostWorldFeed {
    [self runTestOnFeedName:@"WashingtonPost-World" feedItems:25 expectedTotalMediaItems:0 hasDescription:YES];
}

/**
 *  http://www.nytimes.com/services/xml/rss/nyt/InternationalHome.xml
 */
- (void)testNYTimesInternationalFeed {
    [self runTestOnFeedName:@"NYTimes-International" feedItems:25 expectedTotalMediaItems:17 hasDescription:NO];
}

/**
 *  http://rss.cnn.com/rss/cnn_topstories.rss
 */
- (void)testCNNTopStoriesFeed {
    [self runTestOnFeedName:@"CNN-TopStories" feedItems:90 expectedTotalMediaItems:70 hasDescription:YES];
}

/**
 *  http://rss.cnn.com/rss/cnn_world.rss
 */
- (void)testCNNWorldFeed {
    [self runTestOnFeedName:@"CNN-World" feedItems:135 expectedTotalMediaItems:131 hasDescription:YES];
}

/**
 *  http://www.rfa.org/tibetan/RSS
 */
- (void)testRFATibetanFeed {
    [self runTestOnFeedName:@"RFA-tibetan" feedItems:15 expectedTotalMediaItems:0 hasDescription:YES];
}

/**
 *  http://techcrunch.com/feed/
 */
- (void)testTechcrunchFeed {
    [self runTestOnFeedName:@"techcrunch" feedItems:20 expectedTotalMediaItems:89 hasDescription:YES];
}

/**
 *  http://boingboing.net/feed
 */
- (void)testBoingBoingFeed {
    [self runTestOnFeedName:@"boinboing" feedItems:30 expectedTotalMediaItems:0 hasDescription:YES];
}

/**
 *  http://fivethirtyeight.com/features/feed/
 */
- (void)test538Feed {
    [self runTestOnFeedName:@"538" feedItems:20 expectedTotalMediaItems:88 hasDescription:YES];
}

#pragma - mark Atom Tests

/**
 *  http://googleblog.blogspot.com/
 */
- (void)testGoogleAtomFeed {
    [self runTestOnFeedName:@"google-atom" feedItems:25 expectedTotalMediaItems:0 hasDescription:YES];
}

/**
 *  http://7rmath4ro2of2a42.onion/index.atom
 *  https://soylentnews.org/index.atom
 */
- (void)testSoylentNewsAtomFeed {
    [self runTestOnFeedName:@"soylentNews-atom" feedItems:50 expectedTotalMediaItems:0 hasDescription:YES];
}

#pragma - mark RDF Tests

/**
 *  http://7rmath4ro2of2a42.onion/index.rss
 *  https://soylentnews.org/index.rss
 */
- (void)testSoylentNewsRDFFeed {
    [self runTestOnFeedName:@"soylentNews-rdf" feedItems:50 expectedTotalMediaItems:0 hasDescription:YES];
}

#pragma - mark OPML Tests

- (void)test1BasicOPML {
    [self runtOPMLTestForName:@"test_1" expectedFeeds:13];
}

- (void)test2BasicOPML {
    [self runtOPMLTestForName:@"test_2" expectedFeeds:6];
}

- (void)test3BasicOPML {
    [self runtOPMLTestForName:@"test_3" expectedFeeds:100];
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

- (void)runTestOnFeedName:(NSString*)feedName feedItems:(NSUInteger)expectedFeedItems expectedTotalMediaItems:(NSUInteger)expectedMediaItems hasDescription:(BOOL)hasDescription {
    NSData *feedData = [self dataForResource:feedName ofType:@"xml"];
    __block RSSFeed *parsedFeed = nil;
    __block NSArray *parsedItems = nil;
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"Feed - %@",feedName]];
    NSURL *url = [NSURL URLWithString:@"test@test.example"];
    [self.parser feedFromXMLData:feedData sourceURL:url completionBlock:^(RSSFeed *feed, NSArray *items, NSError *error) {
        if (error) {
            XCTFail(@"Error for %@: %@", feedName, error);
            return;
        }
        NSLog(@"Parsed %@ %@ feed with %lu items.", feedName, [RSSFeed stringForFeedType:feed.feedType], (unsigned long)items.count);
        parsedFeed = feed;
        parsedItems = items;
        
        XCTAssertTrue([parsedFeed.title length] > 0);
        XCTAssertTrue([parsedFeed.feedDescription length] > 0 == hasDescription);
        XCTAssertNotNil(parsedFeed.htmlURL);
        XCTAssertTrue([[parsedFeed.sourceURL absoluteString] length] > 0);
        if(parsedFeed.xmlURL) {
            NSLog(@"%@ - has self xmlUrl",parsedFeed.title);
        }
        __block NSUInteger foundMediaItems = 0;
        XCTAssertEqual([items count], expectedFeedItems, @"Did not find correct number of items");
        
        [items enumerateObjectsUsingBlock:^(RSSItem *item, NSUInteger idx, BOOL *stop) {
            XCTAssertTrue([item.title length] > 0);
            XCTAssertNotNil(item.publicationDate);
            XCTAssertTrue([item.itemDescription length] > 0);
            XCTAssertTrue([item.linkURL.absoluteString length] > 0,@"URL has no length");
            
            if (item.author) {
                XCTAssertTrue([item.author.email length] > 0);
            }
            
            [item.mediaItems enumerateObjectsUsingBlock:^(RSSMediaItem *mediaItem, NSUInteger idx, BOOL *stop) {
                foundMediaItems += 1;
                XCTAssertTrue([mediaItem.url absoluteString] > 0, @"Link has no length");
            }];
            NSLog(@"Parsed item from %@: %@", feedName, item.title);
        }];
        XCTAssertEqual(foundMediaItems, expectedMediaItems);
        [expectation fulfill];
    } completionQueue:nil];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error");
        }
    }];
}


@end
