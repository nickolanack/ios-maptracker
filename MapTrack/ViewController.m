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

#import "MapOverlayListViewController.h"
#import "OverlayCell.h"
#import "MockPolylineRenderer.h"

@interface ViewController ()


@property MKUserTracker *tracker;
@property MKOffscreenFeatureRenderer *offscreenRenderer;
@property MKPolylineTapDetector *tapDetector;
@property UITableView *tableView;

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

-(void)onPolylineTap:(MKPolyline *)polyline atCoordinate:(CLLocationCoordinate2D)coord andTouch:(CGPoint)touchPt{
    //    NSLog(@"PolyTap: %f, %f", coord.latitude, coord.longitude);
    //
    //    MKPlacemarkAnnotation *p=[[MKPlacemarkAnnotation alloc] init];
    //    [p setCoordinate:coord];
    //    NSString *icon=[[NSBundle mainBundle] pathForResource:@"waypoint-offscreen-15.png" ofType:nil];
    //    [p setIconUrl:icon];
    //
    //    [self.mapView addAnnotation:p];
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
        
        if([ext isEqualToString:@".kml"]&&(![[NSCharacterSet characterSetWithCharactersInString:@"._"] characterIsMember:[path characterAtIndex:0]])){
            
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
        
        if([self.usersOverlaysButton isSelected]){
            [r setAlpha:0.5];
        }else{
            [r setAlpha:0.1];
        }
    }else{
        MockPolylineRenderer *p= [[MockPolylineRenderer alloc]initWithOverlay:overlay];
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
    [self.overlaysButton setSelected:!self.overlaysButton.selected];
    [self.usersOverlaysButton setHidden:!self.overlaysButton.selected];
    [self.overlaysListButton setHidden:!self.overlaysButton.selected];
}

- (IBAction)onUsersOverlaysButtonClick:(id)sender {
    [self.usersOverlaysButton setSelected:!self.usersOverlaysButton.selected];
    for(id o in self.mapView.overlays) {
        
        [self.mapView removeOverlay:o];
        [self.mapView addOverlay:o];
        
        //[o setNeedsDisplay];
    }
}

- (IBAction)onOverlaysListButtonClick:(id)sender{
    
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
    [self.addUserLocationButton setHidden:!self.locatonButton.selected];
    
}



- (IBAction)onMarkerDropButtonClick:(id)sender {
    MKPointAnnotation *point=[[MKPointAnnotation alloc] init];
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

- (IBAction)onAddUserLocationButtonClick:(id)sender {
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
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            
            [self.topBar setHidden:true];
            break;
            
        default:
            [self.topBar setHidden:false];
            break;
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIViewController *vc=[segue destinationViewController];
    if([vc isKindOfClass:[MapOverlayListViewController class]]){
        
        MapOverlayListViewController *mOverlayvc=(MapOverlayListViewController *)vc;
        [mOverlayvc setDelegate:self];
        [mOverlayvc setDataSource:self];
        
    }
    
}

#pragma mark OverlayTable Cells

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(_tableView==nil){
        _tableView=tableView;
    }
    
    if(section==0){
        return _mapView.overlays.count;
    }else{
        return _mapView.annotations.count;
    }
    
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    int section=indexPath.section;
    int row=indexPath.row;
    
    OverlayCell *cell;
    
    NSString *textLabel=@"Feature";
    NSString *detailTextLabel=@"";
    UIImage *image;
    

       
        
    if(section==0){
        
        
        NSObject<MKOverlay> *o=[_mapView.overlays objectAtIndex:row];
        textLabel= @"Overlay";
        //cell.detailTextLabel.text= o.title;
        
        if([o isKindOfClass:[MKImageOverlay class]]){
            MKImageOverlay *iO=(MKImageOverlay *)o;
            image=[iO getUIImage];
        }
        
        if([o isKindOfClass:[MKStyledPolyline class]]){
            
            MKStyledPolyline *sPO=(MKStyledPolyline *)o;
            
            
            MockPolylineRenderer *pl=[[MockPolylineRenderer alloc] initWithPolyline:sPO];
            [pl setStrokeColor:sPO.color];
            [pl setLineWidth:sPO.width];
            
            
            MKMapRect pr=sPO.boundingMapRect;
            
            float max=MAX(pr.size.height, pr.size.width);
            float size =64;
            CGSize imageSize=CGSizeMake(size*(pr.size.width/max),size*(pr.size.height/max));
            
            MKZoomScale scale= size / max;
            
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0);
            
            CGContextRef context=UIGraphicsGetCurrentContext();
            CGContextScaleCTM(context, scale, scale);
            [pl drawMapRect:pr zoomScale:scale inContext:context];
            image = UIGraphicsGetImageFromCurrentImageContext();  // UIImage returned.
            UIGraphicsEndImageContext();
            
            
        }
        
    }else if(section==1){
            MKPointAnnotation *a=[_mapView.annotations objectAtIndex:row];
        
            textLabel= @"Point";
            //cell.detailTextLabel.text= a.title;
            
            if([a isKindOfClass:[MKPhotoAnnotation class]]){
                MKPhotoAnnotation *phA=(MKPhotoAnnotation *)a;
                image=[phA getIcon];
            }
            
            if([a isKindOfClass:[MKPlacemarkAnnotation class]]){
                MKPlacemarkAnnotation *plA=(MKPlacemarkAnnotation *)a;
                image=[plA getIcon];
            }
            
            if([a isKindOfClass:[MKUserLocation class]]){
                image=[UIImage imageNamed:@"userlocation-offscreen-15.png"];
            }
        
            if([a isKindOfClass:[MKPointAnnotation class]]){
                image=[UIImage imageNamed:@"waypoint-offscreen-15.png"];
            }
            
            
            detailTextLabel=a.title;
            
        }
        
        
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"MapOverlayCell"];
        
        if (cell == nil){
            cell = [[OverlayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MapOverlayCell"];
            
            
        }
        
  
    
    cell.featureText.text=textLabel;
    cell.detailFeatureText.text=detailTextLabel;
    
    if(image != nil){
        [cell.featureImage setImage:image];
    }
    cell.featureSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    return cell;
    
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views{
    if(_tableView){
        [_tableView reloadData];
    }
}
-(void)mapView:(MKMapView *)mapView didAddOverlayRenderers:(NSArray<MKOverlayRenderer *> *)renderers{
    if(_tableView){
        [_tableView reloadData];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //add code here for when you hit delete
    }
}


@end
