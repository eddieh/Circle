//
//  MSENameDetailsTableViewController.h
//  MultiStepEditor
//
//  Created by Eddie Hillenbrand on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIPlaceHolderTextView;
@class PFObject;

@interface CircleNameDetailsTableViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *detailsTextView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@property (strong, nonatomic) PFObject *event;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

- (IBAction)cancel:(id)sender;

@end
