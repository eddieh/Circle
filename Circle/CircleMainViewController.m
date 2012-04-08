//
//  CircleMainViewController.m
//  Circle
//
//  Created by Joshua Conner on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleMainViewController.h"

@interface CircleMainViewController ()
- (void)setViewControllersWithStoryboardNames:(NSArray *)names;
@end

@implementation CircleMainViewController

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
	
    NSArray *storyboardNames = [NSArray arrayWithObjects:@"CircleCheckInStoryboard", 
                                                         @"CircleCreateEventStoryboard",
                                                         @"CircleNearbyStoryboard",
                                                         @"CircleMessagesStoryboard",
                                                         @"CircleSearchStoryboard",
                                                         nil];
    
    [self setViewControllersWithStoryboardNames:storyboardNames];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setViewControllersWithStoryboardNames:(NSArray *)names {
    NSMutableArray *response = [[NSMutableArray alloc] initWithCapacity:[names count]];
    
    for (NSString *name in names) {
        [response addObject:[[UIStoryboard storyboardWithName:name bundle:nil] 
                             instantiateInitialViewController]];
    }
    
    [self setViewControllers:response];
}

@end
