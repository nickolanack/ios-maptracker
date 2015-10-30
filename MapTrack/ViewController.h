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

@interface ViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate, SaxKmlParserDelegate, MKOffscreenFeatureRendererDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

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


@property (weak, nonatomic) IBOutlet StyleButton *locatonButton;
@property (weak, nonatomic) IBOutlet StyleButton *waypointButton;
@property (weak, nonatomic) IBOutlet StyleButton *markerDropButton;
@property (weak, nonatomic) IBOutlet StyleButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet StyleButton *lockLocationButton;

@end

