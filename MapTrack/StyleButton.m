//
//  StyleButton.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-20.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "StyleButton.h"
#import <QuartzCore/QuartzCore.h>
@interface StyleButton ()

@property UIColor *defaultColor;

@end

@implementation StyleButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithCoder:(NSCoder *)aDecoder{

    self=[super initWithCoder:aDecoder];
    self.layer.cornerRadius = 4; // this value vary as per your desire
    //self.clipsToBounds = YES;
    
    self.layer.shadowColor = [UIColor redColor].CGColor;
    self.layer.shadowOpacity = 0.4;
    self.layer.shadowRadius = 20;
    
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth=1.5;
    
    self.defaultColor=self.backgroundColor;
    
    if(self.isSelected){
        [self setBackgroundColor:[UIColor magentaColor]];
    }
    return self;
    
}

-(void)setSelected:(BOOL)selected{
    [self setBackgroundColor:(selected?[UIColor magentaColor]:self.defaultColor)];
    [super setSelected:selected];
    
}

@end
