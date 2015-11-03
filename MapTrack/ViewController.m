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
#import "MKPhotoAnnotation.h"
#import "MKPlacemarkAnnotation.h"
#import "MKStyledPolyline.h"
#import "MKPolylineTapDetector.h"

@interface ViewController ()


@property MKUserTracker *tracker;
@property MKOffscreenFeatureRenderer *offscreenRenderer;
@property MKPolylineTapDetector *tapDetector;

@end

@implementation ViewController


#pragma mark Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [self.mapView setDelegate:self];
    self.tracker=[[MKUserTracker alloc] initWithMap:self.mapView];
    [self.tracker setDelegate:self];
    
    [self loadUsersKmlFiles];
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];

    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    
    
    _tapDetector=[[MKPolylineTapDetector alloc] initWithMap:self.mapView];
    [_tapDetector setDelegate:self];
    
    
}

-(void) onPolylineTap:(MKPolyline *)polyline{


}

-(void)updateTimer{

    NSString *timeStr=@"";
    int seconds=[_tracker getTimeInterval];
    if(seconds>60){
        int minutes=seconds/60;
        if(minutes>60){
            int hours=minutes/60;
            timeStr=[timeStr stringByAppendingString:[NSString stringWithFormat:@"%i:", hours]];
        }
        timeStr=[timeStr stringByAppendingString:[NSString stringWithFormat:(minutes<10?@"%i:":@"%02i:"), minutes%60]];
    }
    timeStr=[timeStr stringByAppendingString:[NSString stringWithFormat:(seconds<10?@"%i":@"%02i"), seconds%60]];
    
    self.trackTime.text=timeStr;
    
}

-(void)loadUsersKmlFiles{
    
    NSString *folder=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *fm =[NSFileManager defaultManager];
    NSError *err;
    NSArray *paths=[fm contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] error:&err];
    for (NSString *path in paths) {
        NSLog(@"%@", path);
        
        NSString *ext=[path substringFromIndex:path.length-4];
        
        
        if([ext isEqualToString:@".kml"]&&(!([path characterAtIndex:0]=='.'))){
            
            NSError *err;
            NSString *kml=[NSString stringWithContentsOfFile:[folder stringByAppendingPathComponent:path] encoding:NSUTF8StringEncoding error:&err];
            [[[SaxKmlParser alloc] initWithDelegate:self] parseString:kml];
        }
    }
    
}

#pragma mark Map View

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
        
        if([overlay isKindOfClass:[MKStyledPolyline class]]){
            
            [p setStrokeColor:((MKStyledPolyline *) overlay).color];
            [p setLineWidth:((MKStyledPolyline *) overlay).width];
        
        }else{
        
        [p setStrokeColor:[UIColor blueColor]];
        [p setLineWidth:2.0f];
            
        }
        r=p;
    }
    
    return r;
    
    
}



