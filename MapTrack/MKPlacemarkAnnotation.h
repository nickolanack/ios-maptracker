//
//  MKPlacemarkAnnotation.h
//  MapTrack
//
//  Created by Nick Blackwell on 2015-11-02.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKPlacemarkAnnotation : MKPointAnnotation

@property NSString *iconUrl;

-(UIImage*)getIcon;


@end
