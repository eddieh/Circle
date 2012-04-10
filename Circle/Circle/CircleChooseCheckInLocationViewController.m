//
//  CircleChooseCheckInLocationViewController.m
//  Circle
//
//  Created by Joshua Conner on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleChooseCheckInLocationViewController.h"
#import "Parse/Parse.h"

@interface CircleChooseCheckInLocationViewController ()
@end

@implementation CircleChooseCheckInLocationViewController
@synthesize events = _events;

- (void)setEvents:(NSArray *)events {
    _events = events;
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query includeKey:@"Venue"];
    [query includeKey:@"Location"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            self.events = objects;
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"location";
    PFObject *event= [self.events objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"location"];
    }
    
    // Configure the cell...
    cell.textLabel.text = [event objectForKey:@"name"];
    cell.detailTextLabel.text = [[event objectForKey:@"Venue"] objectForKey:@"name"];
    NSLog(@"%@", event);
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        PFObject *event = [self.events objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        
        if ([segue.destinationViewController respondsToSelector:@selector(setEvent:)]) {
            [segue.destinationViewController performSelector:@selector(setEvent:) withObject:event];
        }
    }
}


@end