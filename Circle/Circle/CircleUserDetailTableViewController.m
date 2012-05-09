//
//  CircleUserDetailTableViewController.m
//  Circle
//
//  Created by Sam Olson on 5/3/12.
//  Copyright (c) 2012 Northern Arizona University. All rights reserved.
//

#import "CircleUserDetailTableViewController.h"
#import "CircleEventDetailViewController.h"
#import "CircleFindFriendsTableViewController.h"
#import "CircleEventCell.h"
#import "UIImageView+WebCache.h"
#import "Parse/Parse.h"

@interface CircleUserDetailTableViewController ()

@end

@implementation CircleUserDetailTableViewController{
    NSDateFormatter *dateFormatter;
}
@synthesize userName = _userName;
@synthesize userEmail = _userEmail;
@synthesize profileImage = _profileImage;
@synthesize selectedUser = _selectedUser;
@synthesize addFriendButton = _addFriendButton;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    dateFormatter = [[NSDateFormatter alloc]init];
    self = [super initWithClassName:@"Rsvp"];
    self = [super initWithCoder:aDecoder];
    if (self) {        
        // The className to query on
        self.className = @"Rsvp";
        
        // The key of the PFObject to display in the label of the default cell style
        //self.keyToDisplay = @"text";
        
        // Whether the built-in pull-to-refresh is enabled
        //self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        //self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 25;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    self.userName.text = [self.selectedUser objectForKey:@"name"];
    self.userEmail.text = [self.selectedUser objectForKey:@"email"];
    
    PFFile *userProfileImage = [self.selectedUser objectForKey:@"image"];
    if(userProfileImage != NULL)
    {
        [self.profileImage setImageWithURL:[NSURL URLWithString:userProfileImage.url]];
    }
    else {
        [self.profileImage setImage:[UIImage imageNamed:@"profile.png"]];
    }
    
//PFQuery *isFriend1 = [PFQuery queryWithClassName:@"Friendships"];
//[isFriend1 whereKey:@"friend1" equalTo:[PFUser currentUser]];
//[isFriend1 whereKey:@"friend2" equalTo:self.selectedUser];
//if ([isFriend1 countObjects]>0)
//{
//    self.addFriendButton.titleLabel.text = @"Delete Friend";
//}
//else {
//    PFQuery *isFriend2 = [PFQuery queryWithClassName:@"Friendships"];
//    [isFriend2 whereKey:@"friend1" equalTo:self.selectedUser];
//    [isFriend2 whereKey:@"friend2" equalTo:[PFUser currentUser]];
//    
//    if ([isFriend2 countObjects]>0)
//    {
//        self.addFriendButton.titleLabel.text = @"Delete Friend";
//    }
//    else {
//        self.addFriendButton.titleLabel.text = @"Add Friend";
//    }
//}
    
    if([[self.selectedUser objectId] isEqualToString: [[PFUser currentUser]objectId]]){
        self.addFriendButton.hidden = YES;
    }
    
    PFQuery *isFriend2 = [PFQuery queryWithClassName:@"Friendships"];
    [isFriend2 whereKey:@"friend1" equalTo:[PFUser currentUser]];
    [isFriend2 whereKey:@"friend2" equalTo:self.selectedUser];
    
    if ([isFriend2 countObjects]>0)
    {
        self.addFriendButton.titleLabel.text = @"Delete Friend";
    }
    else {
        self.addFriendButton.titleLabel.text = @"Add Friend";
    }



                        
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"User Page Loaded\n User Name: %@", [self.selectedUser objectForKey:@"name"]);

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setUserName:nil];
    [self setUserEmail:nil];
    [self setProfileImage:nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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


 // Override to customize what kind of query to perform on the class. The default is to query for
 // all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.className];
    [query whereKey: @"user" equalTo: self.selectedUser];
    [query includeKey:@"event"];
    
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:@"eventStartDate"];
    
    return query;
}
 


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object
{
    static NSString *CellIdentifier = @"eventDetailCell";
    
    CircleEventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CircleEventCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    cell.eventTitleLabel.text = [[object objectForKey:@"event"] objectForKey:@"name"];
    cell.eventLocationLabel.text = [NSString stringWithFormat:@"at %@",[[object objectForKey:@"event"]objectForKey:@"venueName"]];
    
    PFFile *image;
    if ((image = [[object objectForKey:@"event"] objectForKey:@"image"]) && [image isKindOfClass:[PFFile class]]) {
        [cell.imageView setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:[UIImage imageNamed:@"profile.png"]
                                success:^(UIImage *image) {}
                                failure:^(NSError *error) {}];
    }
    
    //set up the calendar
    NSDate *date = [[object objectForKey:@"event"]objectForKey:@"startDate"];
    //formatting the dayLabel with "Mon," "Tue," etc.
    [dateFormatter setDateFormat:@"EE"];
    cell.weekdayLabel.text = [dateFormatter stringFromDate:date];
    
    //format the date number
    [dateFormatter setDateFormat:@"d"];
    cell.dayLabel.text = [dateFormatter stringFromDate:date];
    
    //format the month
    [dateFormatter setDateFormat:@"MMM"];
    cell.monthLabel.text = [dateFormatter stringFromDate:date];
    
    return cell;
}

-(void) addFriendButtonClicked:(id)sender{

    NSLog(@"Friend Button Clicked");
    PFQuery *isFriend1 = [PFQuery queryWithClassName:@"Friendships"];
    [isFriend1 whereKey:@"friend1" equalTo:[PFUser currentUser]];
    [isFriend1 whereKey:@"friend2" equalTo:self.selectedUser];
    
    
    if ([isFriend1 countObjects]>0)
    {
        [self.addFriendButton setTitle:@"Add Friend" forState:UIControlStateNormal];
        PFObject *tempFriend1;
        for (tempFriend1 in [isFriend1 findObjects])
        {
            [tempFriend1 deleteInBackground];
            NSLog(@"FRIEND DELETED!");
        }
    }
    else {
        NSLog(@"FRIEND ADDED");
        [self.addFriendButton setTitle:@"Delete Friend" forState:UIControlStateNormal];
        PFObject *friendship = [PFObject objectWithClassName:@"Friendships"];
        [friendship setObject:[PFUser currentUser] forKey:@"friend1"];
        [friendship setObject:self.selectedUser forKey:@"friend2"];
        [friendship saveInBackground];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if ([[[self objectAtIndex:indexPath] objectForKey:@"event"]objectForKey:@"image"]) {
        [self performSegueWithIdentifier:@"eventDetailSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"eventDetailNoImageSegue" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[CircleEventDetailViewController class]]) {
        CircleEventDetailViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        vc.event = [[self.objects objectAtIndex:indexPath.row]objectForKey:@"event"];
        vc.image = [self.tableView cellForRowAtIndexPath:indexPath].imageView.image;
        
        // retain ourselves so that the controller will still exist once it's popped off
        //[self.navigationController popViewControllerAnimated: NO];  
        //[self.navigationController.parentViewController.navigationController popViewControllerAnimated: NO];
    }
}

@end