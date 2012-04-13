//
//  MSEWhereTableViewController.m
//  MultiStepEditor
//
//  Created by Eddie Hillenbrand on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleWhereTableViewController.h"
#import "Parse/Parse.h"


@interface CircleWhereTableViewController () 

@end

@implementation CircleWhereTableViewController
@synthesize venueCell = _venueCell;
@synthesize savedAddressesCell = _savedAddresseCell;
@synthesize addAddressCell = _addAddressCell;
@synthesize currentLocationCell = _currentLocationCell;

@synthesize nextButton = _nextButton;
@synthesize event = _event;
@synthesize currentLocation = _currentLocation;
@synthesize l = _l;


#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.l = [LocationSingleton sharedInstance];
    self.l.delegate = self;
    
    NSLog(@"%@", self.event);
}

- (void)viewDidUnload
{
    [self setVenueCell:nil];
    [self setSavedAddressesCell:nil];
    [self setNextButton:nil];
    [self setAddAddressCell:nil];
    [self setCurrentLocationCell:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"CreateEventNextSegue"]) {
        id viewController = [segue destinationViewController];
        if ([viewController respondsToSelector:@selector(setEvent:)]) {

//            [self.event setObject:self.nameTextField.text forKey:@"name"];
//            [self.event setObject:self.detailsTextField.text forKey:@"details"];
            
            [viewController setEvent:self.event];
        }
    }
}

#pragma mark - LocationSingletonDelegate method
- (void)didRecieveLocationUpdate:(CLLocation *)location; {
    NSLog(@"Location received: %@", location);
    self.currentLocation = location; //to use later?
    
    //for now, we're just going to set every event's location with our current location
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    [self.event setObject:point forKey:@"location"];
    self.currentLocationCell.textLabel.text = [NSString stringWithFormat:@"%f, %f", location.coordinate.latitude, location.coordinate.longitude];
}
@end
