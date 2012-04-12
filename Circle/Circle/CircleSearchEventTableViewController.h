//
//  CircleSearchEventTableViewController.h
//  Circle
//
//  Created by Sam Olson on 4/10/12.
//  Copyright (c) 2012 Northern Arizona University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleSelectCategoryTableViewController.h"

@interface CircleSearchEventTableViewController : UITableViewController <CircleCategoryDelegate>
@property (weak, nonatomic) IBOutlet UITableViewCell *categoryCell;

@end
