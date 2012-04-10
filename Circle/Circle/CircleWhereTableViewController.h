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

@property (strong, nonatomic) PFObject *event;

@end
