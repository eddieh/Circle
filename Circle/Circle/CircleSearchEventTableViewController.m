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
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) PFGeoPoint *point;
@end

@implementation CircleSearchEventTableViewController
@synthesize categoryCell = _categoryCell;
@synthesize categories = _categories;
@synthesize locationCell = _locationCell;
@synthesize location = _location;
//added
@synthesize dateCell = _dateCell;
@synthesize startDate = _startDate;
@synthesize endDate = _endDate;
@synthesize dateFormatter = _dateFormatter;

@synthesize connection = _connection;
@synthesize point = _point;

- (void)viewDidLoad {
    self.connection = [[GooglePlacesConnection alloc] initWithDelegate:self];
    // Set up the date formatter
    self.dateFormatter = [[NSDateFormatter alloc] init];
	[self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [self.dateFormatter setDateFormat:@"EEE M/d/yy"];
    searchBar.text = @"";
}

- (void)viewDidUnload
{
    [self setCategoryCell:nil];
    [self setCategories:nil];
    [self setLocation:nil];
    [self setLocationCell:nil];
    [self setStartDate:nil];
    [self setEndDate:nil];
    [self setDateCell:nil];
    [self setDateFormatter:nil];
    [self setConnection:nil];
    [self setPoint:nil];
    [super viewDidUnload];
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
    else {
        self.categoryCell.detailTextLabel.text = @"";
    }
    //if start date hasnt been declared, set it to current date
    if (!self.startDate){
        self.startDate = [[NSDate alloc]init];
        self.startDate = [self.dateFormatter dateFromString:[self.dateFormatter stringFromDate:self.startDate]];
    }
    NSLog(@"Start Date(Event): %@",self.startDate);
    NSLog(@"End Date(Event): %@",self.endDate);
    
    //adds dates to window with a to between the start and end date if the end date is NOT null
    if (self.startDate)
    {
        NSLog(@"end1%@",self.endDate);
        //NSLog(@"end1%@",[self.endDate compare:self.startDate]);
        if (self.endDate && !([self.endDate timeIntervalSinceDate:self.startDate]<60.0f))
        {
            NSLog(@"called");
            NSString *selectedDates = [NSString stringWithFormat:@"%@%@%@",[self.dateFormatter stringFromDate:self.startDate],@" to ",[self.dateFormatter stringFromDate:self.endDate]];
            self.dateCell.detailTextLabel.text = selectedDates;
        }
        else {
            NSString *selectedDates = [self.dateFormatter stringFromDate:self.startDate];
            self.dateCell.detailTextLabel.text = selectedDates;
        }
    }

    //add search button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                              target:self action:@selector(searchButtonClicked)];
    
}

#pragma mark - UISearchBar delegate
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    
    self.tableView.scrollEnabled = NO;
    //add cancel button when keyboard appears
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:self action:@selector(cancelSearchButtonClick)];
}


- (void) searchButtonClicked {
    
    NSLog(@"CALLEDEDEDED%@",searchBar.text);
    
    [self performSegueWithIdentifier:@"searchResultsTransition" sender:self];
}
-(void) searchBarSearchButtonClicked:(UISearchBar *) searchBar{
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
        [self searchButtonClicked];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[CircleSelectCategoryTableViewController class]]) {
        CircleSelectCategoryTableViewController *vc = (CircleSelectCategoryTableViewController *)segue.destinationViewController;
        vc.delegate = self;
        vc.selectedCategories = self.categories;
    }
    else if ([segue.destinationViewController isKindOfClass:[CircleSelectLocationViewController class]]) {
        CircleSelectLocationViewController *vc = (CircleSelectLocationViewController *)segue.destinationViewController;
        NSLog(@"Prepare for segue. Location: %@", self.location);
        vc.delegate = self;
        vc.searchText = self.locationCell.detailTextLabel.text;
    }
   else if ([segue.destinationViewController isKindOfClass:[CircleSearchResultsTableViewController class]]) {
       PFQuery *query = [PFQuery queryWithClassName:@"Event"];
       if(![self.categoryCell.detailTextLabel.text isEqualToString:@""])
       {
           [query whereKey:@"category" containedIn:self.categories];
       }
       if(![self.locationCell.detailTextLabel.text isEqualToString:@""])
       {
           [query whereKey:@"location" nearGeoPoint:self.point withinMiles:50.0];
       }
       //checks to see if a start date exists, if not, it uses the current date
       if(![self.dateCell.detailTextLabel.text isEqualToString:@""])
       {
           if (self.startDate) {
               [query whereKey:@"startDate" greaterThanOrEqualTo:self.startDate];
           }
           //if the start date and end date are within 1 minute, the end date is not used
           if ([self.endDate timeIntervalSinceDate:self.startDate]>60.0f)
           {
               [query whereKey:@"startDate" lessThanOrEqualTo:self.endDate];
           } else {
               //restrict search to 24 hour window
               NSDate *oneDayLater = [self.startDate dateByAddingTimeInterval:24*60*60];
               [query whereKey:@"startDate" lessThanOrEqualTo:oneDayLater];
               NSLog(@"one day later: %@", oneDayLater);
           }
       }
//       else {
//           NSDate *currentDate = [NSDate date];
//           [query whereKey:@"startDate" greaterThanOrEqualTo:currentDate];
//       }
       if(![searchBar.text isEqualToString:@""])
       {
           NSLog(@"searchtextCalled%@",searchBar.text);
           [query whereKey:@"name" matchesRegex:searchBar.text modifiers:@"i"];
       }
       [segue.destinationViewController setMyQuery:query];
    }
    //Date delegate
    else if ([segue.destinationViewController isKindOfClass:[CircleSelectDateViewController class]]) {
        CircleSelectDateViewController *vc = (CircleSelectDateViewController *)segue.destinationViewController;
        vc.delegate = self;
        vc.selectedStartDate = self.startDate;
        vc.selectedEndDate = self.endDate;
    }
    
    
}

#pragma mark - userSelectedDate delegate
-(void) userSelectedStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;{
    NSLog(@"user selected date");
    self.startDate = startDate;
    self.endDate = endDate;
    
    [self.tableView reloadData];
}

#pragma mark - userSelectedCategories delegate
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
