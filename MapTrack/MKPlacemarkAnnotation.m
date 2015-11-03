//
//  MKPlacemarkAnnotation.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-11-02.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "MKPlacemarkAnnotation.h"

@implementation MKPlacemarkAnnotation


@synthesize iconUrl;

-(UIImage *) getIcon{
    
    NSRange r=[self.iconUrl rangeOfString:@"http://"];
    if(r.location==0){
        
        NSString *httpsString=[self.iconUrl stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
        NSError *err;
        NSData * imageData=[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString: [httpsString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]] options:NSDataReadingMappedIfSafe error:&err];
        if(!err){
            return [MKPlacemarkAnnotation ThumbnailImage:[UIImage imageWithData:imageData]];
        }
        
    }
    
    r=[self.iconUrl rangeOfString:@"http"];
    if(r.location==0){
        
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [self.iconUrl stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
        UIImage *theImage = [UIImage imageWithData:imageData];
        return [MKPlacemarkAnnotation ThumbnailImage:theImage];
        
    }else{
        
        if([[NSFileManager defaultManager] fileExistsAtPath:self.iconUrl]){
            
            return [UIImage imageWithContentsOfFile:self.iconUrl];
            
        }else{
            //throw;
            return nil;
        }
        
    }
    
    
}


+(UIImage *)ThumbnailImage:(UIImage *)image{
    
    UIImage *theImage=image;
    CGSize size = CGSizeMake(theImage.size.width/2.0, theImage.size.height/2.0);
    
    UIGraphicsBeginImageContext(size);
    
    [theImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return destImage;
    
}

@end
