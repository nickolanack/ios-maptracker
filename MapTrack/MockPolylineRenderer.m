//
//  MockPolylineRenderer.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-11-05.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "MockPolylineRenderer.h"

@implementation MockPolylineRenderer

-(void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context{
   
    //CGContextTranslateCTM(context, mapRect.origin.x, mapRect.origin.y);
    //CGContextAddRect(context, CGRectMake(mapRect.origin.x, mapRect.origin.y, mapRect.size.width, mapRect.size.height));
    //CGContextTranslateCTM(context, -mapRect.origin.x, -mapRect.origin.y);
    
    [super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
   
    //CGAffineTransform tr=CGContextGetCTM(context);
    //CGRect r=CGContextGetPathBoundingBox(context);
    
    //NSLog(@"drawMapRect: x:%f, y:%f - w:%f, h:%f", r.origin.x, r.origin.y, r.size.width, r.size.height);
}

@end
