//
//  MSEWhereTableViewController.h
//  MultiStepEditor
//
//  Created by Eddie Hillenbrand on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFObject;

@interface CircleWhereTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITableViewCell *venueCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *savedAddressesCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *addAddressCell;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@property (strong, nonatomic) PFObject *event;

@end
