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
#import "SAXKmlParserDelegate.h"

@interface ViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate, SAXKmlParserDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;



- (IBAction)onTrackButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet StyleButton *trackButton;

- (IBAction)onWaypointButtonClick:(id)sender;

@end

