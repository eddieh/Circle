//
//  CircleFriendsTableViewController.m
//  Circle
//
//  Created by Sam Olson on 4/30/12.
//  Copyright (c) 2012 Northern Arizona University. All rights reserved.
//

#import "CircleFriendsTableViewController.h"
#import "CircleUserDetailTableViewController.h"
#import "UIImageView+WebCache.h"
#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "FriendCheckInCell.h"
#import "CircleEventDetailViewController.h"


@interface CircleFriendsTableViewController() {
    BOOL didGetFriends;
}
@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) PFObject *selectedEvent;
@end

@implementation CircleFriendsTableViewController
@synthesize friends = _friends;
@synthesize selectedEvent = _selectedEvent;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    //TODO: Displays current friends (categories are being used to test if everythings working)
    self = [super initWithClassName:@"Friendships"];
    self = [super initWithCoder:aDecoder];
    if (self) {        
        // The className to query on
        self.className = @"Friendships";
        
        // The key of the PFObject to display in the label of the default cell style
        self.keyToDisplay = @"name";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 25;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.friends = [[NSMutableArray alloc] initWithCapacity:10];
    
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (![PFUser currentUser]) {
        UINavigationController *modalNavigationController = [[UIStoryboard storyboardWithName:@"CircleAuthStoryboard" bundle:nil] instantiateInitialViewController];
        
        if ([modalNavigationController.topViewController isKindOfClass:[CircleSignInViewController class]]) {
            CircleSignInViewController *signInVC = (CircleSignInViewController *)modalNavigationController.topViewController;
            signInVC.delegate = self;
        }
        
        [self presentModalViewController:modalNavigationController animated:YES];
    }
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
    
    if ([self.friends count] == 0) {
        didGetFriends = YES;
        // The find succeeded.
        NSLog(@"Successfully retrieved %d friends.", self.objects.count);
        for (int i = 0; i < self.objects.count; i++) {
            [self.friends addObject:[[self.objects objectAtIndex:i] objectForKey:@"friend2"]];
        }
        [self loadObjects];
    }
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

 // Override to customize what kind of query to perform on the class. The default is to query for
 // all objects ordered by createdAt descending.
 - (PFQuery *)queryForTable {
     PFQuery *query;
     
     if ([self.friends count] == 0) {
         query = [PFQuery queryWithClassName:@"Friendships"];
         
         if ([PFUser currentUser]) {
             [query whereKey:@"friend1" equalTo : [PFUser currentUser]];
         }
         [query includeKey:@"friend2"];
         
     } else {             
         query = [PFQuery queryWithClassName:@"CheckIn"];
         [query whereKey:@"user" containedIn:self.friends];
         [query includeKey:@"user"];
         [query includeKey:@"event"];
     }
     return query;
 }
 


 // Override to customize the look of a cell representing an object. The default is to display
 // a UITableViewCellStyleDefault style cell with the label being the first key in the object. 
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {

     if ([object.className isEqualToString:@"CheckIn"]) {
         NSString *cellIdentifier;
         if ([[object objectForKey:@"user"] objectForKey:@"image"]) {
             cellIdentifier = @"friendCell";
         } else {
             cellIdentifier = @"friendNoImageCell";
         }
         
         FriendCheckInCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
         if (cell == nil) {
             cell = [[FriendCheckInCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier];
         }
         
         [cell configureWithCheckIn:object];
         return cell;
     } else {
         UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"blankCell"];
         
         if (!cell) {
             cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"blankCell"];
         }
         return cell;
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

//sets variables for user detail page
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[CircleUserDetailTableViewController class]]) {
        CircleUserDetailTableViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        vc.selectedUser = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"user"];
        
    } else if ([segue.destinationViewController isKindOfClass:[CircleEventDetailViewController class]]) {
        CircleEventDetailViewController *controller = segue.destinationViewController;
        
        [controller setEvent:self.selectedEvent];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    self.selectedEvent = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"event"];
    
    if ([self.selectedEvent objectForKey:@"image"]) {
        [self performSegueWithIdentifier:@"eventDetailSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"eventNoImageSegue" sender:self];
    }
}

#pragma mark - CircleSignInDelegateMethods
- (void) signInSuccessful; {
    [self dismissModalViewControllerAnimated:YES];
    [self loadObjects];
}

- (void) userCancelledSignIn {
    [self dismissModalViewControllerAnimated:YES];
    [self.tabBarController setSelectedIndex:2];
}

@end
