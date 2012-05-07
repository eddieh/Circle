//
//  CircleNearbyViewController.m
//  Circle
//
//  Created by Joshua Conner on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//
// This is the template PFQueryTableViewController subclass file. Use it to customize your own subclass.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "CircleNearbyViewController.h"
#import "LocationSingleton.h"
#import "CircleEventDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "NearbyEventCell.h"


@interface CircleNearbyViewController () {
    PF_MBProgressHUD *HUD;
    LocationSingleton *locationSingleton;
    NSDateFormatter *dateFormatter;
    BOOL gotLocation;
}
@property (nonatomic, strong) NSArray *actionSheetButtonTitles;
@property (nonatomic, strong) NSString *sortOrder;
@property (nonatomic, strong) NSArray *origObjects;
@property (nonatomic, strong) CLLocation *currentLocation;
@end

@implementation CircleNearbyViewController
@synthesize pickerView;
@synthesize sortedByLabel = _sortedByLabel;
@synthesize logOutSignInButton;
@synthesize sortOrder = _sortOrder;
@synthesize origObjects = _origObjects;
@synthesize currentLocation = _currentLocation;
@synthesize actionSheetButtonTitles = _actionSheetButtonTitles;

- (void) setCurrentLocation:(CLLocation *)currentLocation {
    _currentLocation = currentLocation;
    if (!gotLocation) {
        [self loadObjects];
        gotLocation = YES;
    }
}

#pragma mark - View lifecycle
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithClassName:@"Event"];
    self = [super initWithCoder:aDecoder];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE M/d 'at' h:mm a"];
    locationSingleton = [LocationSingleton sharedInstance];
    locationSingleton.delegate = self;
    
    self.actionSheetButtonTitles = [NSArray arrayWithObjects:@"✓ Sort by nearest", @"Sort by soonest",  nil];
    
    if (self) {        
        // The className to query on
        self.className = @"Event";
        
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[CircleEventDetailViewController class]]) {
        CircleEventDetailViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        vc.event = [self.objects objectAtIndex:indexPath.row];
        vc.image = [self.tableView cellForRowAtIndexPath:indexPath].imageView.image;
    }
}

// show a modal view with the sign in view
- (void)showSignInView {
    UINavigationController *modalNavigationController = [[UIStoryboard storyboardWithName:@"CircleAuthStoryboard" bundle:nil] instantiateInitialViewController];
    
    if ([modalNavigationController.topViewController isKindOfClass:[CircleSignInViewController class]]) {
        CircleSignInViewController *signInVC = (CircleSignInViewController *)modalNavigationController.topViewController;
        signInVC.delegate = self;
        signInVC.isVoluntarySignIn = YES;
    }
    
    [self presentModalViewController:modalNavigationController animated:YES];
}

- (void) doSignOut {
    HUD = [self configureHUD];
    HUD.labelText = @"Signing out...";
    [HUD show:YES];
    
    //fake delay: wait 1 second, show "Signed out", wait 1 more second, then hide
    float delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self setHUDCustomViewWithImageNamed:@"37x-Checkmark.png" labelText:@"Signed out."detailsLabelText:nil hideDelay:1.0];
        self.logOutSignInButton.title = @"Sign in";
        [PFUser logOut];
        
    });
}

#pragma mark - UI callback methods
//if the user is signed in, log them out; otherwise present signin form modally
- (IBAction)signInLogOutButtonPressed:(id)sender; {
    if ([PFUser currentUser]) {
        [self doSignOut];
    } else {
        [self showSignInView];
    }
}

- (IBAction)segmentedButtonChanged:(UISegmentedControl *)sender {
    NSLog(@"Selected: %d", sender.selectedSegmentIndex);
}

- (IBAction)sortButtonPressed:(UIBarButtonItem *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    for (NSString *title in self.actionSheetButtonTitles) {
        [actionSheet addButtonWithTitle:title];
    }
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [actionSheet addSubview:self.pickerView];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [actionSheet setBounds:CGRectMake(0, 0, 320, 225)];
}

