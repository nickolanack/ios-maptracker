//
//  MKPolylineTapDetectorTests.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-11-03.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MKPolylineTapDetector.h"


@interface MKPolylineTapDetectorTests : XCTestCase

@end

@implementation MKPolylineTapDetectorTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testTrigonometry{
    
    
    
    
    
    
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    MKMapPoint ptA=MKMapPointMake(1.0, 2.0);
    MKMapPoint ptB=MKMapPointMake(0.0, 0.0);
    MKMapPoint ptC=MKMapPointMake(5.0, 0.0);
    
    MKMapPoint ptExpected=MKMapPointMake(1.0, 0.0);
    
    
    float a=sqrtf(powf(ptB.x-ptC.x,2)+powf(ptB.y-ptC.y,2)); //MKMetersBetweenMapPoints(ptB, ptC);
    float b=sqrtf(powf(ptA.x-ptC.x,2)+powf(ptA.y-ptC.y,2)); //MKMetersBetweenMapPoints(ptA, ptC);
    float c=sqrtf(powf(ptB.x-ptA.x,2)+powf(ptB.y-ptA.y,2)); //MKMetersBetweenMapPoints(ptB, ptA);
    
    float B=acosf((powf(b, 2)-powf(a,2)-powf(c,2))/(-2*a*c));
    XCTAssertEqual(B, acosf(1.0/sqrtf(5)));
    
    
    
    float d=cosf(B)*c;
    float fraction=d/a;
    
    XCTAssertEqual((int)(d*100), 100);
    XCTAssertEqual((int)(fraction*100), (int)((1.0/5.0)*100));
    
    
    
    
    float dx=ptC.x-ptB.x;
    float dy=ptC.y-ptB.y;
    
    MKMapPoint ptActual= MKMapPointMake(ptB.x+fraction*dx, ptB.y+fraction*dy);
    
    
    
    XCTAssertEqual([self thou:ptActual.x], [self thou:ptExpected.x]);
    XCTAssertEqual([self thou:ptActual.y], [self thou:ptExpected.y]);
    
    ptActual=[MKPolylineTapDetector IntersectionPointFrom:ptA toTangentDefinedByPoint:ptB andPoint:ptC];
    
    XCTAssertEqual([self thou:ptActual.x], [self thou:ptExpected.x]);
    XCTAssertEqual([self thou:ptActual.y], [self thou:ptExpected.y]);
    
}

-(int)thou:(float)n{
    return (int)(n*1000);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
