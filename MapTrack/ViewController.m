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

@property bool isTracking;
@property bool isMonitoring;

@property bool isMovingRegion;

@property CLLocation *currentLocation;


//@property NSMutableArray *lines;
//@property NSMutableArray *points;
@property NSMutableArray *offScreenViews;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.precision=5.0f;
    self.isTracking=false;
    self.isMonitoring=false;
    self.isMovingRegion=false;
    
    /*
     * Initialize the track with a fake starting point.
     *
     self.currentPoints =[[NSMutableArray alloc] initWithObjects:[[CLLocation alloc ] initWithCoordinate:CLLocationCoordinate2DMake(49.0f, -119.0f) altitude:0 horizontalAccuracy:1 verticalAccuracy:1 timestamp:[NSDate date]], nil];
     */
    self.lm = [[CLLocationManager alloc]init];
    [self.lm setDelegate:self];
    [self.mapView setDelegate:self];
    
    self.offScreenViews=[[NSMutableArray alloc] init];
    
    //NSMutableArray *lines=[[NSMutableArray alloc] init];
    //NSMutableArray *points=[[NSMutableArray alloc] init];
    
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
        [self startMonitoringLocation];
    }
    
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
    [self.trackButton setBackgroundColor:[UIColor magentaColor]];
}
-(void)stopTrackingLocation{
    
    NSLog(@"Stop tracking");
    self.currentPoints=nil;
    if(self.currentLine){
        [self.mapView removeOverlay:self.currentLine];
        self.currentLine=nil;
    }
    [self.trackButton setBackgroundColor:[UIColor whiteColor]];
    self.isTracking=false;
    
    
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if([alertView.title isEqualToString:@"End Tracking"]){
        
        if(buttonIndex==1){
            MKPolyline *p=self.currentLine;
            // [self.lines addObject:p];
            [self stopTrackingLocation];
            [self.mapView addOverlay:p];
        }
        
        if(buttonIndex==2){
            [self stopTrackingLocation];
            
        }
        
        if(buttonIndex==0){
            //do nothing... cancel
        }
        
        
        
    }
    
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

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    // NSLog(@"%@", newHeading);
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
    NSLog(@" Draw line with %d point",[self.currentPoints count]);
    
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    
    MKPolylineRenderer *p= [[MKPolylineRenderer alloc]initWithOverlay:overlay];
    [p setStrokeColor:[UIColor blueColor]];
    [p setLineWidth:2.0f];
    
    return p;
    
    
}



-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    
    
    MKAnnotationView *p=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    [p setImage:[UIImage imageNamed:@"waypoint-default-25x28.png"]];
    [p setDraggable:true];
    
    return p;
}
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState{
    
    if (newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = view.annotation.coordinate;
        NSLog(@"dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        
        [view setDragState:MKAnnotationViewDragStateNone];
    }
    
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    self.isMovingRegion=true;
   [self updateOffscreenItems];
    
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
     self.isMovingRegion=false;
     [self updateOffscreenItems];
}




-(void)updateOffscreenItems{
   
    NSArray *annotations= self.mapView.annotations;
    CLLocationCoordinate2D center=[self.mapView centerCoordinate];
    int i=0;
    for (MKPointAnnotation *a in annotations) {
        MKMapRect mr=self.mapView.visibleMapRect;
        MKMapPoint p=MKMapPointForCoordinate(a.coordinate);
        if(!MKMapRectContainsPoint(mr, p)){
            
            UIImageView *image;
            if([self.offScreenViews count] >i){
                image=[self.offScreenViews objectAtIndex:i];
            }else{;
                image=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"waypoint-offscreen-15.png"]];
                [self.offScreenViews addObject:image];
                [self.view addSubview:image];
                
            }
            
            
            CGPoint intersect=[self calcRectIntersectionPoint:a.coordinate];
            [image setCenter:intersect];

            
            i++;
        }
        
    }
    
     NSLog(@"update offscreen: %d (%d)", i, [self.offScreenViews count]);
    for(int j=[self.offScreenViews count]-1; j>=i; j--){
        NSLog(@"remove %d",j);
        UIImageView *v= [self.offScreenViews objectAtIndex:j];
        [self.offScreenViews removeObjectAtIndex:j];
        [v removeFromSuperview];
        v=nil;
    }
    
    
    if(self.isMovingRegion){
        [self performSelector:@selector(updateOffscreenItems) withObject:nil afterDelay:0.1];
    }
    
}


-(CGPoint)calcRectIntersectionPoint:(CLLocationCoordinate2D) coord{
    
    CGPoint p=[self.mapView convertCoordinate:coord toPointToView:self.view];

    return CGPointMake(0, 0);
}

- (IBAction)onTrackButtonClick:(id)sender {
    
    if(!self.isTracking){
        [self startTrackingLocation];
    }else{
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"End Tracking"message:@"What do you want to do with your current track" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"keep it on the map", @"discard it", nil];
        [alert show];
        
        
    }
}

- (IBAction)onWaypointButtonClick:(id)sender {
    
    
    MKPointAnnotation *point=[[MKPointAnnotation alloc] init];
    //[point setCoordinate:self.currentLocation.coordinate];
    [point setCoordinate:self.mapView.centerCoordinate];
    
    //[self.points addObject:point];
    [self.mapView addAnnotation:point];
    
}

@end
