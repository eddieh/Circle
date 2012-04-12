//
//  CircleSelectSampleViewController.m
//  Circle
//
//  Created by Sam Olson on 4/11/12.
//  Copyright (c) 2012 Northern Arizona University. All rights reserved.
//

#import "CircleSelectSampleViewController.h"
#import "CircleSelectSampleCell.h"


//@interface CircleSelectSampleViewController ()

//@end

@implementation CircleSelectSampleViewController
@synthesize carMakes = _carMakes; 
@synthesize carModels = _carModels;


//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.carMakes = [[NSArray alloc]
                     initWithObjects:@"Chevy",
                     @"BMW",
                     @"Toyota",
                     @"Volvo",
                     @"Smart", nil];
    
    self.carModels = [[NSArray alloc]
                      initWithObjects:@"Volt",
                      @"Mini",
                      @"Venza",
                      @"S60",
                      @"Fortwo", nil];
    
    //Initialize the array.
    listOfItems = [[NSMutableArray alloc] init];
    
    NSArray *countriesToLiveInArray = [NSArray arrayWithObjects:@"Iceland", @"Greenland", @"Switzerland", @"Norway", @"New Zealand", @"Greece", @"Rome", @"Ireland", nil];
    NSDictionary *countriesToLiveInDict = [NSDictionary dictionaryWithObject:countriesToLiveInArray forKey:@"Countries"];
    
    NSArray *countriesLivedInArray = [NSArray arrayWithObjects:@"India", @"U.S.A", nil];
    NSDictionary *countriesLivedInDict = [NSDictionary dictionaryWithObject:countriesLivedInArray forKey:@"Countries"];
    
    [listOfItems addObject:countriesToLiveInDict];
    [listOfItems addObject:countriesLivedInDict];
    
    //Initialize the copy array.
    copyListOfItems = [[NSMutableArray alloc] init];
    
    //Set the title
    //self.navigationItem.title = @"Countries";
    
    //Add the search bar
    self.tableView.tableHeaderView = searchBar;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    searching = NO;
    letUserSelectRow = YES;
    
}

//- (void)viewDidUnload
//{
//    [super viewDidUnload];
//    // Release any retained subviews of the main view.
//    // e.g. self.myOutlet = nil;
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    
    //Remove all objects first.
    [copyListOfItems removeAllObjects];
    
    if([searchText length] > 0) {
        
        searching = YES;
        letUserSelectRow = YES;
        self.tableView.scrollEnabled = YES;
        [self searchTableView];
    }
    else {
        
        searching = NO;
        letUserSelectRow = NO;
        self.tableView.scrollEnabled = NO;
    }
    
    [self.tableView reloadData];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    
    searching = YES;
    letUserSelectRow = NO;
    self.tableView.scrollEnabled = NO;
    
    //Add the done button.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                               target:self action:@selector(doneSearching_Clicked:)];
    NSLog(@"HELLO WORLD");
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    
    [self searchTableView];
}

- (void) searchTableView {
    
    NSString *searchText = searchBar.text;
    NSMutableArray *searchArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dictionary in listOfItems)
    {
        NSArray *array = [dictionary objectForKey:@"Countries"];
        [searchArray addObjectsFromArray:array];
    }
    
    for (NSString *sTemp in searchArray)
    {
        NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if (titleResultsRange.length > 0)
            [copyListOfItems addObject:sTemp];
    }
    
    NSLog(@"@%@",copyListOfItems);
    
    searchArray = nil;
    
    
}

- (void) doneSearching_Clicked:(id)sender {
    
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    
    letUserSelectRow = YES;
    searching = NO;
    self.navigationItem.rightBarButtonItem = nil;
    self.tableView.scrollEnabled = YES;
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (searching)
        return 1;
    else
        return [listOfItems count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (searching)
        return [copyListOfItems count];
    else {
        
        //Number of rows it should expect should be based on the section
        NSDictionary *dictionary = [listOfItems objectAtIndex:section];
        NSArray *array = [dictionary objectForKey:@"Countries"];
        return [array count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(searching)
        return @"";
    
    if(section == 0)
        return @"Countries to visit";
    else
        return @"Countries visited";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
    }
    
    // Set up the cell...
    
    if(searching)
        cell.textLabel.text = [copyListOfItems objectAtIndex:indexPath.row];
    else {
        
        //First get the dictionary object
        NSDictionary *dictionary = [listOfItems objectAtIndex:indexPath.section];
        NSArray *array = [dictionary objectForKey:@"Countries"];
        NSString *cellValue = [array objectAtIndex:indexPath.row];
        cell.textLabel.text = cellValue;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Get the selected country
    
    NSString *selectedCountry = nil;
    
    if(searching)
        selectedCountry = [copyListOfItems objectAtIndex:indexPath.row];
    else {
        
        NSDictionary *dictionary = [listOfItems objectAtIndex:indexPath.section];
        NSArray *array = [dictionary objectForKey:@"Countries"];
        selectedCountry = [array objectAtIndex:indexPath.row];
    }
    
    //Initialize the detail view controller and display it.
//    DetailViewController *dvController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
//    dvController.selectedCountry = selectedCountry;
//    [self.navigationController pushViewController:dvController animated:YES];
//    [dvController release];
//    dvController = nil;
}

//
//#pragma mark - Table view data source
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return [self.carModels count];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"carTableCell";
//    
//    CircleSelectSampleCell *cell = [tableView
//                              dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[CircleSelectSampleCell alloc]
//                initWithStyle:UITableViewCellStyleDefault 
//                reuseIdentifier:CellIdentifier];
//    }
//    
//    // Configure the cell...
//    cell.makeLabel.text = [self.carMakes 
//                           objectAtIndex: [indexPath row]];
//    
//    cell.modelLabel.text = [self.carModels 
//                            objectAtIndex:[indexPath row]];
//    
//    
//    return cell;
//}

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

@end