#pragma mark - View lifecycle
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
    [self setPickerView:nil];
    [self setSortedByLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![PFUser currentUser]) {
        self.logOutSignInButton.title = @"Sign in";
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
    self.origObjects = [self.objects copy];
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
     
     // If no objects are loaded in memory, we look to the cache first to fill the table
     // and then subsequently do a query against the network.
     if ([self.objects count] == 0) {
         query.cachePolicy = kPFCachePolicyCacheThenNetwork;
     }
     
     if (self.currentLocation) {
         NSLog(@"Querying with location");
         PFGeoPoint *g = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
         [query whereKey:@"location" nearGeoPoint:g];
     }
     //[query orderByAscending:@"startTime"];
     
     return query;
 }



 // Override to customize the look of a cell representing an object. The default is to display
 // a UITableViewCellStyleDefault style cell with the label being the first key in the object. 
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
     static NSString *CellIdentifier = @"nearbyCell";
     
     NearbyEventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     if (cell == nil) {
         cell = [[NearbyEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
     }
     
     // Configure the cell
     cell.textLabel.text = [object objectForKey:@"name"];
     
     NSString *detailText;
     if ([object objectForKey:@"venueName"]) {
         detailText = [NSString stringWithFormat:@"at %@", [object objectForKey:@"venueName"]];
     } else {
         detailText = [object objectForKey:@"address"];
     }
     
     cell.detailTextLabel.text = detailText;
     
     if ([object objectForKey:@"image"] && [[object objectForKey:@"image"] isKindOfClass:[PFFile class]]) {
         PFFile *image = [object objectForKey:@"image"];
         [cell.imageView setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:[UIImage imageNamed:@"profile.png"]
                                     success:^(UIImage *image) {}
                                     failure:^(NSError *error) {}];
     }
     
     return cell;
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

//#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if ([[self objectAtIndex:indexPath] objectForKey:@"image"]) {
        [self performSegueWithIdentifier:@"eventDetailSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"eventDetailNoImageSegue" sender:self];
    }
}

#pragma mark - CircleSignInDelegateMethods
- (void) signInSuccessful; {
    self.logOutSignInButton.title = @"Log out";
    [self dismissModalViewControllerAnimated:YES];
}

- (void) userCancelledSignIn {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - HUD helper methods
/**
 * The way the HUD is supposed to work is that you init it every time you use it, so use this method to configure
 * with appropriate fonts and delegate and all that.
 */
- (PF_MBProgressHUD *)configureHUD {
    //init and set up HUD    
    HUD = [[PF_MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0];
    HUD.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    
    return HUD;
}

/**
 * Displays a message and image in the HUD and then hides it after hideDelay.
 */
- (void)setHUDCustomViewWithImageNamed:(NSString *)imageName 
                             labelText:(NSString *)labelText 
                      detailsLabelText:(NSString *)detailsLabelText 
                             hideDelay:(float)hideDelay {
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    HUD.mode = PF_MBProgressHUDModeCustomView;
    HUD.labelText = labelText;
    HUD.detailsLabelText = detailsLabelText;
    [HUD hide:YES afterDelay:hideDelay];
}


#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(PF_MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidden
	[HUD removeFromSuperview];
	HUD = nil;
}

#pragma mark - LocationSingletondelegate methods
- (void)didRecieveLocationUpdate:(CLLocation *)location; {
    self.currentLocation = location;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //NSLog(@"Index: %d", buttonIndex);
    if (buttonIndex == 0) {
        self.actionSheetButtonTitles = [NSArray arrayWithObjects:@"✓ Sort by nearest", @"Sort by soonest",  nil];
        self.sortedByLabel.text = @"Sorted by nearest";
        self.objects = [self.origObjects mutableCopy];
    } else {
        self.actionSheetButtonTitles = [NSArray arrayWithObjects:@"Sort by nearest", @"✓ Sort by soonest",  nil];
        
        self.sortedByLabel.text = @"Sorted by soonest";

        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES]; // If you want newest at the top, pass NO instead.
        self.objects = [[self.origObjects sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]] mutableCopy];
    }
    [self.tableView reloadData];
}
@end