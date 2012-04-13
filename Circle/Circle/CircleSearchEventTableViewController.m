//
//  CircleSearchEventTableViewController.m
//  Circle
//
//  Created by Sam Olson on 4/10/12.
//  Copyright (c) 2012 Northern Arizona University. All rights reserved.
//

#import "CircleSearchEventTableViewController.h"
#import "CircleSearchResultsTableViewController.h"

@interface CircleSearchEventTableViewController ()
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) PFGeoPoint *point;
@end

@implementation CircleSearchEventTableViewController
@synthesize categoryCell = _categoryCell;
@synthesize categories = _categories;
@synthesize locationCell = _locationCell;
@synthesize location = _location;
@synthesize connection = _connection;
@synthesize point = _point;

- (void)viewDidLoad {
    self.connection = [[GooglePlacesConnection alloc] initWithDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setCategoryCell:nil];
    [self setCategories:nil];
    [self setLocation:nil];
    [self setLocationCell:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *categoryString = [[NSString alloc] init];
    
    if ([self.categories count] > 0) {
        for (PFObject *category in self.categories) {
            categoryString = [categoryString stringByAppendingFormat:@"%@, ", [category objectForKey:@"name"]];
        }
        categoryString = [categoryString substringToIndex:[categoryString length] - 2];
        self.categoryCell.detailTextLabel.text = categoryString;
    }
    if (self.location)
    {
        self.locationCell.detailTextLabel.text = self.location;
    }
    //add search button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                              target:self action:@selector(searchBarSearchButtonClicked)];
    
}

#pragma mark - UISearchBar delegate
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    
    self.tableView.scrollEnabled = NO;
    //add cancel button when keyboard appears
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:self action:@selector(cancelSearchButtonClick)];
    
}
- (void) searchBarSearchButtonClicked {
    
    NSLog(@"@%@",searchBar.text);
    [self performSegueWithIdentifier:@"searchResultsTransition" sender:self];
    
}

-(void) cancelSearchButtonClick {
    [searchBar resignFirstResponder];
    
    self.navigationItem.leftBarButtonItem = nil;
    self.tableView.scrollEnabled = YES;
    
    [self.tableView reloadData];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        [self searchBarSearchButtonClicked];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[CircleSelectCategoryTableViewController class]]) {
        CircleSelectCategoryTableViewController *vc = (CircleSelectCategoryTableViewController *)segue.destinationViewController;
        vc.delegate = self;
        vc.selectedCategories = self.categories;
    }
    if ([segue.destinationViewController isKindOfClass:[CircleSelectLocationViewController class]]) {
        CircleSelectLocationViewController *vc = (CircleSelectLocationViewController *)segue.destinationViewController;
        NSLog(@"Prepare for segue. Location: %@", self.location);
        vc.delegate = self;
        vc.searchText = self.locationCell.detailTextLabel.text;
        
    }
   if ([segue.destinationViewController isKindOfClass:[CircleSearchResultsTableViewController class]]) {
       PFQuery *query = [PFQuery queryWithClassName:@"Event"];
       if(![self.categoryCell.detailTextLabel.text isEqualToString:@""])
       {
           [query whereKey:@"category" containedIn:self.categories];
       }
       if(![self.locationCell.detailTextLabel.text isEqualToString:@""])
       {
           [query whereKey:@"location" nearGeoPoint:self.point withinMiles:50.0];
       }
       if(![searchBar.text isEqualToString:@""])
       {
        
           [query whereKey:@"name" containsString:searchBar.text];
       }

       //TODO; be able to search by dates
       //NSLog(@"LOGGED@%@",[query get:@"category"]);
       [segue.destinationViewController setMyQuery:query];
    }
    
    
}

- (void)userSelectedCategories:(NSArray *)categories {
    self.categories = categories;
}

#pragma mark - CityAutocompleteTableViewcontrollerDelegate methods
- (void) cityAutocompleteTableViewController:(CircleSelectLocationViewController *)controller didSelectCityWithDictionary:(NSDictionary *)dict; {
    NSLog(@"User selected location: %@", dict);
    self.locationCell.detailTextLabel.text = [dict objectForKey:@"description"];
    [self.connection getGoogleObjectDetails:[dict objectForKey:@"reference"]];
}

- (void) selectionCancelledInCityAutocompleteTableViewController:(CircleSelectLocationViewController *)controller; {
    self.point = nil;
    self.location = nil;
    self.locationCell.detailTextLabel.text = @"";
}

#pragma mark - GooglePlacesConnection delegate
- (void) googlePlacesConnection:(GooglePlacesConnection *)conn didFinishLoadingWithGooglePlacesObject:(GooglePlacesObject *)detailObject; {
    NSLog(@"Details loaded! \n\n%@", detailObject);
    self.point = [PFGeoPoint geoPointWithLatitude:detailObject.coordinate.latitude longitude:detailObject.coordinate.longitude];
}

- (void) googlePlacesConnection:(GooglePlacesConnection *)conn didFailWithError:(NSError *)error; {
    NSLog(@"Main GPC error: %@", error);
}

@end
