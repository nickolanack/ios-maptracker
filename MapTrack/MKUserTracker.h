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


@interface MKUserTracker : NSObject<CLLocationManagerDelegate>

@property id<MKUserTrackerDelegate> delegate;

-(instancetype)initWithMap:(MKMapView *)map;


-(void)startTrackingLocation;
-(void)stopTrackingLocation;

@end
