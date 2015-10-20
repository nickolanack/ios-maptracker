//
//  ViewController.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-19.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property MKPolyline *currentLine;
@property NSMutableArray *currentPoints;

@property float precision;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.precision=5.0f;
    
    /*
     * Initialize the track with a fake starting point.
     *
    self.currentPoints =[[NSMutableArray alloc] initWithObjects:[[CLLocation alloc ] initWithCoordinate:CLLocationCoordinate2DMake(49.0f, -119.0f) altitude:0 horizontalAccuracy:1 verticalAccuracy:1 timestamp:[NSDate date]], nil];
    */
    self.lm = [[CLLocationManager alloc]init];
    [self.lm setDelegate:self];
    [self.mapView setDelegate:self];
    
    
    if([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedAlways){
        [self.lm requestAlwaysAuthorization];
    }
  
    
}



-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{

    
    if([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedAlways){
        [self startTracking];
    }
    
}

-(void)startTracking{

    [self.mapView setShowsUserLocation:true];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    self.currentLine=[[MKPolyline alloc] init];
    [self.mapView addOverlay:self.currentLine];
    
    [self.lm startUpdatingHeading];
    [self.lm startUpdatingLocation];

}

-(void)stopTracking{

    

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    if([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedAlways){
        //exit(0);
        NSLog(@"%d", [CLLocationManager authorizationStatus]);
    }else{
        [self startTracking];
    }

}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    CLLocation *point=[locations lastObject];
    
    if(!self.currentPoints){
        self.currentPoints=[[NSMutableArray alloc] initWithObjects:point, nil];
    }else{
    
        if([self.currentPoints count]){
            
            if([point distanceFromLocation:[self.currentPoints lastObject]]>self.precision){
            
                [self.currentPoints addObject:point];
                [self addedPointToPath];
            }
          
        
        }
    
    }
    //NSLog(@"%@", locations);
}



-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
 //NSLog(@"%@", newHeading);

}

-(void)addedPointToPath{

    //check for loops?
    //redraw
    
    [self.mapView removeOverlay:self.currentLine];

    CLLocationCoordinate2D locations[[self.currentPoints count]];
    
    for (int i=0; i<[self.currentPoints count]; i++) {
        CLLocation *l=[self.currentPoints objectAtIndex:i];
        CLLocationCoordinate2D c=l.coordinate;
        locations[i]= c;
    }
    
    
    self.currentLine=[MKPolyline polylineWithCoordinates:locations count:[self.currentPoints count]];
  
    [self.mapView addOverlay:self.currentLine];
    NSLog(@" Draw line with %d point",[self.currentPoints count]);

}
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    
   MKPolylineRenderer *p= [[MKPolylineRenderer alloc]initWithOverlay:overlay];
    [p setStrokeColor:[UIColor blueColor]];
    [p setLineWidth:2.0f];
 
    return p;
    

}


@end
