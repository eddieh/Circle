//
//  CircleSignUpViewController.h
//  Circle
//
//  Created by Joshua Conner on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@interface CircleSignUpViewController : UIViewController <UITextFieldDelegate, PF_MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;

- (IBAction)dismissKeyboard;
- (IBAction)signUpButtonPressed;
@end
