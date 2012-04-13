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
//#import "CircleSearchResultsTableViewController.h"



@protocol CircleResultsDelegate <NSObject>
@required
-(void) userSelectedFilter:(NSArray *) categories: (NSString*) location;
@optional
@end
@interface CircleSearchEventTableViewController : UITableViewController <CircleCategoryDelegate, CityAutocompleteTableViewControllerDelegate, GooglePlacesConnectionDelegate>
{
    IBOutlet UISearchBar *searchBar;
    
}
-(void) searchButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableViewCell *categoryCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *locationCell;
@property (strong, nonatomic) GooglePlacesConnection *connection;
@property NSObject<CircleResultsDelegate> *delegate;

- (void) cityAutocompleteTableViewController:(CircleSelectLocationViewController *)controller didSelectCityWithDictionary:(NSDictionary *)dict;


@end

