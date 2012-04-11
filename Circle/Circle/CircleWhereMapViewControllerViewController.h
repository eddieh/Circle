//
//  CircleWhereMapViewControllerViewController.h
//  Circle
//
//  Created by Eddie Hillenbrand on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface CircleWhereMapViewControllerViewController : UIViewController <UISearchBarDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
