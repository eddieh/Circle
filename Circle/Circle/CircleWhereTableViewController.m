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

@synthesize nextButton = _nextButton;
@synthesize event = _event;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSLog(@"%@", self.event);
}

- (void)viewDidUnload
{
    [self setVenueCell:nil];
    [self setSavedAddressesCell:nil];
    [self setNextButton:nil];
    [self setAddAddressCell:nil];
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


@end
