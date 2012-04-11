//
//  CircleOverviewSaveTableViewController.m
//  Circle
//
//  Created by Eddie Hillenbrand on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleOverviewSaveTableViewController.h"
#import "Parse/Parse.h"

@interface CircleOverviewSaveTableViewController ()

@end

@implementation CircleOverviewSaveTableViewController

@synthesize nameCell = _nameCell;
@synthesize detailsCell = _detailsCell;
@synthesize whereCell = _whereCell;
@synthesize startsCell = _startsCell;
@synthesize endsCells = _endsCells;
@synthesize categoryCell = _categoryCell;
@synthesize photoCell = _photoCell;
@synthesize saveButton = _saveButton;
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
    [self setNameCell:nil];
    [self setDetailsCell:nil];
    [self setWhereCell:nil];
    [self setStartsCell:nil];
    [self setEndsCells:nil];
    [self setCategoryCell:nil];
    [self setPhotoCell:nil];
    [self setSaveButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"didEnterEventNameDetailsSegue"]) {
        id viewController = [segue destinationViewController];
        if ([viewController respondsToSelector:@selector(setEvent:)]) {
            
//            [self.event setObject:self.nameTextField.text forKey:@"name"];
//            [self.event setObject:self.detailsTextField.text forKey:@"details"];
            
            [viewController setEvent:self.event];
        }
    }
}

@end
