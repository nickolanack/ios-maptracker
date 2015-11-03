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
-(float)distance:(MKMapPoint)a :(MKMapPoint)b{

    return sqrtf(powf(b.x-a.x,2)+powf(b.y-a.y,2));

}
- (MKMapPoint)closestPointTo:(MKMapPoint)pt inPoly:(MKPolyline *)poly{
    
    int i=[self closestPointIndexTo:pt inPoly:poly];
    MKMapPoint p=poly.points[i];
    float dist=[self distance: poly.points[i] :pt];
    
    if(i>0){
        MKMapPoint p0=[MKPolylineTapDetector IntersectionPointFrom:pt toTangentDefinedByPoint:poly.points[i] andPoint:poly.points[i-1]];
        float dist0=[self distance:p0 :pt];
        if(dist0<dist){
            dist=dist0;
            p=p0;
        }
    }
    
    if(i<poly.pointCount-1){
        MKMapPoint p1=[MKPolylineTapDetector IntersectionPointFrom:pt toTangentDefinedByPoint:poly.points[i] andPoint:poly.points[i+1]];
        float dist1=[self distance:p1 :pt];
        if(dist1<dist){
            dist=dist1;
            p=p1;
        }
    }
    
    return p;
    
}

- (int)closestPointIndexTo:(MKMapPoint)pt inPoly:(MKPolyline *)poly
{
    double distance=-1;
    int i=-1;
    for (int n = 0; n < poly.pointCount - 1; n++) {
        
        MKMapPoint ptA = poly.points[n];
       
        double d = [self distance:ptA :pt];
        if(d<distance||i==-1){
            distance=d;
            i=n;
        }
    }
    
    return i;
}

+(MKMapPoint)IntersectionPointFrom:(MKMapPoint)ptA toTangentDefinedByPoint:(MKMapPoint)ptB andPoint:(MKMapPoint)ptC{

    // given a triangle with sides of known length, a, b, c, and the unknown angles opposite each side called A, B, C
    // then using sine b² = a² + c² - 2ac cosB. etc, the angles can be written in terms of known sides.
    // to calculate the distance between ptA and side a, cos(B)=(d)/c where d is the distance from point ptB toward ptC
    // such that a point at this distance ptD would form a perpendicular line with ptA to a and a triangle could be drawn
    // the triagle drawn around ptA, ptB, and ptD is right angled and c is the hypotenuse.
    // cos(B)*c=d; sqrt(c^2-d^2)=distance!
   
    
    //I think distance in terms of projection pixels makes more sense
    
    float a=sqrtf(powf(ptB.x-ptC.x,2)+powf(ptB.y-ptC.y,2)); //MKMetersBetweenMapPoints(ptB, ptC);
    float b=sqrtf(powf(ptA.x-ptC.x,2)+powf(ptA.y-ptC.y,2)); //MKMetersBetweenMapPoints(ptA, ptC);
    float c=sqrtf(powf(ptB.x-ptA.x,2)+powf(ptB.y-ptA.y,2)); //MKMetersBetweenMapPoints(ptB, ptA);
    
    float B=acosf((powf(b, 2)-powf(a,2)-powf(c,2))/(-2.0*a*c));
    float d=cosf(B)*c;
    float fraction=d/a;
    if(fraction<0||fraction>1){
        return ptB;
    }
    
    float dx=ptC.x-ptB.x;
    float dy=ptC.y-ptB.y;
    
    return MKMapPointMake(ptB.x+fraction*dx, ptB.y+fraction*dy);
 
}

- (double)mapDistanceFromPoint:(CGPoint)pt withPixelDistance: (NSUInteger)px
{
    CGPoint ptB = CGPointMake(pt.x + px, pt.y);
    

    
    CLLocationCoordinate2D coordA = [self.map convertPoint:pt toCoordinateFromView:self.map];
    CLLocationCoordinate2D coordB = [self.map convertPoint:ptB toCoordinateFromView:self.map];
    
    return [self distance:MKMapPointForCoordinate(coordA) :MKMapPointForCoordinate(coordB)];
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    if ((tap.state & UIGestureRecognizerStateRecognized) == UIGestureRecognizerStateRecognized) {
        MKMapPoint closestPointInPoly;
        // Get map coordinate from touch point
        CGPoint touchPt = [tap locationInView:self.map];
        CLLocationCoordinate2D coord = [self.map convertPoint:touchPt toCoordinateFromView:self.map];
        
        
        float nearestDistance = MAXFLOAT;
        MKPolyline *nearestPoly = nil;
        
        // for every overlay ...
        for (id <MKOverlay> overlay in self.map.overlays) {
            
            // .. if MKPolyline ...
            if ([overlay isKindOfClass:[MKPolyline class]]) {
                
                // ... get the distance ...
                MKMapPoint pt=MKMapPointForCoordinate(coord);
                MKMapPoint closest=[self closestPointTo:pt inPoly:overlay];
                float distance = [self distance:closest :pt];
                
                // ... and find the nearest one
                if (distance < nearestDistance) {
                    
                    nearestDistance = distance;
                    nearestPoly = overlay;
                    closestPointInPoly=closest;
  
                }
            }
        }
        
        float maxDistance=[self mapDistanceFromPoint:touchPt withPixelDistance:25.0];
        
        
        if (nearestDistance <= maxDistance) {
            
            [self.delegate onPolylineTap:nearestPoly atCoordinate: MKCoordinateForMapPoint(closestPointInPoly) andTouch:touchPt];
            
        }
    }
}


@end
