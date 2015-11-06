//
//  OverlayCell.h
//  MapTrack
//
//  Created by Nick Blackwell on 2015-11-05.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverlayCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *featureText;
@property (weak, nonatomic) IBOutlet UILabel *detailFeatureText;
@property (weak, nonatomic) IBOutlet UIImageView *featureImage;

@property (weak, nonatomic) IBOutlet UISwitch *featureSwitch;

@end