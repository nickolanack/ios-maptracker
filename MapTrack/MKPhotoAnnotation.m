//
//  MKImageAnnotation.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-29.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "MKPhotoAnnotation.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface MKPhotoAnnotation()

@property NSString *path;

@end

@implementation MKPhotoAnnotation

-(instancetype)initWithImagePath:(NSString *) path{

    self=[super init];
    self.path=path;
    return self;
    
}

-(instancetype)initWithUIImage:(UIImage *) image{
    
    self=[super init];
    NSFileManager *fm=[NSFileManager defaultManager];
//    NSString *folder=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"photos"];
//    if(![fm fileExistsAtPath:folder]){
//        NSError *err;
//        [fm createDirectoryAtPath:folder withIntermediateDirectories:true attributes:nil error:&err];
//    }
    NSString *folder=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    int i=0;
    
    NSString *name;
    NSString *file;
    
    do{
    name=[NSString stringWithFormat:@"photo-%d.png", i];
    file = [folder stringByAppendingPathComponent:name];
        i++;
        
    }while([fm fileExistsAtPath:file]);
    

    [UIImagePNGRepresentation(image) writeToFile:file atomically:true];
    
    
    NSString *thumb=[file stringByAppendingString:@".thumb.png"];
    [UIImagePNGRepresentation([MKPhotoAnnotation ThumbnailImage:image MaxWidth:40 MaxHeight:40]) writeToFile:thumb atomically:true];
    
    self.path=file;
    
    return self;
    
}
-(UIImage *) getIcon{
    
    NSString *thumb=[_path stringByAppendingString:@".thumb.png"];

    if(![[NSFileManager defaultManager] fileExistsAtPath:thumb]){
        @throw [[NSException alloc] initWithName:@"File Not Found" reason:[NSString stringWithFormat:@"expected file to exist at path: %@",_path] userInfo:nil];
    }
    
    return [[UIImage alloc] initWithContentsOfFile:thumb];

}


-(void)setCoordinate:(CLLocationCoordinate2D)coordinate{
    [super setCoordinate:coordinate];
    
    NSError *err;
    [[NSString stringWithFormat:@"{\"latitude\":%f, \"longitude\":%f}", coordinate.latitude, coordinate.longitude] writeToFile:[_path stringByAppendingString:@".json"] atomically:true encoding:NSUTF8StringEncoding error:&err];

}


+(UIImage *)ThumbnailImage:(UIImage *)image MaxWidth:(float)width MaxHeight:(float)height{
    
    UIImage *theImage=image;
    CGSize sizeContraint = CGSizeMake(width, height);
    CGSize size = CGSizeMake(theImage.size.width, theImage.size.height);
    if(size.width>sizeContraint.width){
        float scale=size.width/sizeContraint.width;
        size.width=sizeContraint.width;
        size.height=size.height/scale;
    }
    if(size.height>sizeContraint.height){
        float scale=size.height/sizeContraint.height;
        size.height=sizeContraint.height;
        size.width=size.width/scale;
    }
    
    
    UIGraphicsBeginImageContext(size);
    
    [theImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return destImage;
    
}


@end
