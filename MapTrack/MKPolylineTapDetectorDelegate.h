//  Created by Nick Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@protocol MKPolylineTapDetectorDelegate <NSObject>


-(void) onPolylineTap:(MKPolyline *)polyline atCoordinate:(CLLocationCoordinate2D)coord andTouch:(CGPoint)touch;



@end
