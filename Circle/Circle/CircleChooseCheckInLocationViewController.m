//
//  CircleChooseCheckInLocationViewController.m
//  Circle
//
//  Created by Joshua Conner on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleChooseCheckInLocationViewController.h"
#import "Parse/Parse.h"
#import "NearbyEventCell.h"
#import "UIImageView+WebCache.h"

@interface CircleChooseCheckInLocationViewController ()
@end

@implementation CircleChooseCheckInLocationViewController
@synthesize events = _events;

- (void)setEvents:(NSArray *)events {
    _events = events;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![PFUser currentUser]) {
        UINavigationController *modalNavigationController = [[UIStoryboard storyboardWithName:@"CircleAuthStoryboard" bundle:nil] instantiateInitialViewController];
        
        if ([modalNavigationController.topViewController isKindOfClass:[CircleSignInViewController class]]) {
            CircleSignInViewController *signInVC = (CircleSignInViewController *)modalNavigationController.topViewController;
            signInVC.delegate = self;
        }
        
        [self presentModalViewController:modalNavigationController animated:YES];
    }
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
    
     NearbyEventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
        cell = [[NearbyEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"location"];
    }
    
    // Configure the cell...
    cell.textLabel.text = [event objectForKey:@"name"];
    cell.detailTextLabel.text = [[event objectForKey:@"Venue"] objectForKey:@"name"];
    NSLog(@"event: %@", event);
    
    
    if ([event objectForKey:@"image"] && [[event objectForKey:@"image"] isKindOfClass:[PFFile class]]) {
        PFFile *image = [event objectForKey:@"image"];
        NSLog(@"image: %@", image);
        [cell.imageView setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:[UIImage imageNamed:@"profile.png"]
                                success:^(UIImage *image) {}
                                failure:^(NSError *error) {}];
    }

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

#pragma mark - CircleSignInDelegateMethods
- (void) signInSuccessful; {
    [self dismissModalViewControllerAnimated:YES];
}

- (void) userCancelledSignIn {
    [self dismissModalViewControllerAnimated:YES];
    [self.tabBarController setSelectedIndex:2];
}

@end