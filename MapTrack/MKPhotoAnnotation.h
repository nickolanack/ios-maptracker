//
//  MKImageAnnotation.h
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-29.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKPhotoAnnotation : MKPointAnnotation


@property (readonly) NSString *path;

-(instancetype)initWithImagePath:(NSString *) path;
-(instancetype)initWithUIImage:(UIImage *) image;
-(UIImage *) getIcon;

@end
