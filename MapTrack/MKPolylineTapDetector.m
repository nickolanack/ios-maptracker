//
//  MKPolylineTapDetector.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-11-02.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "MKPolylineTapDetector.h"

@implementation MKPolylineTapDetector

@synthesize delegate;

-(instancetype)initWithMap:(MKMapView *)map{

    self =[super init];
    
    self.map=map;
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.map addGestureRecognizer:tap];

    return self;

}




/** Returns the distance of |pt| to |poly| in meters
 *
 * from http://paulbourke.net/geometry/pointlineplane/DistancePoint.java
 *
 */
- (double)distanceOfPoint:(MKMapPoint)pt toPoly:(MKPolyline *)poly
{
    double distance = MAXFLOAT;
    for (int n = 0; n < poly.pointCount - 1; n++) {
        
        MKMapPoint ptA = poly.points[n];
        MKMapPoint ptB = poly.points[n + 1];
        
        double xDelta = ptB.x - ptA.x;
        double yDelta = ptB.y - ptA.y;
        
        if (xDelta == 0.0 && yDelta == 0.0) {
            
            // Points must not be equal
            continue;
        }
        
        double u = ((pt.x - ptA.x) * xDelta + (pt.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta);
        MKMapPoint ptClosest;
        if (u < 0.0) {
            
            ptClosest = ptA;
        }
        else if (u > 1.0) {
            
            ptClosest = ptB;
        }
        else {
            
            ptClosest = MKMapPointMake(ptA.x + u * xDelta, ptA.y + u * yDelta);
        }
        
        distance = MIN(distance, MKMetersBetweenMapPoints(ptClosest, pt));
    }
    
    return distance;
}


/** Converts |px| to meters at location |pt| */
- (double)metersFromPixel:(NSUInteger)px atPoint:(CGPoint)pt
{
    CGPoint ptB = CGPointMake(pt.x + px, pt.y);
    
    CLLocationCoordinate2D coordA = [self.map convertPoint:pt toCoordinateFromView:self.map];
    CLLocationCoordinate2D coordB = [self.map convertPoint:ptB toCoordinateFromView:self.map];
    
    return MKMetersBetweenMapPoints(MKMapPointForCoordinate(coordA), MKMapPointForCoordinate(coordB));
}


#define MAX_DISTANCE_PX 22.0f
- (void)handleTap:(UITapGestureRecognizer *)tap
{
    if ((tap.state & UIGestureRecognizerStateRecognized) == UIGestureRecognizerStateRecognized) {
        
        // Get map coordinate from touch point
        CGPoint touchPt = [tap locationInView:self.map];
        CLLocationCoordinate2D coord = [self.map convertPoint:touchPt toCoordinateFromView:self.map];
        
        double maxMeters = [self metersFromPixel:MAX_DISTANCE_PX atPoint:touchPt];
        
        float nearestDistance = MAXFLOAT;
        MKPolyline *nearestPoly = nil;
        
        // for every overlay ...
        for (id <MKOverlay> overlay in self.map.overlays) {
            
            // .. if MKPolyline ...
            if ([overlay isKindOfClass:[MKPolyline class]]) {
                
                // ... get the distance ...
                float distance = [self distanceOfPoint:MKMapPointForCoordinate(coord)
                                                toPoly:overlay];
                
                // ... and find the nearest one
                if (distance < nearestDistance) {
                    
                    nearestDistance = distance;
                    nearestPoly = overlay;
                }
            }
        }
        
        if (nearestDistance <= maxMeters) {
            
            [self.delegate onPolylineTap:nearestPoly atCoordinate:coord];

        }
    }
}


@end
