//
//  CircleOverviewSaveTableViewController.h
//  Circle
//
//  Created by Eddie Hillenbrand on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFObject;

@interface CircleOverviewSaveTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *detailsCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *whereCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *startsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *endsCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *categoryCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *photoCell;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (strong, nonatomic) PFObject *event;

@end
