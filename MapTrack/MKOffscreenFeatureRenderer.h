//
//  MKOffscreenFeatureRenderer.h
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-27.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MKOffscreenFeatureRendererDelegate.h"

@interface MKOffscreenFeatureRenderer : NSObject

@property id<MKOffscreenFeatureRendererDelegate> delegate;
@property MKMapView *mapView;

-(instancetype)initWithMap:(MKMapView *)map;

-(void)startUpdating;
-(void)stopUpdating;
@end
