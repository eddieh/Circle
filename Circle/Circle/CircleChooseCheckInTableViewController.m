//
//  CircleChooseCheckInTableViewController.m
//  Circle
//
//  Created by Joshua Conner on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleChooseCheckInTableViewController.h"
#import "NearbyEventCell.h"
#import "UIImageView+WebCache.h"

@interface CircleChooseCheckInTableViewController ()

@end

@implementation CircleChooseCheckInTableViewController


#pragma mark - View lifecycle
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithClassName:@"Event"];
    self = [super initWithCoder:aDecoder];
    if (self) {        
        // The className to query on
        self.className = @"Event";
        
        // The key of the PFObject to display in the label of the default cell style
        self.keyToDisplay = @"Event";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 25;
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Parse

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

/*
 // Override to customize what kind of query to perform on the class. The default is to query for
 // all objects ordered by createdAt descending.
 - (PFQuery *)queryForTable {
 PFQuery *query = [PFQuery queryWithClassName:self.className];
 
 // If no objects are loaded in memory, we look to the cache first to fill the table
 // and then subsequently do a query against the network.
 if ([self.objects count] == 0) {
 query.cachePolicy = kPFCachePolicyCacheThenNetwork;
 }
 
 [query orderByDescending:@"createdAt"];
 
 return query;
 }
 */


 // Override to customize the look of a cell representing an object. The default is to display
 // a UITableViewCellStyleDefault style cell with the label being the first key in the object. 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"location";
    PFObject *event= [self.objects objectAtIndex:indexPath.row];
    
    NearbyEventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[NearbyEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"location"];
    }
    
    // Configure the cell...
    cell.textLabel.text = [event objectForKey:@"name"];
    cell.detailTextLabel.text = [event objectForKey:@"venueName"];
    
    
    if ([event objectForKey:@"image"] && [[event objectForKey:@"image"] isKindOfClass:[PFFile class]]) {
        PFFile *image = [event objectForKey:@"image"];

        [cell.imageView setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:[UIImage imageNamed:@"profile.png"]
                                success:^(UIImage *image) {}
                                failure:^(NSError *error) {}];
    }
    
    return cell; 
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        PFObject *event = [self.objects objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        
        if ([segue.destinationViewController respondsToSelector:@selector(setEvent:)]) {
            [segue.destinationViewController performSelector:@selector(setEvent:) withObject:event];
        }
    }
}

/*
 // Override if you need to change the ordering of objects in the table.
 - (PFObject *)objectAtIndex:(NSIndexPath *)indexPath { 
 return [self.objects objectAtIndex:indexPath.row];
 }
 */

/*
 // Override to customize the look of the cell that allows the user to load the next page of objects.
 // The default implementation is a UITableViewCellStyleDefault cell with simple labels.
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
 static NSString *CellIdentifier = @"NextPage";
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
 }
 
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 cell.textLabel.text = @"Load more...";
 
 return cell;
 }
 */

#pragma mark - Table view data source

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
//}

#pragma mark - CircleSignInDelegateMethods
- (void) signInSuccessful; {
    [self dismissModalViewControllerAnimated:YES];
}

- (void) userCancelledSignIn {
    [self dismissModalViewControllerAnimated:YES];
    [self.tabBarController setSelectedIndex:2];
}

@end
