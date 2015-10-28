//
//  MKUsersPath.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-27.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "MKUserTracker.h"
#import "SaxKmlParser.h"

@interface MKUserTracker()

@property MKPolyline *currentPath;
@property NSMutableArray *previousPaths;
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
    
    _lm = [[CLLocationManager alloc]init];
    [_lm setDelegate:self];
    
    if([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedAlways){
        [_lm requestAlwaysAuthorization];
    }
    
    [self checkBackgroundRefreshStatusAndNotify];
    [self restoreUserPathFeatures];
    
    
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
    if(_currentPath){
        [self.mapView removeOverlay:_currentPath];
    }
    
    
    CLLocationCoordinate2D locations[[self.currentPoints count]];
    
    for (int i=0; i<[self.currentPoints count]; i++) {
        CLLocation *l=[self.currentPoints objectAtIndex:i];
        CLLocationCoordinate2D c=l.coordinate;
        locations[i]= c;
    }
    
    _currentPath=[MKPolyline polylineWithCoordinates:locations count:[self.currentPoints count]];
    
    [self.mapView addOverlay:_currentPath];
    int c=(int)[self.currentPoints count];
    NSLog(@" Draw line with %d point",c);
    
}


-(void)startMonitoringLocation{
    
    
    
    [self.mapView setShowsUserLocation:true];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    
    
    //[_lm startUpdatingHeading];
    [_lm startUpdatingLocation];
    
    self.isMonitoring=true;
    
}

-(void)stopMonitoringLocation{
    
    [_lm stopUpdatingLocation];
    self.isMonitoring=false;
}

-(void)startTrackingLocation{
    
    self.isTracking=true;
    //[self.trackButton setBackgroundColor:[UIColor magentaColor]];
}
-(void)stopTrackingLocation{
    
    NSLog(@"Stopped tracking");
    self.currentPoints=nil;
    if(_currentPath){
        [self storeUserPathFeatures];
        [self addPolylineToPreviousPaths:_currentPath];
        _currentPath=nil;
    }
    
    //[self.trackButton setBackgroundColor:[UIColor whiteColor]];
    self.isTracking=false;
    
}

-(void)restoreUserPathFeatures{
    
    NSString *file = [[NSHomeDirectory()
                       stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"yourpath.kml"];
    NSFileManager *f=[NSFileManager defaultManager];
    if([f fileExistsAtPath:file]){
        
        NSLog(@"File Exists");
        NSError *err;
        SaxKmlParser *parser=[[SaxKmlParser alloc] init];
        [parser setDelegate:self];
        [parser parseString:[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&err]];
        
    }
    
}

-(void) onKmlPlacemark:(NSDictionary *)dictionary{}
-(void) onKmlPolyline:(NSDictionary *)dictionary{
    
    NSArray *coordinateStrings=[SaxKmlParser ParseCoordinateArrayString:[dictionary objectForKey:@"coordinates"]];
    CLLocationCoordinate2D locations[[coordinateStrings count]];
    
    for (int i=0; i<[coordinateStrings count]; i++) {
        locations[i]= [SaxKmlParser ParseCoordinateString:[coordinateStrings objectAtIndex:i]];
    }
    
    
    MKPolyline * p= [MKPolyline polylineWithCoordinates:locations count:[coordinateStrings count]];
    
    [_mapView addOverlay:p];
    [self addPolylineToPreviousPaths:p];
    
}

-(void)addPolylineToPreviousPaths:(MKPolyline *) path{
    if(!_previousPaths){
        _previousPaths=[[NSMutableArray alloc] init];
    }
    
    [_previousPaths addObject:path];
    
}

-(void) onKmlPolygon:(NSDictionary *)dictionary{}
-(void) onKmlStyle:(NSDictionary *)dictionary{}
-(void) onKmlFolder:(NSDictionary *)dictionary{}
-(void) onKmlGroundOverlay:(NSDictionary *)dictionary{}

-(void)storeUserPathFeatures{
    
    NSString *file = [[NSHomeDirectory()
                       stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"yourpath.kml"];
    NSError *err;
    
    
    NSString *kml=@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\" xmlns:kml=\"http://www.opengis.net/kml/2.2\" xmlns:atom=\"http://www.w3.org/2005/Atom\"><Document>";
    
    
    for(int i=0;i<_previousPaths.count;i++){
        kml=[kml stringByAppendingString:[self polyline:[_previousPaths objectAtIndex:i] ToKmlString:[NSString stringWithFormat:@"Previous Path %i", i]]];
    }
    
    kml=[kml stringByAppendingString:[self polyline:_currentPath ToKmlString:@"Your Path"]];
    kml=[kml stringByAppendingString:@"</Document></kml>"];
    
    
    [kml writeToFile:file atomically:true encoding:NSUTF8StringEncoding error:&err];
    if(err){
        NSLog(@"%@", err.description);
    }
    
}

-(NSString *)polyline:(MKPolyline *) polyline ToKmlString:(NSString *) name{
    
    
    NSString *kmlSnippit=[NSString stringWithFormat:@"<Placemark><name>%@</name><LineString><tessellate>1</tessellate><coordinates>", name];
    for(int i=0;i<polyline.pointCount;i++){
        
        CLLocationCoordinate2D c=MKCoordinateForMapPoint(polyline.points[i]);
        kmlSnippit=[kmlSnippit stringByAppendingString:[NSString stringWithFormat:@"%f,%f,0 ",c.longitude,c.latitude]];
        
    }
    kmlSnippit=[kmlSnippit stringByAppendingString:@"</coordinates></LineString></Placemark>"];
    
    
    return kmlSnippit;
    
}

@end