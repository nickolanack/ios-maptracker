//
//  MKUsersPath.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-27.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "MKUserTracker.h"

@interface MKUserTracker()

@property MKPolyline *currentLine;
@property NSMutableArray *currentPoints;
@property CLLocationManager *lm;
@property float precision;

@property bool isTracking;
@property bool isMonitoring;

@property CLLocation *currentLocation;

@property MKMapView *mapView;

@end

@implementation MKUserTracker

@synthesize delegate;

-(instancetype)initWithMap:(MKMapView *)map{

    self=[super init];
    self.mapView=map;
    
    self.lm = [[CLLocationManager alloc]init];
    [self.lm setDelegate:self];
    
    
    if([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedAlways){
        [self.lm requestAlwaysAuthorization];
    }
    
    [self checkBackgroundRefreshStatusAndNotify];
    return self;

}



-(void)checkBackgroundRefreshStatusAndNotify{
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


-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    if([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedAlways){
        //exit(0);
        NSLog(@"%d", [CLLocationManager authorizationStatus]);
    }else{
        [self startMonitoringLocation];
    }
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    CLLocation *point=[locations lastObject];
    self.currentLocation=point;
    if(self.isTracking){
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
    }else{
        
    }
    
    // NSLog(@"%@", locations);
}


-(void)addedPointToPath{
    
    // check for loops?
    // redraw
    if(self.currentLine){
        [self.mapView removeOverlay:self.currentLine];
    }
    
    
    CLLocationCoordinate2D locations[[self.currentPoints count]];
    
    for (int i=0; i<[self.currentPoints count]; i++) {
        CLLocation *l=[self.currentPoints objectAtIndex:i];
        CLLocationCoordinate2D c=l.coordinate;
        locations[i]= c;
    }
    
    self.currentLine=[MKPolyline polylineWithCoordinates:locations count:[self.currentPoints count]];
    
    [self.mapView addOverlay:self.currentLine];
    int c=(int)[self.currentPoints count];
    NSLog(@" Draw line with %d point",c);
    
}


-(void)startMonitoringLocation{
    
    
    
    [self.mapView setShowsUserLocation:true];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    
    
    //[self.lm startUpdatingHeading];
    [self.lm startUpdatingLocation];
    
    self.isMonitoring=true;
    
}

-(void)stopMonitoringLocation{
    
    [self.lm stopUpdatingLocation];
    self.isMonitoring=false;
}

-(void)startTrackingLocation{
    
    self.isTracking=true;
    //[self.trackButton setBackgroundColor:[UIColor magentaColor]];
}
-(void)stopTrackingLocation{
    
    NSLog(@"Stopped tracking");
    self.currentPoints=nil;
    if(self.currentLine){
        self.currentLine=nil;
    }

    //[self.trackButton setBackgroundColor:[UIColor whiteColor]];
    self.isTracking=false;
    
    
}


@end
