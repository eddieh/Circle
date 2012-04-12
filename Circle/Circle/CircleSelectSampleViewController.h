//
//  CircleSelectSampleViewController.h
//  Circle
//
//  Created by Sam Olson on 4/11/12.
//  Copyright (c) 2012 Northern Arizona University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleSelectSampleViewController : UITableViewController
{
    NSMutableArray *listOfItems;
    NSMutableArray *copyListOfItems;
    IBOutlet UISearchBar *searchBar;
    BOOL searching;
    BOOL letUserSelectRow;
}
- (void) searchTableView;
- (void) doneSearching_Clicked:(id)sender;
    
@property(nonatomic,retain)NSMutableArray *dataSource;

@property (nonatomic, strong) NSArray *carMakes;
@property (nonatomic, strong) NSArray *carModels;



@end
