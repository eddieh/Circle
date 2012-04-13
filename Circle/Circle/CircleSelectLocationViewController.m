//
//  CityAutocompleteTableViewController.m
//  GooglePlacesSearch
//
//  Created by Joshua Conner on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleSelectLocationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "GooglePlacesConnection.h"

@interface CircleSelectLocationViewController ()
@property (strong, nonatomic) GooglePlacesConnection  *googlePlacesConnection;
@end

@implementation CircleSelectLocationViewController
@synthesize searchBar = _searchBar;
@synthesize locationManager = _locationManager;
@synthesize currentLocation = _currentLocation;
@synthesize googlePlacesConnection = _googlePlacesConnection;


@synthesize urlConnection = _urlConnection;
@synthesize responseData = _responseData;
@synthesize locations = _locations;
@synthesize delegate = _delegate;

- (void)viewWillAppear:(BOOL)animated {
    [self.searchBar becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.responseData = [[NSMutableData data] init];
    
    [[self locationManager] startUpdatingLocation];
    
    
    self.googlePlacesConnection = [[GooglePlacesConnection alloc] initWithDelegate:self];
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setLocations:nil];
    [self setCurrentLocation:nil];
    [self setUrlConnection:nil];
    [self setResponseData:nil];
    [self setLocations:nil];
    self.googlePlacesConnection.delegate = nil;
    [self setDelegate:nil];
    
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
    return [self.locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LocationCell";
	
	// Dequeue or create a cell of the appropriate type.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell                = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    //UPDATED from locations to locationFilter results
    NSDictionary *suggestion = [self.locations objectAtIndex:[indexPath row]];
    
    NSLog(@"Suggestion: %@", suggestion);
    cell.textLabel.text = [suggestion objectForKey:@"description"];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [self.locations objectAtIndex:indexPath.row];
    NSLog(@"did select: %@", dict);
    
    [self.delegate cityAutocompleteTableViewController:self didSelectCityWithDictionary:dict];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Google Places connection delegate
- (void) googlePlacesConnection:(GooglePlacesConnection *)conn didFailWithError:(NSError *)error; {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error finding place - Try again" 
//                                                    message:[error localizedDescription] 
//                                                   delegate:nil 
//                                          cancelButtonTitle:@"OK" 
//                                          otherButtonTitles: nil];
//    [alert show];
}

- (void) googlePlacesConnection:(GooglePlacesConnection *)conn didFinishLoadingWithSuggestions:(NSMutableArray *)suggestions; {
    self.locations = suggestions;
    [self.tableView reloadData];
}

- (void) googlePlacesConnection:(GooglePlacesConnection *)conn didFinishLoadingWithGooglePlacesObject:(GooglePlacesObject *)detailObject; {
    
}



#pragma mark - UISearchBar delegate
//NEW - to handle filtering
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //only search if there's input!
    if (![searchBar.text isEqualToString:@""]) { 
        [self.googlePlacesConnection getGoogleObjectsWithQuery:searchBar.text andCoordinates:CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude)];
    }
}

@end
