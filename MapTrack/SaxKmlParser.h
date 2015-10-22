//
//  GeolKmlParser.h
//  Geolive 1.0
//
//  Created by Nick Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAXKmlParserDelegate.h"

@class SAXKmlParserDelegate;

@interface SaxKmlParser : NSObject<NSXMLParserDelegate>

@property id<SAXKmlParserDelegate> delegate;


-(instancetype)initWithDelegate:(id<SAXKmlParserDelegate>) delegate;

-(void) parseString:(NSString *)string;


@end
