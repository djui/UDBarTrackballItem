//
//  ViewController.m
//  UDTrackball
//
//  Created by Uwe Dauernheim on 2/14/13.
//  Copyright (c) 2013 Uwe Dauernheim. All rights reserved.
//

#import "ViewController.h"
#import "UDInputAccessoryView.h"
#import "UDBarTrackballItem.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad
{
  
    [self.textView setInputAccessoryView:[self trackballAccessoryView]];
  
    // Show keyboard and set focus on text in view center
    [self.textView becomeFirstResponder];
    [self.textView setSelectedRange:NSMakeRange(220, 0)];
    [self.textView scrollRangeToVisible:NSMakeRange(0,0)];
  
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)trackballAccessoryView
{
    // Use this simple toolbar if you don't want to use the special input accessory view.
    // UIToolbar *trackballToolbar = [[UIToolbar alloc] init];
    // [trackballToolbar sizeToFit];
    // [trackballToolbar setTintColor:[UIColor colorWithRed:145/255. green:153/255. blue:164/255. alpha:1]];
  
    // Special input accessory view; allows smaller height in landscape orientation
    UIToolbar *trackballToolbar = [[UDInputAccessoryView alloc] init];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    UDBarTrackballItem *trackball = [[UDBarTrackballItem alloc] initForTextView:[self textView]];
  
    [trackballToolbar setItems:@[spacer, trackball, spacer] animated:YES];

    return trackballToolbar;
}

- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
}
@end
