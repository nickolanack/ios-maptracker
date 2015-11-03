//  Created by Nick Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.

#import "SaxKmlParser.h"
#import "SAXKmlParserDelegate.h"
@interface SaxKmlParser()

@property NSMutableDictionary *currentObject;
@property NSMutableArray *currentObjectType;


@property NSMutableDictionary *styleMaps;
@property NSMutableDictionary *styles;

@end


@implementation SaxKmlParser


-(instancetype)initWithDelegate:(id<SaxKmlParserDelegate>)delegate{
    self=[super init];
    self.delegate=delegate;
    
    
    self.styleMaps=[[NSMutableDictionary alloc] init];
    self.styles=[[NSMutableDictionary alloc] init];
    
    return self;
}


-(void)parseString:(NSString *)string{
   

    self.currentObject=nil;

    self.currentObjectType=[[NSMutableArray alloc] init];
    
    NSXMLParser *parser = [[NSXMLParser alloc]initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO]; // We don't care about namespaces
    [parser setShouldReportNamespacePrefixes:NO]; //
    [parser setShouldResolveExternalEntities:NO]; // We just want data, no other stuff
    
    [parser parse];
}


#pragma mark -
#pragma marker NSXML Parser Delegate


// Document handling methods
- (void)parserDidStartDocument:(NSXMLParser *)parser{
   // NSLog(@" parserDidStartDocument ");
    NSLog(@"%s: Parsing Document Started.", __PRETTY_FUNCTION__);

}
// sent when the parser begins parsing of the document.
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    NSLog(@"%s: Parsing Document Complete.", __PRETTY_FUNCTION__);
}
// sent when the parser has completed parsing. If this is encountered, the parse was successful.

// DTD handling methods for various declarations.
- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID{
  //  NSLog(@" blob");
}

- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName{
   // NSLog(@" blob");
}

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue{
    //NSLog(@" blob");
}

- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model{
//NSLog(@" blob");
}

- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value{
    //NSLog(@" blob");
}

- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID{}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
   // NSLog(@" didStartElement %@ namespaceURI %@ qualifiedName %@ attributes %@",elementName, namespaceURI, qName, attributeDict);
   
    NSString *tagName=[elementName lowercaseString];
   // NSLog(@"Start %@", elementName);
    
    
    if([tagName isEqualToString:@"placemark"]){
        [self.currentObjectType addObject:@"placemark"];
         self.currentObject=[[NSMutableDictionary alloc] init];
        NSString *ID=[attributeDict objectForKey:@"id"];
        if(ID!=nil){
            [self.currentObject setObject:ID forKey:@"id"];
        }
        [self.currentObject setObject:@"marker" forKey:@"mapitemtype"];
    }else if([tagName isEqualToString:@"linestring"]){
        //[self.currentObjectType addObject:@"linestring"];
       // self.currentObject=[[NSMutableDictionary alloc] init];
       // NSString *ID=[attributeDict objectForKey:@"id"];
       // if(ID!=nil){
        //    [self.currentObject setObject:ID forKey:@"id"];
        //}
        [self.currentObject setObject:@"polyline" forKey:@"mapitemtype"];
        //NSLog(@"Polygon");
    }else if([tagName isEqualToString:@"style"]){
        [self.currentObjectType addObject:@"style"];
        self.currentObject=[[NSMutableDictionary alloc] init];
        NSString *ID=[attributeDict objectForKey:@"id"];
        if(ID!=nil){
            [self.currentObject setObject:[NSString stringWithFormat:@"%@%@",@"#",ID] forKey:@"id"];
        }
        [self.currentObject setObject:@"style" forKey:@"mapitemtype"];
        //NSLog(@"Polygon");
    }else if([tagName isEqualToString:@"stylemap"]){
        [self.currentObjectType addObject:@"stylemap"];
        self.currentObject=[[NSMutableDictionary alloc] init];
        NSString *ID=[attributeDict objectForKey:@"id"];
        if(ID!=nil){
            [self.currentObject setObject:[NSString stringWithFormat:@"%@%@",@"#",ID] forKey:@"id"];
        }
        [self.currentObject setObject:@"stylemap" forKey:@"mapitemtype"];
        //NSLog(@"Polygon");
    }else if([tagName isEqualToString:@"name"]){
        [self.currentObjectType addObject:@"name"];
    }else if([tagName isEqualToString:@"description"]){
        [self.currentObjectType addObject:@"description"];
    }else if([tagName isEqualToString:@"linestyle"]){
        [self.currentObjectType addObject:@"linestyle"];
    }else if([tagName isEqualToString:@"polystyle"]){
        [self.currentObjectType addObject:@"polystyle"];
    }else if([tagName isEqualToString:@"color"]){
        [self.currentObjectType addObject:@"color"];
    }else if([tagName isEqualToString:@"width"]){
        [self.currentObjectType addObject:@"width"];
    }else if([tagName isEqualToString:@"outline"]){
        [self.currentObjectType addObject:@"outline"];
    }else if([tagName isEqualToString:@"coordinates"]){
        [self.currentObjectType addObject:@"coordinates"];
    }else if([tagName isEqualToString:@"styleurl"]){
        [self.currentObjectType addObject:@"styleurl"];
    }else if([tagName isEqualToString:@"extendeddata"]){
        [self.currentObjectType addObject:@"extendeddata"];
    }else if([tagName isEqualToString:@"groundoverlay"]){
        [self.currentObjectType addObject:@"groundoverlay"];
        self.currentObject=[[NSMutableDictionary alloc] init];
        NSString *ID=[attributeDict objectForKey:@"id"];
        if(ID!=nil){
            [self.currentObject setObject:ID forKey:@"id"];
        }
    }else if([tagName isEqualToString:@"viewboundscale"]){
        [self.currentObjectType addObject:@"viewboundscale"];
    }else if([tagName isEqualToString:@"latlonbox"]){
        [self.currentObjectType addObject:@"latlonbox"];
    }else if([tagName isEqualToString:@"north"]){
        [self.currentObjectType addObject:@"north"];
    }else if([tagName isEqualToString:@"south"]){
        [self.currentObjectType addObject:@"south"];
    }else if([tagName isEqualToString:@"east"]){
        [self.currentObjectType addObject:@"east"];
    }else if([tagName isEqualToString:@"west"]){
        [self.currentObjectType addObject:@"west"];
    }else if([tagName isEqualToString:@"rotation"]){
        [self.currentObjectType addObject:@"rotation"];
    }else if([tagName isEqualToString:@"href"]){
        [self.currentObjectType addObject:@"href"];
    }else if([tagName isEqualToString:@"tessellate"]){
        [self.currentObjectType addObject:@"tessellate"];
    }else if([tagName isEqualToString:@"key"]){
        [self.currentObjectType addObject:@"key"];
    }else{
        NSLog(@"Unknown Tag %@", tagName);
    }
    
    
}
// sent when the parser finds an element start tag.
// In the case of the cvslog tag, the following is what the delegate receives:
//   elementName == cvslog, namespaceURI == http://xml.apple.com/cvslog, qualifiedName == cvslog
// In the case of the radar tag, the following is what's passed in:
//    elementName == radar, namespaceURI == http://xml.apple.com/radar, qualifiedName == radar:radar
// If namespace processing >isn't< on, the xmlns:radar="http://xml.apple.com/radar" is returned as an attribute pair, the elementName is 'radar:radar' and there is no qualifiedName.

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
   //  NSLog(@" didEndElement %@ namespaceURI %@ qualifiedName %@",elementName, namespaceURI, qName);
    
    NSString *tagName=[elementName lowercaseString];
    
    
    if([tagName isEqualToString:@"placemark"]){
        if(self.delegate!=nil){
            
            NSDictionary *feature=[self prepareData:self.currentObject];
            
            if([[self.currentObject objectForKey:@"mapitemtype"] isEqualToString:@"polyline"]){
                [self.delegate onKmlPolyline:feature];
            }else if([[self.currentObject objectForKey:@"mapitemtype"] isEqualToString:@"polygon"]){
                [self.delegate onKmlPolygon:feature];
            }else{
             [self.delegate onKmlPlacemark:feature];
            }
        }
    }else if([tagName isEqualToString:@"style"]){
        [self onKmlStyle:self.currentObject];
       
    }else if([tagName isEqualToString:@"stylemap"]){
        [self onKmlStyleMap:self.currentObject];
       
    }else if([tagName isEqualToString:@"groundoverlay"]){
        if(self.delegate!=nil){
            [self.delegate onKmlGroundOverlay:self.currentObject];
        }
    }else{
        NSLog(@"end %@", tagName);
    
    }
    
    
    if([tagName isEqualToString:((NSString *)[self.currentObjectType lastObject])]){
        [self.currentObjectType removeLastObject];
    }
    
}
// sent when an end tag is encountered. The various parameters are supplied as above.

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI{
   // NSLog(@" didStartMappingPrefix %@ toURI %@",prefix, namespaceURI);

}
// sent when the parser first sees a namespace attribute.
// In the case of the cvslog tag, before the didStartElement:, you'd get one of these with prefix == @"" and namespaceURI == @"http://xml.apple.com/cvslog" (i.e. the default namespace)
// In the case of the radar:radar tag, before the didStartElement: you'd get one of these with prefix == @"radar" and namespaceURI == @"http://xml.apple.com/radar"

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix{
   // NSLog(@" didEndMappingPrefix %@",prefix);
}
// sent when the namespace prefix in question goes out of scope.

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
  //  NSLog(@" foundCharacters %@",string);
    
    NSString *data=[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([data isEqualToString:@"\n"]||[data isEqualToString:@""]){
        return;
    }
    
    
    
  //  NSLog(@" foundString %@",data);
    NSString *current=[self.currentObjectType lastObject];
    
    if(!current){
        NSLog(@"No current tag for value: %@", data);
    }
    
    if([current isEqualToString:@"name"] || [current isEqualToString:@"description"] || [current isEqualToString:@"coordinates"]|| [current isEqualToString:@"styleurl"] || [current isEqualToString:@"width"] || [current isEqualToString:@"outline"]){
        
        NSString *key=[self.currentObject objectForKey:@"key"];
        if(key!=nil){
            current=key;
            [self.currentObject removeObjectForKey:@"key"];
        }
        
        NSString *previous=[self.currentObject objectForKey:current];
        if(previous==nil){
            previous=@"";
        }
        
        [self.currentObject setObject:[NSString stringWithFormat:@"%@%@",previous,data] forKey:[NSString stringWithString:current]];
    }else if([current isEqualToString:@"color"]){
        NSString *parent=[self.currentObjectType objectAtIndex:([self.currentObjectType count]-2)];
       // NSLog(@"Style%@",parent);
        if([parent isEqualToString:@"linestyle"]||[parent isEqualToString:@"polystyle"]){
            if([parent isEqualToString:@"polystyle"]){
                current=@"polycolor";
            }
            [self.currentObject setObject:data forKey:[NSString stringWithString:current]];
        }
        
    }else{
        if(self.currentObject&&current){
             [self.currentObject setObject:data forKey:[NSString stringWithString:current]];
        }
        if(current){
            NSLog(@"Unknown Value %@ for %@", data, current);
        }else{
            NSLog(@"Unknown Value %@ for %@", data, current);
        }
    }
    
}
// A comment (Text in a <!-- --> block) iss reported to the delegate as a single string

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock{
    NSString *data=[[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    [self parser:parser foundCharacters:data];
}



// This returns the string of the characters encountered thus far. You may not necessarily get the longest character run. The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)foundIgnorableWhitespace{
   // NSLog(@" foundIgnorableWhitespace %@",foundIgnorableWhitespace);
}
// The parser reports ignorable whitespace in the same way as characters it's found.

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data{\
  //  NSLog(@" foundProcessingInstructionWithTarget %@ data %@",target, data);
}
// The parser reports a processing instruction to you using this method. In the case above, target == @"xml-stylesheet" and data == @"type='text/css' href='cvslog.css'"

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment{
   // NSLog(@" foundComment %@",comment);
}

// this reports a CDATA block to the delegate as an NSData.


    
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@" parseErrorOccurred %@",parseError);

}
// ...and this reports a fatal error to the delegate. The parser will stop parsing.

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError{
    NSLog(@" validationErrorOccurred %@",validationError);
}
// If validation is on, this will report a fatal validation error to the delegate. The parser will stop parsing.


