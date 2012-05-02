//
//  CircleMainViewController.m
//  Circle
//
//  Created by Joshua Conner on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleMainViewController.h"
#import <Parse/Parse.h>
#import "LocationSingleton.h"
#import "CircleChooseCheckInLocationViewController.h"

@interface CircleMainViewController () <LocationSingletonDelegate> {
    BOOL didRecieveFirstLocationUpdate;
    NSArray *nearbyEvents;
}
@property LocationSingleton *locationManager;
@property CLLocation *currentLocation;

- (void)setViewControllersWithStoryboardNames:(NSArray *)names;
@end

@implementation CircleMainViewController
@synthesize locationManager = _locationManager;
@synthesize currentLocation = _currentLocation;
@synthesize lastSelectedViewController = _lastSelectedViewController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/**
 * Spawn threads to load data from servers!
 */
- (void)viewDidAppear:(BOOL)animated {
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
	
    NSArray *storyboardNames = [NSArray arrayWithObjects:@"CircleCheckInStoryboard", 
                                                         @"CircleCreateEventStoryboard",
                                                         @"CircleNearbyStoryboard",
                                                         @"CircleManageFriendsStoryboard",
                                                         @"CircleSearchStoryboard",
                                                         nil];
    
    //@"MapStoryboard",
    
    [self setViewControllersWithStoryboardNames:storyboardNames];
    
    //select the middle tab!
    self.selectedIndex = 2;

//    //try to get location info early so we can pass it viewcontrollers
//    self.locationManager = [LocationSingleton sharedInstance];
//    self.locationManager.delegate = self;
//    self.locationManager.currentLocation  
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

- (void)getEventsCallbackWithResult:(NSArray *)result error:(NSError *)error {
    if (!error) {
        //find the correct viewcontroller and set its objects
        for (UIViewController *v in self.viewControllers) {
            if ([v isKindOfClass:[CircleChooseCheckInLocationViewController class]]) {
                [v performSelector:@selector(setObjects:) withObject:result];
            }
        }
    }
}

#pragma mark - LocationSingletonDelegate method
- (void)didRecieveLocationUpdate:(CLLocation *)location {
    self.currentLocation = location;
    
    if (!didRecieveFirstLocationUpdate) {
        didRecieveFirstLocationUpdate = YES;
        
        PFQuery *eventsQuery = [PFQuery queryWithClassName:@"Events"];
        eventsQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
        [eventsQuery includeKey:@"venue"];
        
        [eventsQuery findObjectsInBackgroundWithTarget:self selector:@selector(getEventsCallbackWithResult:error:)];
    }
}

#pragma mark - UITabBarControllerDelegate methods
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    // since the first view in the create event workflow hides the tab bar we save the last selected view
    // so we can go back when if the user touches the cancel button
    self.lastSelectedViewController = [tabBarController selectedViewController];
    return YES;
}

@end
