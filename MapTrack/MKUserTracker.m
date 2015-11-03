//
//  MKUsersPath.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-27.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "MKUserTracker.h"
#import "SaxKmlParser.h"
#import "MKStyledPolyline.h"

@interface MKUserTracker()

@property MKStyledPolyline *currentPath;
@property NSMutableArray *previousPaths;
@property NSMutableArray *currentPoints;
@property CLLocationManager *lm;
@property float precision;

@property bool isTrackingLocation;
@property bool isTrackingHeading;

@property bool isLogging;
@property NSFileHandle *locationLogFileHandle;
@property int *logCount;

@property MKMapView *mapView;

@property bool isMovingWithLocation;
@property bool isRotatingWithLocation;

@property NSDate *startDate;


@property float distance;

@end

@implementation MKUserTracker

@synthesize delegate, currentLocation, pathColor, pathWidth;

-(instancetype)initWithMap:(MKMapView *)map{
    
    self=[self init];
    self.mapView=map;
    
    _lm = [[CLLocationManager alloc]init];
    [_lm setDelegate:self];
    
    if([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedAlways){
        [_lm requestAlwaysAuthorization];
    }
    
    [self checkBackgroundRefreshStatusAndNotify];
    [self restoreUserPathFeatures];
    
    // when _isLogging is set to true, then this class instance will record all
    // location samples to file. which can be used for debuging, or for generating unit tests.
    _isLogging=true;
    
    return self;
    
}

-(instancetype)init{
    self =[super init];
    
    self.pathWidth=0.5;
    self.pathColor=[UIColor blueColor];
    
    return self;
}

-(void)startLogging{
    
    NSString *log;    NSFileManager *fm=[NSFileManager defaultManager];
    int i=0;
    do{
    
        log=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"locationlog-%d.json", i]];
        i++;
        
    }while([fm fileExistsAtPath:log]);
    
    [fm createFileAtPath:log contents:nil attributes:nil];
    _locationLogFileHandle = [NSFileHandle fileHandleForWritingAtPath:log];
     [_locationLogFileHandle writeData:[@"[\n" dataUsingEncoding:NSUTF8StringEncoding]];
    _logCount=0;
    
    
    
}
-(void)log:(CLLocation *)location{
    if(_locationLogFileHandle){
        NSString *data=[NSString stringWithFormat:@"%@{\"lat\":%f, \"lng\":%f, \"alt\":%f, \"spd\":%f, \"crs\":%f, \"tms\":%f, \"h-ac\":%f, \"v-ac\":%f}\n", (_logCount==0?@"   ":@",\n   "),location.coordinate.latitude, location.coordinate.longitude, location.altitude, location.speed, location.course, [location.timestamp timeIntervalSince1970], location.horizontalAccuracy, location.verticalAccuracy];
        
        [_locationLogFileHandle writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
        _logCount++;
    }
}
-(void)stopLogging{
    [_locationLogFileHandle writeData:[@"\n]" dataUsingEncoding:NSUTF8StringEncoding]];
    [_locationLogFileHandle closeFile];
       _locationLogFileHandle=nil;
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
                                          message:@"MapTracker has been restricted, and will be unable to operate in the background"
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
    currentLocation=point;
    
    if(_isLogging){
        [self log:point];
    }
    
    
    if(_isTrackingLocation){
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

    NSLog(@"%@",newHeading);
    

}


-(void)addedPointToPath{
    
    // check for loops?
    // redraw
    if(_currentPath&&self.mapView){
        [self.mapView removeOverlay:_currentPath];
    }
    
    
    CLLocationCoordinate2D locations[[self.currentPoints count]];
    
    for (int i=0; i<[self.currentPoints count]; i++) {
        CLLocation *l=[self.currentPoints objectAtIndex:i];
        CLLocationCoordinate2D c=l.coordinate;
        locations[i]= c;
    }
    
    _currentPath=[MKStyledPolyline polylineWithCoordinates:locations count:[self.currentPoints count]];
    
    if(self.mapView){
        [self.mapView addOverlay:_currentPath];
    }
    int c=(int)[self.currentPoints count];
    NSLog(@" Draw line with %d point",c);
    
    
    [self updateDistance];
    
    
}

-(void)updateDistance{
    
    double oldDistance=_distance;
    
    if(self.currentPoints&&self.currentPoints.count>1){
        
        CLLocation *newCoordinate = [self.currentPoints objectAtIndex:self.currentPoints.count-1];
        CLLocation *oldCoordinate = [self.currentPoints objectAtIndex:self.currentPoints.count-2];
        
        double meters=[newCoordinate distanceFromLocation:oldCoordinate];
    
        if(meters>0){
            _distance=_distance+meters;
            [self.delegate userTrackerDistanceDidChange:_distance From:oldDistance];
        }
        
    }else if(_distance>0){
        _distance=0;
        [self.delegate userTrackerDistanceDidChange:_distance From:oldDistance];
    
    }
    
    
    
   
    

    

}


-(void)startMonitoringLocation{
    
    
    if(self.mapView){
        [self.mapView setShowsUserLocation:true];
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    }
    
    
    [_lm startUpdatingLocation];
    
}

-(void)stopMonitoringLocation{
    [_lm stopUpdatingLocation];
}

-(void)startTrackingLocation{
    
    _isTrackingLocation=true;
    //[self.trackButton setBackgroundColor:[UIColor magentaColor]];
    if(_isLogging){
        [self startLogging];
    }
    
    
    _startDate = [NSDate date];
    [self updateDistance];
    
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
    _isTrackingLocation=false;
    
    if(_isLogging){
        [self stopLogging];
    }
    
    _startDate=nil;
    
}

-(NSTimeInterval) getTimeInterval{
    if(_startDate!=nil){
        
        return -[_startDate timeIntervalSinceNow];
    }else{
        return 0;
    }
}

-(void)restoreUserPathFeatures{
    
    NSString *file = [[NSHomeDirectory()
                       stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"_yourpath.kml"];
    NSFileManager *f=[NSFileManager defaultManager];
    if([f fileExistsAtPath:file]){
        
        NSLog(@"Restoring User File: %@", file);
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
    
    
    MKStyledPolyline * p= [MKStyledPolyline polylineWithCoordinates:locations count:[coordinateStrings count]];
    
    [p setColor:[SaxKmlParser ParseColorString:[dictionary objectForKey:@"color"]]];
    [p setWidth:[[dictionary objectForKey:@"width"] floatValue]];
    
    [_mapView addOverlay:p];
    [self addPolylineToPreviousPaths:p];
    
}

-(void)addPolylineToPreviousPaths:(MKStyledPolyline *) path{
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
                       stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"_yourpath.kml"];
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

-(NSString *)polyline:(MKStyledPolyline *) polyline ToKmlString:(NSString *) name{
    
    
    NSString *kmlSnippit=[NSString stringWithFormat:@"<Placemark><name>%@</name><LineString><tessellate>1</tessellate><coordinates>", name];
    for(int i=0;i<polyline.pointCount;i++){
        
        CLLocationCoordinate2D c=MKCoordinateForMapPoint(polyline.points[i]);
        kmlSnippit=[kmlSnippit stringByAppendingString:[NSString stringWithFormat:@"%f,%f,0 ",c.longitude,c.latitude]];
        
    }
    kmlSnippit=[kmlSnippit stringByAppendingString:@"</coordinates></LineString></Placemark>"];
    
    
    return kmlSnippit;
    
}



-(void)startMovingWithLocation{
    _isMovingWithLocation=true;
    [self updateUserFollowMode];
}
-(void)stopMovingWithLocation{
    _isMovingWithLocation=false;
    [self updateUserFollowMode];
}

-(void)startRotatingWithHeading{
    _isRotatingWithLocation=true;
    [self updateUserFollowMode];

}
-(void)stopRotatingWithHeading{
    _isRotatingWithLocation=false;
    [self updateUserFollowMode];

}


-(void)updateUserFollowMode{

    if(!self.mapView){
        @throw [[NSException alloc] initWithName:@"Null MKMapView" reason:@"Attempted to update user tracking mode with nil MKMapView" userInfo:nil];
    }
    if(_isMovingWithLocation){
        if(_isRotatingWithLocation){
            [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
        }else{
            [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        }
        //[_mapView setCenterCoordinate:point.coordinate animated:true];
    }else{
        [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    }
}




@end
