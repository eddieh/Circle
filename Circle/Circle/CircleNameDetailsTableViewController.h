//
//  MSENameDetailsTableViewController.h
//  MultiStepEditor
//
//  Created by Eddie Hillenbrand on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFObject;

@interface CircleNameDetailsTableViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *detailsTextField;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@property (strong, nonatomic) PFObject *event;

@end
