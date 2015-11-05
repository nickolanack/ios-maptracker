//
//  MapOverlayListViewController.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-11-05.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "MapOverlayListViewController.h"

@implementation MapOverlayListViewController


@synthesize delegate, dataSource;

-(void)viewDidLoad{

    [self.tableView setDelegate:delegate];
    [self.tableView setDataSource:dataSource];

}


-(void)setDataSource:(id<UITableViewDataSource>)dataSrc{
    [self.tableView setDataSource:dataSrc];
    dataSource=dataSrc;
    if(self.tableView){
        [self.tableView reloadData];
    }
}
-(void)setDelegate:(id<UITableViewDelegate>)delgt{
    [self.tableView setDelegate:delgt];
    delegate=delgt;
}




@end
