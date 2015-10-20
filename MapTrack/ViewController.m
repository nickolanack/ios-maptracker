//
//  ViewController.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-19.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lm = [[CLLocationManager alloc]init];
    [self.lm setDelegate:self];
    
    if([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedAlways){
        [self.lm requestAlwaysAuthorization];
    }else{
        [self startMonitoring];
    }
  
    
}

- (void)startMonitoring{

    

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
        [self startMonitoring];
    }

}

@end
