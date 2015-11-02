//
//  MKOffscreenFeatureRenderer.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-27.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "MKOffscreenFeatureRenderer.h"

@interface MKOffscreenFeatureRenderer()

//@property NSMutableArray *lines;
//@property NSMutableArray *points;
@property NSMutableArray *offScreenViews;
@property UIView *offScreenUserLocaton;
@property UIView *view;
@property bool updating;

@end

@implementation MKOffscreenFeatureRenderer

-(instancetype)initWithMap:(MKMapView *)map{
    
    self=[super init];
    
    self.mapView=map;
    self.offScreenViews=[[NSMutableArray alloc] init];
    _view=[self.mapView superview];
    
    return self;
}

@synthesize delegate;



-(void)startUpdating{
    _updating=true;
    [self updateOffscreenItems];
}
-(void)stopUpdating{
    _updating=false;
}





-(void)updateOffscreenItems{
    
    NSArray *annotations= self.mapView.annotations;
    //CLLocationCoordinate2D center=[self.mapView centerCoordinate];
    
    
    int i=0;
    for (MKPointAnnotation *a in annotations) {
        
        
        
        
        MKMapRect mr=self.mapView.visibleMapRect;
        MKMapPoint p=MKMapPointForCoordinate(a.coordinate);
        if(!MKMapRectContainsPoint(mr, p)){
            
            if([self.delegate shouldRenderViewForOffscreenPointFeature:a]){
                
                if(![a isKindOfClass:[MKUserLocation class]]){
                    
                    
                    
                    UIView *image;
                    if([self.offScreenViews count] >i){
                        image=[self.offScreenViews objectAtIndex:i];
                    }else{
                        image=[self.delegate viewForOffscreenPointFeature:a];
                        if(!image){
                            image=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"waypoint-offscreen-15.png"]];
                        }
                        
                        [self.offScreenViews addObject:image];
                        [self.view addSubview:image];
                        
                    }
                    
                    
                    CGPoint intersect=[self calcRectIntersectionPoint:a.coordinate];
                    [image setCenter:intersect];
                    
                    
                    i++;
                    
                }else{
                    
                    if(!self.offScreenUserLocaton){
                        self.offScreenUserLocaton=[self.delegate viewForOffscreenPointFeature:a];
                        if(!self.offScreenUserLocaton){
                            self.offScreenUserLocaton=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userlocation-offscreen-15.png"]];
                        }
                        
                        [self.view addSubview:self.offScreenUserLocaton];
                    }
                    
                    [self.offScreenUserLocaton setHidden:false];
                    CGPoint intersect=[self calcRectIntersectionPoint:a.coordinate];
                    [self.offScreenUserLocaton setCenter:intersect];
                    
                    
                    
                }
        }
    }else{
        if([a isKindOfClass:[MKUserLocation class]]){
            [self.offScreenUserLocaton setHidden:true];
        }
        
        
    }
    
}
int c=(int)[self.offScreenViews count];
for(int j=c-1; j>=i; j--){
    UIImageView *v= [self.offScreenViews objectAtIndex:j];
    [self.offScreenViews removeObjectAtIndex:j];
    [v removeFromSuperview];
    v=nil;
}


if(_updating){
    [self performSelector:@selector(updateOffscreenItems) withObject:nil afterDelay:0.05];
}

}


-(CGPoint)calcRectIntersectionPoint:(CLLocationCoordinate2D) coord{
    
    CGPoint p=[self.mapView convertCoordinate:coord toPointToView:self.mapView];
    CGRect r=self.mapView.frame;
    CGPoint c=CGPointMake((r.size.width/2.0), (r.size.height/2.0));
    
    float angle=[self angleFromPoint:p toCenter:c];
    
    float tr_angle=[self angleFromPoint:CGPointMake(r.size.width, 0) toCenter:c];
    float br_angle=[self angleFromPoint:CGPointMake(r.size.width, r.size.height) toCenter:c];
    
    float tl_angle=[self angleFromPoint:CGPointMake(0, 0) toCenter:c];
    float bl_angle=[self angleFromPoint:CGPointMake(0, r.size.height) toCenter:c];
    
    float x=0;
    float y=0;
    
    if(tl_angle>angle&&tr_angle<=angle){
        //top
        //y=0;
        x=r.size.width/2.0;
        if(angle!=M_PI_2){
            x=x-((-r.size.height/2.0)/tan(angle));
            
        }
        
    }else if(bl_angle>angle&&tl_angle<=angle){
        //left
        //x=0;
        y=r.size.height/2.0;
        if(angle!=M_PI){
            y=y-(r.size.width/2.0)*tan(M_PI-angle);
        }
        
    }else if(br_angle>angle&&bl_angle<=angle){
        //bottom
        y=r.size.height;
        x=r.size.width/2.0;
        if(angle!=(3*M_PI_2)){
            x=x-y*tan(3*M_PI_2-angle);
        }
        
    }else{
        //right
        x=r.size.width-10;
        y=r.size.height/2.0;
        if(angle!=0){
            if(angle>M_PI){
                //overflow
                angle=angle-2*M_PI; //do want a negative angle for overflow
            }
            y=y-(r.size.width/2.0)*tan(angle);
            
        }
    }
    
    
    return CGPointMake(x, y);
}

-(float)angleFromPoint:(CGPoint) p toCenter:(CGPoint)c{
    float dx=p.x-c.x;
    float dy=p.y-c.y;
    dy=-dy; //flip y axis so that my math is easier
    if(dy==0){
        if(dx>0){
            return 0;
        }
        return M_PI;
    }
    
    float h=sqrtf(powf(dx, 2)+powf(dy,2));
    float angle= asinf(dy/h);
    
    if(dy>=0&&dx<0){
        return M_PI-angle;
    }
    
    if(dx<0&&dy<0){
        return M_PI-angle;
    }
    
    if(dx>=0&&dy<0){
        return 2*M_PI+angle;
    }
    
    return angle;
    
}


@end
