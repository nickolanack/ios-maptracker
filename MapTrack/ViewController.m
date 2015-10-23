//
//  ViewController.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-19.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "ViewController.h"
#import "SaxKmlParser.h"

#import "MKImageOverlay.h"
#import "MKImageOverlayRenderer.h"

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
@property UIImageView *offScreenUserLocaton;



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
    
    [self loadSampleData];
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
    [self.trackButton setSelected:true];
    //[self.trackButton setBackgroundColor:[UIColor magentaColor]];
}
-(void)stopTrackingLocation{
    
    NSLog(@"Stop tracking");
    self.currentPoints=nil;
    if(self.currentLine){
        [self.mapView removeOverlay:self.currentLine];
        self.currentLine=nil;
    }
    [self.trackButton setSelected:false];
    //[self.trackButton setBackgroundColor:[UIColor whiteColor]];
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
    int c=(int)[self.currentPoints count];
    NSLog(@" Draw line with %d point",c);
    
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKOverlayRenderer *r=nil;
    if([overlay isKindOfClass:[MKImageOverlay class] ]){
    
        NSLog(@"got to imageview");
        MKImageOverlayRenderer *p=[[MKImageOverlayRenderer alloc] initWithOverlay:overlay];
        r=p;
        
        [r setAlpha:0.5];
    
    }else{
    
    
     MKPolylineRenderer *p= [[MKPolylineRenderer alloc]initWithOverlay:overlay];
    [p setStrokeColor:[UIColor blueColor]];
    [p setLineWidth:2.0f];
        r=p;
    }
    
    return r;
    
    
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
    //CLLocationCoordinate2D center=[self.mapView centerCoordinate];
    
    
    int i=0;
    for (MKPointAnnotation *a in annotations) {
        
        
        
        MKMapRect mr=self.mapView.visibleMapRect;
        MKMapPoint p=MKMapPointForCoordinate(a.coordinate);
        if(!MKMapRectContainsPoint(mr, p)){
            
            if(![a isKindOfClass:[MKUserLocation class]]){
                
                
                
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
                
            }else{
                
                if(!self.offScreenUserLocaton){
                    self.offScreenUserLocaton=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userlocation-offscreen-15.png"]];
                    [self.view addSubview:self.offScreenUserLocaton];
                }
                
                [self.offScreenUserLocaton setHidden:false];
                CGPoint intersect=[self calcRectIntersectionPoint:a.coordinate];
                [self.offScreenUserLocaton setCenter:intersect];
                
                
                
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
    
    
    if(self.isMovingRegion){
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

-(void)loadSampleData{
    
    {
    NSString *path=[[NSBundle mainBundle] pathForResource:@"ok-mnt-park.kml" ofType:nil];
    NSError *err;
    NSString *kml=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    [[[SaxKmlParser alloc] initWithDelegate:self] parseString:kml];
    }
    
    {
   // NSString *path=[[NSBundle mainBundle] pathForResource:@"ok-mnt-places.kml" ofType:nil];
   // NSError *err;
   // NSString *kml=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
   // [[[SaxKmlParser alloc] initWithDelegate:self] parseString:kml];
    }

}

-(void) loadMapItemFromDictionary:(NSDictionary *)dictionary{

    //NSLog(@"Placemark: %@", dictionary);
    //[[dictionary valueForKey:@"coordinates"] componentsSeparatedByString:@","];
    
    
   // MKPointAnnotation *p=[[MKPointAnnotation alloc] init];
    
    //p setCoordinate:CLLocationCoordinate2DMake(<#CLLocationDegrees latitude#>, <#CLLocationDegrees longitude#>)
    

}
-(void) loadStyleFromDictionary:(NSDictionary *)dictionary{}
-(void) loadFolderFromDictionary:(NSDictionary *)dictionary{}
-(void) loadGroundOverlayFromDictionary:(NSDictionary *)dictionary{

    NSLog(@"Ground Overlay: %@", dictionary);
    
    MKImageOverlay *o=[[MKImageOverlay alloc] init];
    

    NSString *image=[[dictionary valueForKey:@"href"] stringByReplacingOccurrencesOfString:@"files/" withString:@""];
    
    [o setImage:image];
    [o setRotation:[[dictionary valueForKey:@"rotation"] floatValue]];
    [o setScale:[[dictionary valueForKey:@"viewboundscale"] floatValue]];
    [o setNorth:[[dictionary valueForKey:@"north"] floatValue] South:[[dictionary valueForKey:@"south"] floatValue] East:[[dictionary valueForKey:@"east"] floatValue] West:[[dictionary valueForKey:@"west"] floatValue]];

    [self.mapView addOverlay:o];
    
}


@end
