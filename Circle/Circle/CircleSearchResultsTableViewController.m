//
//  CircleSearchResultsTableViewController.m
//  Circle
//
//  Created by Sam Olson on 4/13/12.
//  Copyright (c) 2012 Northern Arizona University. All rights reserved.
//

#import "CircleSearchResultsTableViewController.h"
#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@interface CircleSearchResultsTableViewController ()
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSString *location;
//added
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@end
@implementation CircleSearchResultsTableViewController
@synthesize categories = _categories;
@synthesize location = _location;
@synthesize myQuery = _myQuery;
//added
@synthesize startDate = _startDate;
@synthesize endDate = _endDate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithClassName:@"Category"];
    self = [super initWithCoder:aDecoder];
//    if (self) {        
//        // The className to query on
//        self.className = @"Category";
//        
//        // The key of the PFObject to display in the label of the default cell style
//        self.keyToDisplay = @"name";
//        
//        // Whether the built-in pull-to-refresh is enabled
//        self.pullToRefreshEnabled = YES;
//        
//        // Whether the built-in pagination is enabled
//        self.paginationEnabled = YES;
//        
//        // The number of objects to show per page
//        self.objectsPerPage = 25;
//    }
    
    PFQuery *query = self.myQuery;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    
    return self;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[CircleEventDetailViewController class]]) {
        CircleEventDetailViewController *vc = segue.destinationViewController;
        vc.event = [self.objects objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    }
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
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    //if ([segue.destinationViewController isKindOfClass:[CircleSearchEventTableViewController class]]) {
//        //CircleSearchEventTableViewController *vc = (CircleSearchEventTableViewController *)segue.destinationViewController;
//        //vc.delegate = self;
//        //vc.selectedCategories = self.categories;
//    }
//}



 // Override to customize what kind of query to perform on the class. The default is to query for
 // all objects ordered by createdAt descending.
 - (PFQuery *)queryForTable {
     PFQuery *query;
     if (self.myQuery) {
         query = self.myQuery;
     } else { 
         query = [PFQuery queryWithClassName:self.className];
     }
     
     // If no objects are loaded in memory, we look to the cache first to fill the table
     // and then subsequently do a query against the network.
     if ([self.objects count] == 0) {
         query.cachePolicy = kPFCachePolicyCacheThenNetwork;
     }

     [query orderByDescending:@"createdAt"];
     return query;
 }
 


 // Override to customize the look of a cell representing an object. The default is to display
 // a UITableViewCellStyleDefault style cell with the label being the first key in the object. 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"searchLocation";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    cell.textLabel.text = [object objectForKey:@"name"];
    cell.detailTextLabel.text = [object objectForKey:@"venueName"];
    
    if ([[object objectForKey:@"image"] isKindOfClass:[UIImage class]]) {
        [cell.imageView setImage:[object objectForKey:@"image"]];
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
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
//}

//#pragma mark - filter delegate
//-(void) userSelectedFilter:(NSArray *) categories: (NSString*) location
//{
//    NSLog(@"RESULTS@%@", self.categories);
//}
@end