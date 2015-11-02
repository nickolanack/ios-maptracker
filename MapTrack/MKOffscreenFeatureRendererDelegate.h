//
//  MKOffscreenFeatureRendererDelegate.h
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-27.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol MKOffscreenFeatureRendererDelegate <NSObject>

@required

-(UIView *)viewForOffscreenPointFeature:(MKPointAnnotation *)point;
-(bool)shouldRenderViewForOffscreenPointFeature:(MKPointAnnotation *)point;

@end