//
//  MKUserTrackerDelegate.h
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-27.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//
#import <Foundation/Foundation.h>



@protocol MKUserTrackerDelegate <NSObject>

@required

-(void)userTrackerPaceDidChangeTo:(float) pace From:(float) previousPace;
-(void)userTrackerDistanceDidChange:(float) distance From:(float) previousDistance;

@end
