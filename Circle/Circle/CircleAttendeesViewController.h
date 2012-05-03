//
//  CircleAttendeesViewController.h
//  Circle
//
//  Created by Sam Olson on 4/30/12.
//  Copyright (c) 2012 Northern Arizona University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@interface CircleAttendeesViewController : PFQueryTableViewController

@property (strong,nonatomic) NSMutableArray *filteredAttendees;
@property (strong, nonatomic) PFObject *event;

@end
