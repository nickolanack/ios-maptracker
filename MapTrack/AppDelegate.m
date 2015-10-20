//
//  AppDelegate.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-19.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property UIBackgroundTaskIdentifier masterTaskId;
@property CLLocationManager *lm;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"Enter Background");
    
//    [application beginBackgroundTaskWithName:@"MyTask" expirationHandler:^{
//       
//        
//  
//            NSLog(@"Background Expire Handler");
//        
//        
//        
//    }];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        NSLog(@"Background Thread");
//
//        
//        self.lm = [[CLLocationManager alloc]init];
//        [self.lm setDelegate:self];
//        [self.lm startUpdatingLocation];
//        
//
//    });
//    
  
}
//
//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
//    
//    CLLocation *point=[locations lastObject];
//    
//    NSLog(@"Recieved Background Location: lat:%f, lng:%f, alt:%f", point.coordinate.latitude,  point.coordinate.longitude, point.altitude);
//    
//    //NSLog(@"%@", locations);
//}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    NSLog(@"Terminated");
}

@end
