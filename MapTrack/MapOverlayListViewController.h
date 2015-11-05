//
//  MapOverlayListViewController.h
//  MapTrack
//
//  Created by Nick Blackwell on 2015-11-05.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapOverlayListViewController : UIViewController

@property (nonatomic) id<UITableViewDataSource> dataSource;
@property (nonatomic) id<UITableViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