-(void)onKmlStyleMap:(NSDictionary *)dictionary{

   
    [self.styleMaps setValue:dictionary forKey:[dictionary objectForKey:@"id"]];

}
-(void)onKmlStyle:(NSDictionary *)dictionary{
    
    [self.styles setValue:dictionary forKey:[dictionary objectForKey:@"id"]];
    
    if(self.delegate!=nil&&[self.delegate respondsToSelector:@selector(onKmlStyle:)]){
        [self.delegate onKmlStyle:dictionary];
    }
    
}


-(NSDictionary *)prepareData:(NSDictionary *) dictionary{

    NSMutableDictionary *feature=[[NSMutableDictionary alloc] initWithDictionary:dictionary];
    
    NSString *styleUrl=[dictionary objectForKey:@"styleurl"];
    
    if(styleUrl!=nil&&[[styleUrl substringToIndex:1] isEqualToString:@"#"]){
    
        NSDictionary *style=[self.styles objectForKey:styleUrl];
        if(style!=nil){
          
            if([[dictionary objectForKey:@"mapitemtype"] isEqualToString:@"marker"]){
                [feature setValue:[style objectForKey:@"href"] forKey:@"href"];
                [feature removeObjectForKey:@"styleurl"];
            }
            
            if([[dictionary objectForKey:@"mapitemtype"] isEqualToString:@"polyline"]){
                [feature setValue:[style objectForKey:@"width"]  forKey:@"width"];
                [feature setValue:[style objectForKey:@"color"]  forKey:@"color"];
                [feature removeObjectForKey:@"styleurl"];
            }
            
            if([[dictionary objectForKey:@"mapitemtype"] isEqualToString:@"polygon"]){
                [feature setValue:[style objectForKey:@"width"]  forKey:@"width"];
                [feature setValue:[style objectForKey:@"color"]  forKey:@"color"];
                [feature removeObjectForKey:@"styleurl"];
            }
            
            
        }else{
            NSDictionary *stylemap=[self.styleMaps objectForKey:styleUrl];
            if(stylemap!=nil){
                
                
                
                stylemap=[self prepareData:stylemap];
                
                if([[dictionary objectForKey:@"mapitemtype"] isEqualToString:@"marker"]){
                    [feature setValue:[[stylemap objectForKey:@"normal"] objectForKey:@"href"] forKey:@"href"];
                    [feature removeObjectForKey:@"styleurl"];
                }
                
                if([[dictionary objectForKey:@"mapitemtype"] isEqualToString:@"polyline"]){
                    [feature setValue:[[stylemap objectForKey:@"normal"] objectForKey:@"width"]  forKey:@"width"];
                    [feature setValue:[[stylemap objectForKey:@"normal"] objectForKey:@"color"]  forKey:@"color"];
                    [feature removeObjectForKey:@"styleurl"];
                }
                
                if([[dictionary objectForKey:@"mapitemtype"] isEqualToString:@"polygon"]){
                    [feature setValue:[[stylemap objectForKey:@"normal"] objectForKey:@"width"]  forKey:@"width"];
                    [feature setValue:[[stylemap objectForKey:@"normal"] objectForKey:@"color"]  forKey:@"color"];
                    [feature removeObjectForKey:@"styleurl"];
                }
                
               
                
               
            }else{
                
                //error!
            
            }
        
        }
    
    }else if([[dictionary objectForKey:@"mapitemtype"] isEqualToString:@"stylemap"]){
        //resolve stylemap.
        NSString *normal=[dictionary objectForKey:@"normal"];
        NSDictionary *normalStyle=[self.styles objectForKey:normal];
        
        NSString *highlight=[dictionary objectForKey:@"highlight"];
        NSDictionary *highlightStyle=[self.styles objectForKey:highlight];
        
        return @{@"normal":normalStyle, @"highlight":highlightStyle};
    
    }
    
    return [[NSDictionary alloc] initWithDictionary:feature];

}


+(NSArray*) ParseCoordinateArrayString:(NSString *)coordinates{

    NSArray *coordinateArray=[[coordinates stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return coordinateArray;

}



+(CLLocationCoordinate2D)ParseCoordinateString:(NSString *)coordinate{

    NSArray *coords=[coordinate componentsSeparatedByString:@","];

return CLLocationCoordinate2DMake([[[coords objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] floatValue], [[[coords objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] floatValue]);


}


+(UIColor *)ParseColorString:(NSString *)color{
    
    if(color==nil){
        return [UIColor blackColor];
    }

    NSString *aStr=[color substringWithRange:NSMakeRange(0, 2)];
    NSString *bStr=[color substringWithRange:NSMakeRange(2, 2)];
    NSString *gStr=[color substringWithRange:NSMakeRange(4, 2)];
    NSString *rStr=[color substringWithRange:NSMakeRange(6, 2)];
    
    long a=strtol([aStr UTF8String], NULL, 16);
    long r=strtol([rStr UTF8String], NULL, 16);
    long g=strtol([gStr UTF8String], NULL, 16);
    long b=strtol([bStr UTF8String], NULL, 16);
    
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0];
 
}


@end
