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
#import "MKOffscreenFeatureRenderer.h"
#import "MKUserTracker.h"

@interface ViewController ()


@property MKUserTracker *tracker;
@property MKOffscreenFeatureRenderer *offscreenRenderer;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    [self.mapView setDelegate:self];
    self.tracker=[[MKUserTracker alloc] initWithMap:self.mapView];
    //[self.tracker setDelegate:self];
    
    [self loadSampleData];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKOverlayRenderer *r=nil;
    if([overlay isKindOfClass:[MKImageOverlay class] ]){
        // this is my custom image overlay class
        MKImageOverlayRenderer *p=[[MKImageOverlayRenderer alloc] initWithOverlay:overlay];
        r=p;
        
        if([self.onOverlaysButton isSelected]){
            [r setAlpha:0.5];
        }else{
            [r setAlpha:0.1];
        }
        
        
        
    
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
-(UIView *)viewForOffscreenPointFeature:(MKPointAnnotation *)point{
    return nil;
}
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    
    
    if(!_offscreenRenderer){
        _offscreenRenderer=[[MKOffscreenFeatureRenderer alloc] initWithMap:self.mapView];
        [_offscreenRenderer setDelegate:self];
    }
    
    [_offscreenRenderer startUpdating];

    
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
     [_offscreenRenderer stopUpdating];
}




- (IBAction)onTrackButtonClick:(id)sender {
    
    if(!self.trackButton.isSelected){
        [self.trackButton setSelected:true];
        [self.tracker startTrackingLocation];
       
    }else{

        [self.trackButton setSelected:false];
         [self.tracker stopTrackingLocation];
        
        
    }
}

- (IBAction)onWaypointButtonClick:(id)sender {
    
    
    MKPointAnnotation *point=[[MKPointAnnotation alloc] init];
    [point setCoordinate:self.mapView.centerCoordinate];
    
    //[self.points addObject:point];
    [self.mapView addAnnotation:point];
    
}

- (IBAction)onOverlaysButtonClick:(id)sender {
    [self.onOverlaysButton setSelected:![sender isSelected]];
    for(id o in self.mapView.overlays) {
       
        [self.mapView removeOverlay:o];
        [self.mapView addOverlay:o];
        
        //[o setNeedsDisplay];
    }
}

- (IBAction)onUserLocationClick:(id)sender {
    
    for(id o in self.mapView.annotations) {
        
        if([o isKindOfClass:[MKUserLocation class]]){
            
            MKUserLocation *u=o;

            MKMapRect mr=self.mapView.visibleMapRect;
        
            MKMapPoint p=MKMapPointForCoordinate(u.coordinate);
            if(!MKMapRectContainsPoint(mr, p)){
                [self.mapView setCenterCoordinate:u.coordinate];
            }
        }
    }
}

-(void)loadSampleData{
    
    {
        NSString *path=[[NSBundle mainBundle] pathForResource:@"ok-mnt-park.kml" ofType:nil];
        NSError *err;
        NSString *kml=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
        [[[SaxKmlParser alloc] initWithDelegate:self] parseString:kml];
    }
    
    {
        NSString *path=[[NSBundle mainBundle] pathForResource:@"ok-mnt-places.kml" ofType:nil];
        NSError *err;
        NSString *kml=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
        [[[SaxKmlParser alloc] initWithDelegate:self] parseString:kml];
    }
    
    
    {
        NSString *path=[[NSBundle mainBundle] pathForResource:@"ok-mnt-wild-horse-canyon.kml" ofType:nil];
        NSError *err;
        NSString *kml=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
        [[[SaxKmlParser alloc] initWithDelegate:self] parseString:kml];
    }
    
}

-(void) onKmlPlacemark:(NSDictionary *)dictionary{

    
    MKPointAnnotation *point=[[MKPointAnnotation alloc] init];
    [point setCoordinate:[SaxKmlParser ParseCoordinateString:[dictionary valueForKey:@"coordinates"]]];
    [self.mapView addAnnotation:point];
    
    

}
-(void) onKmlStyle:(NSDictionary *)dictionary{}
-(void) onKmlFolder:(NSDictionary *)dictionary{}
-(void) onKmlGroundOverlay:(NSDictionary *)dictionary{

    NSLog(@"Ground Overlay: %@", dictionary);
    
    MKImageOverlay *o=[[MKImageOverlay alloc] init];
    

    NSString *image=[[dictionary valueForKey:@"href"] stringByReplacingOccurrencesOfString:@"files/" withString:@""];
    
    [o setImage:image];
    [o setRotation:[[dictionary valueForKey:@"rotation"] floatValue]];
    [o setScale:[[dictionary valueForKey:@"viewboundscale"] floatValue]];
    [o setNorth:[[dictionary valueForKey:@"north"] floatValue] South:[[dictionary valueForKey:@"south"] floatValue] East:[[dictionary valueForKey:@"east"] floatValue] West:[[dictionary valueForKey:@"west"] floatValue]];

    [self.mapView addOverlay:o];
    
}
-(void)onKmlPolyline:(NSDictionary *)dictionary{
    

    
    NSArray *coordinateStrings=[SaxKmlParser ParseCoordinateArrayString:[dictionary objectForKey:@"coordinates"]];
    CLLocationCoordinate2D locations[[coordinateStrings count]];
    
    for (int i=0; i<[coordinateStrings count]; i++) {
        locations[i]= [SaxKmlParser ParseCoordinateString:[coordinateStrings objectAtIndex:i]];
    }
 
    
    MKPolyline * p= [MKPolyline polylineWithCoordinates:locations count:[coordinateStrings count]];

    [self.mapView addOverlay:p];
    
}
-(void)onKmlPolygon:(NSDictionary *)dictionary{}


@end
