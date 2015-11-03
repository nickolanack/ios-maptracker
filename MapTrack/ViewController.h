//
//  ViewController.h
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-19.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "StyleButton.h"
#import "SaxKmlParserDelegate.h"
#import "MKOffscreenFeatureRendererDelegate.h"
#import "MKUserTrackerDelegate.h"
#import "MKPolylineTapDetectorDelegate.h"

@interface ViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate, SaxKmlParserDelegate, MKOffscreenFeatureRendererDelegate, UIImagePickerControllerDelegate, MKUserTrackerDelegate, UINavigationControllerDelegate, MKPolylineTapDetectorDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;



- (IBAction)onTrackButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet StyleButton *trackButton;

- (IBAction)onWaypointButtonClick:(id)sender;
- (IBAction)onOverlaysButtonClick:(id)sender;
- (IBAction)onUserLocationClick:(id)sender;
@property (weak, nonatomic) IBOutlet StyleButton *onOverlaysButton;
- (IBAction)onMarkerDropButtonClick:(id)sender;
- (IBAction)onTakePhotoButtonClick:(id)sender;
- (IBAction)onLockLocationButtonClick:(id)sender;
- (IBAction)onAddUserLocationButtonClick:(id)sender;

@property (weak, nonatomic) IBOutlet StyleButton *addUserLocationButton;

@property (weak, nonatomic) IBOutlet StyleButton *locatonButton;
@property (weak, nonatomic) IBOutlet StyleButton *waypointButton;
@property (weak, nonatomic) IBOutlet StyleButton *markerDropButton;
@property (weak, nonatomic) IBOutlet StyleButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet StyleButton *lockLocationButton;
@property (weak, nonatomic) IBOutlet UIView *trackInfoBar;
@property (weak, nonatomic) IBOutlet UILabel *trackLabel;
@property (weak, nonatomic) IBOutlet UILabel *trackTime;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UILabel *trackDistance;

@end

