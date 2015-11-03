//
//  MKPolylineTapDetector.h
//  MapTrack
//
//  Created by Nick Blackwell on 2015-11-02.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKPolylineTapDetectorDelegate.h"

@interface MKPolylineTapDetector : NSObject

@property id<MKPolylineTapDetectorDelegate>delegate;
@property MKMapView *map;

-(instancetype)initWithMap:(MKMapView *)map;

+(MKMapPoint)IntersectionPointFrom:(MKMapPoint)ptA toTangentDefinedByPoint:(MKMapPoint)ptB andPoint:(MKMapPoint)ptC;

@end
