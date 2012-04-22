//
//  CircleSearchEventTableViewController.h
//  Circle
//
//  Created by Sam Olson on 4/10/12.
//  Copyright (c) 2012 Northern Arizona University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleSelectCategoryTableViewController.h"
#import "CircleSelectLocationViewController.h"
#import "GooglePlacesConnection.h"
#import "CircleSelectDateViewController.h"




@interface CircleSearchEventTableViewController : UITableViewController <CircleCategoryDelegate, CityAutocompleteTableViewControllerDelegate, GooglePlacesConnectionDelegate, CircleDateDelegate>
{
    IBOutlet UISearchBar *searchBar;
}

@property (weak, nonatomic) IBOutlet UITableViewCell *categoryCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *locationCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *dateCell;
@property (strong, nonatomic) GooglePlacesConnection *connection;

- (void) cityAutocompleteTableViewController:(CircleSelectLocationViewController *)controller didSelectCityWithDictionary:(NSDictionary *)dict;


@end