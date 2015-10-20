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
@property CLLocationManager *lm;
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

-(void)checkBackgroundRefresStatusAndNotify{
    UIAlertView * alert;
    //We have to make sure that the Background app Refresh is enabled for the Location updates to work in the background.
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied)
    {
        
        // The user explicitly disabled the background services for this app or for the whole system.
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"MapTracker has been explicitly denied access to update in the background. To turn it on, go to Settings > General > Background app Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
    {
        
        // Background services are disabled and the user cannot turn them on.
        // May occur when the device is restricted under parental control.
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"MapTracker has been restricted, adn will be unable to operate in the background"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else
    {
        
        // Background service is enabled, you can start the background supported location updates process
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
    
    //[self.lm startUpdatingHeading];
    [self.lm startUpdatingLocation];

}

-(void)stopTracking{

     [self.lm stopUpdatingLocation];

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
    NSLog(@"Got Location");
    // NSLog(@"%@", locations);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
 // NSLog(@"%@", newHeading);
}

-(void)addedPointToPath{

    // check for loops?
    // redraw
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
