//  Created by Nick Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.

#import <Foundation/Foundation.h>



@protocol SaxKmlParserDelegate <NSObject>

@required

-(void) onKmlPlacemark:(NSDictionary *)dictionary;
-(void) onKmlPolyline:(NSDictionary *)dictionary;
-(void) onKmlPolygon:(NSDictionary *)dictionary;
-(void) onKmlGroundOverlay:(NSDictionary *)dictionary;

@optional

-(void) onKmlStyle:(NSDictionary *)dictionary;
-(void) onKmlFolder:(NSDictionary *)dictionary;

@end