-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    
    MKAnnotationView *p=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    
    if([annotation isKindOfClass:[MKPhotoAnnotation class]]){
        [p setImage:[((MKPhotoAnnotation *) annotation) getIcon]];
    }else if([annotation isKindOfClass:[MKPlacemarkAnnotation class]]){
        
        [p setImage:[((MKPlacemarkAnnotation *) annotation) getIcon]];
        [p setCanShowCallout:true];
        [p setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
        
    }else{
        [p setImage:[UIImage imageNamed:@"waypoint-default-25x28.png"]];
        [p setCanShowCallout:true];
        [p setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
        
    }
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

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{

    NSLog(@"Callout Tapped");

}

-(bool)shouldRenderViewForOffscreenPointFeature:(MKPointAnnotation *)point {
    return true;
}
-(UIView *)viewForOffscreenPointFeature:(MKPointAnnotation *)point{
    
    if([point isKindOfClass:[MKUserLocation class]]){
        return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userlocation-offscreen-15.png"]];
    }else{
        return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"waypoint-offscreen-15.png"]];
    }
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

-(void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated{
    if(mode==MKUserTrackingModeFollowWithHeading){
        [self.lockLocationButton setSelected:true];
    }else{
        [self.lockLocationButton setSelected:false];
    }
    
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{

    NSLog(@"Annotation Selected");

}

#pragma mark Button Clicks

- (IBAction)onTrackButtonClick:(id)sender {
    
    if(!self.trackButton.isSelected){
        [self.trackButton setSelected:true];
        [self.tracker startTrackingLocation];
        
    }else{
        
        [self.trackButton setSelected:false];
        [self.tracker stopTrackingLocation];
    }
    
    [self.trackInfoBar setHidden:!self.trackButton.selected];
}

- (IBAction)onWaypointButtonClick:(id)sender {
    [self toggleWaypointMenu];
}


-(void)toggleWaypointMenu{
    
    [self.waypointButton setSelected:!self.waypointButton.isSelected];
    [self.markerDropButton setHidden:!self.waypointButton.isSelected];
    [self.takePhotoButton setHidden:!self.waypointButton.isSelected];
    
    
    
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
    
    [self.locatonButton setSelected:!self.locatonButton.selected];
    
    if(self.locatonButton.selected){
       

        
            MKMapRect mr=self.mapView.visibleMapRect;
            
            MKMapPoint p=MKMapPointForCoordinate(_tracker.currentLocation.coordinate);
            if(!MKMapRectContainsPoint(mr, p)){
                [self.mapView setCenterCoordinate:_tracker.currentLocation.coordinate animated:true];
            }
    }
    
    
    [self.lockLocationButton setHidden:!self.locatonButton.selected];

}



- (IBAction)onMarkerDropButtonClick:(id)sender {
    MKPlacemarkAnnotation *point=[[MKPlacemarkAnnotation alloc] init];
    [point setCoordinate:self.mapView.centerCoordinate];
    
    
    //[self.points addObject:point];
    [self.mapView addAnnotation:point];
    [self toggleWaypointMenu];
}
- (IBAction)onTakePhotoButtonClick:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    //picker.wantsFullScreenLayout = YES;
    picker.navigationBarHidden = YES;
    picker.toolbarHidden = YES;
    
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //picker.showsCameraControls=YES;
    
    picker.mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    
    [picker setDelegate:self];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self presentViewController:picker animated:false completion:^{
        NSLog(@"Dismissed");
    }];
    
}

- (IBAction)onLockLocationButtonClick:(id)sender {
    
    [self.lockLocationButton setSelected:!self.lockLocationButton.selected];
    if(self.lockLocationButton.selected){
        
        [_tracker startMovingWithLocation];
        [_tracker startRotatingWithHeading];
        
    }else{
        
        [_tracker stopMovingWithLocation];
        [_tracker stopRotatingWithHeading];
        
        
    }
    
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *) info{
    
    NSLog(@"%@", info);
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    NSString *type=[info objectForKey:UIImagePickerControllerMediaType];
    if([type isEqualToString:@"public.image"]){
        
        MKPhotoAnnotation  *point=[[MKPhotoAnnotation alloc] initWithUIImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
        [point setCoordinate:[_tracker.currentLocation coordinate]];
        [self.mapView addAnnotation:point];

    }else{
        NSLog(@"Unknown Media Type: %@",type);
    }
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    NSLog(@"Cancelled");
    
}





#pragma mark Kml Parser

-(void) onKmlPlacemark:(NSDictionary *)dictionary{
    
    
    MKPlacemarkAnnotation *point=[[MKPlacemarkAnnotation alloc] init];
    [point setCoordinate:[SaxKmlParser ParseCoordinateString:[dictionary valueForKey:@"coordinates"]]];
    [point setTitle:[dictionary valueForKey:@"name"]];
    [point setIconUrl:[dictionary valueForKey:@"href"]];
    
    [self.mapView addAnnotation:point];
    
    
    
}
-(void) onKmlStyle:(NSDictionary *)dictionary{}
-(void) onKmlFolder:(NSDictionary *)dictionary{}
-(void) onKmlGroundOverlay:(NSDictionary *)dictionary{
    
    NSLog(@"Ground Overlay: %@", dictionary);
    
    MKImageOverlay *o=[[MKImageOverlay alloc] init];
    
    NSString *folder=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *image=[[dictionary valueForKey:@"href"] stringByReplacingOccurrencesOfString:@"files/" withString:@""];
    
    [o setImage:[folder stringByAppendingPathComponent:image]];
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
   
    
    MKStyledPolyline * p= [MKStyledPolyline polylineWithCoordinates:locations count:[coordinateStrings count]];
    [p setColor:[SaxKmlParser ParseColorString:[dictionary objectForKey:@"color"]]];
    [p setWidth:[[dictionary objectForKey:@"width"] floatValue]];
    [self.mapView addOverlay:p];
    
}
-(void)onKmlPolygon:(NSDictionary *)dictionary{}



#pragma mark Tracking

-(void)userTrackerPaceDidChangeTo:(float) pace From:(float) previousPace{}
-(void)userTrackerDistanceDidChange:(float) distance From:(float) previousDistance{
    [self.trackDistance setText:[NSString stringWithFormat:@"%im", (int)(distance)]];
}

#pragma mark Device

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            /* start special animation */
            [self.topBar setHidden:false];
            break;
            
        default:
            [self.topBar setHidden:true];
            break;
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
