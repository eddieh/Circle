//
//  CircleCheckInViewController.m
//  Circle
//
//  Created by Joshua Conner on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleCheckInViewController.h"
#import "DCRoundSwitch.h"

@interface CircleCheckInViewController ()

@end

@implementation CircleCheckInViewController
@synthesize facebookSlider = _facebookSlider;
@synthesize foursquareSlider = _foursquareSlider;
@synthesize eventTitleLabel;
@synthesize eventTitle = _eventTitle;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.facebookSlider.onText = @"Facebook";
    self.facebookSlider.offText = @"Facebook";
    self.foursquareSlider.onText = @"Foursquare";
    self.foursquareSlider.offText = @"Foursquare";
}

- (void)viewDidUnload
{
    [self setEventTitleLabel:nil];
    [self setFacebookSlider:nil];
    [self setFoursquareSlider:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)checkInButtonPressed {
}
@end
