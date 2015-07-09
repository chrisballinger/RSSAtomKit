# RSSAtomKit

[![CI Status](http://img.shields.io/travis/chrisballinger/RSSAtomKit.svg?style=flat)](https://travis-ci.org/chrisballinger/RSSAtomKit)
[![Version](https://img.shields.io/cocoapods/v/RSSAtomKit.svg?style=flat)](http://cocoadocs.org/docsets/RSSAtomKit)
[![License](https://img.shields.io/cocoapods/l/RSSAtomKit.svg?style=flat)](http://cocoadocs.org/docsets/RSSAtomKit)
[![Platform](https://img.shields.io/cocoapods/p/RSSAtomKit.svg?style=flat)](http://cocoadocs.org/docsets/RSSAtomKit)

Customizable Obj-C RSS/Atom feed fetcher and parser.

## Installation

RSSAtomKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RSSAtomKit', :git => 'https://github.com/chrisballinger/RSSAtomKit.git'
```
    
## Usage

You can pass in a custom `NSURLSessionConfiguration` to the built-in fetcher.

```obj-c
RSSAtomKit *atomKit = [[RSSAtomKit alloc] initWithSessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
NSURL *nytimesURL = [NSURL URLWithString:@"http://www.nytimes.com/services/xml/rss/nyt/HomePage.xml"];
[self.atomKit parseFeedFromURL:nytimesURL completionBlock:^(RSSFeed *feed, NSArray *items, NSError *error) {
   if (error) {
       NSLog(@"Error for %@: %@", nytimesURL, error);
       return;
   }
   NSLog(@"feed: %@ items: %@", feed, items);
} completionQueue:nil];
```

If you prefer, you can also fetch on your own and parse raw `NSData` separately using `RSSParser`'s `feedFromXMLData:completionBlock:completionQueue:` method. Additionally, you can provide application-specific subclasses of `RSSItem` and `RSSFeed` via the `registerItemClass:` and `registerFeedClass:` methods.

## Authors

* [Chris Ballinger](https://github.com/chrisballinger)
* [David Chiles](https://github.com/davidchiles)
* [N-Pex](https://github.com/n-pex)

## License

RSSAtomKit is available under the MIT license. See the LICENSE file for more info.

