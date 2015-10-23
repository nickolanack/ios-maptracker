//
//  GeolKmlParserDelegate.h
//  Geolive 1.0
//
//  Created by Nick Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol SAXKmlParserDelegate <NSObject>

@required

-(void) onKmlPlacemark:(NSDictionary *)dictionary;
-(void) onKmlStyle:(NSDictionary *)dictionary;
-(void) onKmlFolder:(NSDictionary *)dictionary;
-(void) onKmlGroundOverlay:(NSDictionary *)dictionary;

@end
