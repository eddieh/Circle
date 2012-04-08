//
//  CircleEventCategoryAndPrivacyViewController.m
//  Circle
//
//  Created by Eddie Hillenbrand on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleEventCategoryAndPrivacyViewController.h"

@interface CircleEventCategoryAndPrivacyViewController ()

@end

@implementation CircleEventCategoryAndPrivacyViewController
@synthesize categoryPicker;
@synthesize privacyPicker;
@synthesize doneBarButton;

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
}

- (void)viewDidUnload
{
    [self setCategoryPicker:nil];
    [self setPrivacyPicker:nil];
    [self setDoneBarButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
