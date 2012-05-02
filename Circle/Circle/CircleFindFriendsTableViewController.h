//
//  CircleFindFriendsTableViewController.h
//  Circle
//
//  Created by Sam Olson on 4/30/12.
//  Copyright (c) 2012 Northern Arizona University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@interface CircleFindFriendsTableViewController : PFQueryTableViewController <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSString *searchText;
@property (strong, nonatomic) NSString *nameTextField;
@property (strong, nonatomic) NSString *emailTextField;
@property (strong, nonatomic) NSMutableArray *filteredFriends;



@end
