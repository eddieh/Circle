//
//  CircleSearchEventTableViewController.m
//  Circle
//
//  Created by Sam Olson on 4/10/12.
//  Copyright (c) 2012 Northern Arizona University. All rights reserved.
//

#import "CircleSearchEventTableViewController.h"

@interface CircleSearchEventTableViewController ()
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSString *location;
@end

@implementation CircleSearchEventTableViewController
@synthesize categoryCell = _categoryCell;
@synthesize categories = _categories;
@synthesize locationCell = _locationCell;
@synthesize location = _location;
@synthesize connection = _connection;

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
    
    if (self.categories) {
        for (NSString *category in self.categories) {
            categoryString = [categoryString stringByAppendingFormat:@"%@, ", category];
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
                                              target:self action:@selector(searchBarSearchButtonClicked:)];
    
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    
    self.tableView.scrollEnabled = NO;
    //add cancel button when keyboard appears
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:self action:@selector(cancelSearchButtonClick:)];
    
}
- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    
    
}

-(void) cancelSearchButtonClick:(id)sender{
    [searchBar resignFirstResponder];
    
    self.navigationItem.leftBarButtonItem = nil;
    self.tableView.scrollEnabled = YES;
    
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     */
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[CircleSelectCategoryTableViewController class]]) {
        CircleSelectCategoryTableViewController *vc = (CircleSelectCategoryTableViewController *)segue.destinationViewController;
        vc.delegate = self;
        vc.selectedCategories = self.categories;
    }
    if ([segue.destinationViewController isKindOfClass:[CircleSelectLocationViewController class]]) {
        CircleSelectLocationViewController *vc = (CircleSelectLocationViewController *)segue.destinationViewController;
        vc.delegate = self;
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


#pragma mark - GooglePlacesConnection delegate
- (void) googlePlacesConnection:(GooglePlacesConnection *)conn didFinishLoadingWithGooglePlacesObject:(GooglePlacesObject *)detailObject; {
    NSLog(@"Details loaded! \n\n%@", detailObject);
}

- (void) googlePlacesConnection:(GooglePlacesConnection *)conn didFailWithError:(NSError *)error; {
    NSLog(@"Main GPC error: %@", error);
}

@end
