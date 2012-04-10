//
//  CircleSignUpViewController.m
//  Circle
//
//  Created by Joshua Conner on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleSignUpViewController.h"
#import "Parse/Parse.h"

@interface CircleSignUpViewController () {
    PF_MBProgressHUD *HUD;
}

@end

@implementation CircleSignUpViewController
@synthesize nameTextField;
@synthesize emailTextField;
@synthesize passwordTextField;
@synthesize repeatPasswordTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setRepeatPasswordTextField:nil];
    [self setNameTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)signUpButtonPressed {
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
        return NO;
    } else {
        PFUser *newUser = [PFUser user];
        newUser.username = self.emailTextField.text;
        newUser.password = self.passwordTextField.text;
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                //successful signup!
            } else {
                //signup error: display the error!
            }
        }];
    }
    return YES;
}
@end
