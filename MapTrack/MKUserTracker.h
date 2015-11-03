//
//  MKUsersPath.h
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-27.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MKUserTrackerDelegate.h"
#import "SaxKmlParserDelegate.h"


@interface MKUserTracker : NSObject<CLLocationManagerDelegate, SaxKmlParserDelegate>

@property id<MKUserTrackerDelegate> delegate;
@property (readonly) CLLocation *currentLocation;

@property UIColor *pathColor;
@property float pathWidth;


-(instancetype)initWithMap:(MKMapView *)map;

-(void)startTrackingLocation;
-(void)stopTrackingLocation;


-(void)startMovingWithLocation;
-(void)stopMovingWithLocation;

-(void)startRotatingWithHeading;
-(void)stopRotatingWithHeading;


-(NSTimeInterval) getTimeInterval;

@end
