//
//  MockCLLocationManager.h
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-29.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MockCLLocationManager : NSObject

@property id<CLLocationManagerDelegate> locationManagerDelegate;
@property NSArray *locationSamples;


-(void)run;
+(NSArray *)ReadSamplesFromFile:(NSString *)path;

@end
