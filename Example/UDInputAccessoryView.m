//
//  UDInputAccessoryView.m
//  UDTrackball
//
//  Created by Uwe Dauernheim on 2/14/13.
//  Copyright (c) 2013 Uwe Dauernheim. All rights reserved.
//

#import "UDInputAccessoryView.h"

@implementation UDInputAccessoryView

- (void) layoutSubviews
{
    [super layoutSubviews];
  
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
        [self setTintColor:[UIColor colorWithRed:130/255. green:138/255. blue:150/255. alpha:1]];
    else
        [self setTintColor:[UIColor colorWithRed:145/255. green:153/255. blue:164/255. alpha:1]];
  
    CGRect origFrame = self.frame;
    [super sizeToFit];
    CGRect newFrame = self.frame;
    newFrame.origin.y += origFrame.size.height - newFrame.size.height;
  
    self.frame = newFrame;
}

@end