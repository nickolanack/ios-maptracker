//
//  MKImageOverlayView.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-22.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "MKImageOverlayRenderer.h"
#import "MKImageOverlay.h"

@implementation MKImageOverlayRenderer




- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context{
    
    MKImageOverlay *o=self.overlay;
    //NSString *path=[[NSBundle mainBundle] pathForResource:o.image ofType:nil];

    UIImage *image = [o getUIImage];
    CGImageRef imageReference = image.CGImage;
    
    MKMapRect theMapRect = [self.overlay boundingMapRect];
    CGRect theRect = [self rectForMapRect:theMapRect];

    CGPoint p=[self pointForMapPoint:MKMapPointForCoordinate(o.coordinate)];
    
    //Move context origin to center, rotate, and then move context back
    float angle=-M_PI*o.rotation/180.0;
    CGContextTranslateCTM(context, p.x, p.y);
    CGContextRotateCTM(context,  angle) ;
    CGContextTranslateCTM(context, -p.x, -p.y);
    
    //Invert to fix UIImage differences
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -theRect.size.height);

    
    CGContextDrawImage(context, theRect, imageReference);
}


@end
