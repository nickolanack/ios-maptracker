//
//  MKUserTrackerTests.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-11-03.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MKUserTracker.h"
#import "MockCLLocationManager.h"

@interface MKUserTrackerTests : XCTestCase

@end

@implementation MKUserTrackerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testUserTracker {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    
    MKUserTracker *tracker=[[MKUserTracker alloc] init]; //do not init with map for testing
    MockCLLocationManager *mock=[[MockCLLocationManager alloc] init];
    [mock setLocationManagerDelegate:tracker];
    [mock setLocationSamples:[MockCLLocationManager ReadSamplesFromFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"tracklog-0.json" ofType:nil]]];
    [tracker startTrackingLocation];
    [mock run];
    [tracker stopTrackingLocation];
    
    
    [mock setLocationSamples:[MockCLLocationManager ReadSamplesFromFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"tracklog-1.json" ofType:nil]]];
    [tracker startTrackingLocation];
    [mock run];
    [tracker stopTrackingLocation];
    
    
    [mock setLocationSamples:[MockCLLocationManager ReadSamplesFromFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"tracklog-2.json" ofType:nil]]];
    [tracker startTrackingLocation];
    [mock run];
    [tracker stopTrackingLocation];
    
    
    [mock setLocationSamples:[MockCLLocationManager ReadSamplesFromFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"locationlog-0.json" ofType:nil]]];
    [tracker startTrackingLocation];
    [mock run];
    [tracker stopTrackingLocation];
    
    

    
    [mock setLocationSamples:[MockCLLocationManager ReadSamplesFromFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"locationlog-16.json" ofType:nil]]];
    [tracker startTrackingLocation];
    [mock run];
    [tracker stopTrackingLocation];
    
    
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
