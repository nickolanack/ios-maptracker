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

-(void) loadMapItemFromDictionary:(NSDictionary *)dictionary;
-(void) loadStyleFromDictionary:(NSDictionary *)dictionary;
-(void) loadFolderFromDictionary:(NSDictionary *)dictionary;
-(void) loadGroundOverlayFromDictionary:(NSDictionary *)dictionary;

@end
