//
//  CityAutocompleteTableViewController.h
//  GooglePlacesSearch
//
//  Created by Joshua Conner on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GooglePlacesConnection.h"
@protocol CityAutocompleteTableViewControllerDelegate;

@interface CircleSelectLocationViewController : UITableViewController <UISearchBarDelegate, GooglePlacesConnectionDelegate>

@property (strong, nonatomic) NSObject<CityAutocompleteTableViewControllerDelegate> *delegate;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (nonatomic, strong) NSURLConnection   *urlConnection;
@property (nonatomic, strong) NSMutableData     *responseData;
@property (nonatomic, strong) NSMutableArray    *locations;
@end

@protocol CityAutocompleteTableViewControllerDelegate <NSObject>
@required
- (void) cityAutocompleteTableViewController:(CircleSelectLocationViewController *)controller didSelectCityWithDictionary:(NSDictionary *)dict;
@end