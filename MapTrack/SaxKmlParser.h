//
//  GeolKmlParser.h
//  Geolive 1.0
//
//  Created by Nick Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SaxKmlParserDelegate.h"

@class SAXKmlParserDelegate;

@interface SaxKmlParser : NSObject<NSXMLParserDelegate>

@property id<SaxKmlParserDelegate> delegate;


-(instancetype)initWithDelegate:(id<SaxKmlParserDelegate>) delegate;

-(void) parseString:(NSString *)string;


@end
