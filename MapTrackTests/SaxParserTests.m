//
//  SaxParserTests.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-11-02.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SaxKmlParser.h"

@interface SaxParserTests : XCTestCase<SaxKmlParserDelegate>



@end

@implementation SaxParserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSaxKmlParser {
    
    SaxKmlParser *parser=[[SaxKmlParser alloc] initWithDelegate:self];
    NSError *err=nil;
    NSString *kml=[NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"ok-mnt-places.kml" ofType:nil] encoding:NSUTF8StringEncoding error:&err];
    XCTAssertNil(err, @"kml file error");
    [parser parseString:kml];
    
    
    parser=[[SaxKmlParser alloc] initWithDelegate:self];
    err=nil;
    kml=[NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"ok-mnt-park.kml" ofType:nil] encoding:NSUTF8StringEncoding error:&err];
    XCTAssertNil(err, @"kml file error");
    [parser parseString:kml];
    
    parser=[[SaxKmlParser alloc] initWithDelegate:self];
    err=nil;
    kml=[NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"ok-mnt-wild-horse-canyon.kml" ofType:nil] encoding:NSUTF8StringEncoding error:&err];
    XCTAssertNil(err, @"kml file error");
    [parser parseString:kml];
    
}

-(void) onKmlPlacemark:(NSDictionary *)dictionary{
    NSLog(@"%@", dictionary);
    
    XCTAssertNotNil([dictionary objectForKey:@"coordinates"]);
    XCTAssertNotNil([dictionary objectForKey:@"name"]);
    XCTAssertNotNil([dictionary objectForKey:@"mapitemtype"]);
    XCTAssertNotNil([dictionary objectForKey:@"href"]);
    
    XCTAssertEqualObjects(@"marker", [dictionary objectForKey:@"mapitemtype"]);
    
    //dont let it start with #. resolve to icon!
    XCTAssertNotEqualObjects(@"#", [[dictionary objectForKey:@"href"] substringToIndex:1], @"%@",[dictionary objectForKey:@"href"]);
    
    
    if([[dictionary objectForKey:@"name"] isEqualToString:@"Lighthouse"]){
        XCTAssertEqualObjects(@"http://maps.google.com/mapfiles/kml/shapes/flag.png", [dictionary objectForKey:@"href"]);
    }
    
    if([[dictionary objectForKey:@"name"] isEqualToString:@"Landing Point"]){
        XCTAssertEqualObjects(@"http://maps.google.com/mapfiles/kml/shapes/picnic.png", [dictionary objectForKey:@"href"]);
    }
}

-(void) onKmlPolyline:(NSDictionary *)dictionary{
    NSLog(@"%@", dictionary);
}

-(void) onKmlPolygon:(NSDictionary *)dictionary{
    NSLog(@"%@", dictionary);
}

-(void) onKmlStyle:(NSDictionary *)dictionary{
    NSLog(@"%@", dictionary);
}

-(void) onKmlFolder:(NSDictionary *)dictionary{
    NSLog(@"%@", dictionary);
}

-(void) onKmlGroundOverlay:(NSDictionary *)dictionary{
    NSLog(@"%@", dictionary);
}



@end
