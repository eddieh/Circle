//
//  CircleSignInViewController.m
//  Circle
//
//  Created by Joshua Conner on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleSignInViewController.h"
#import "CircleSignUpViewController.h"
#import "Parse/Parse.h"

@interface CircleSignInViewController () {
    BOOL isVoluntarySignIn;
    PF_MBProgressHUD *HUD;
}

@end

@implementation CircleSignInViewController
@synthesize callToActionLabel;
@synthesize emailTextField;
@synthesize passwordTextField;
@synthesize delegate;

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
    
    //change "You need a Circle account to do this" to "Sign in" if the user came to this view by pressing
    //sign in button
    if (isVoluntarySignIn) 
        self.callToActionLabel.text = @"Sign in to your Circle account!";
}

- (void)viewDidUnload
{
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setCallToActionLabel:nil];
    [self setDelegate:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UI Callback methods
//the background above the sign in form is a button that the user can "press" to dismiss the keyboard
- (IBAction)dismissKeyboard:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate method
//move between textfields, or do signup, when the user hits enter on the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [self doSignIn];
    }
    return YES;
}

- (void) doSignIn {
    HUD = [self configureHUD];
        
        //show the HUD, attempt to do signup...
        HUD.labelText = @"Signing up...";
        HUD.dimBackground = YES;
        [HUD show:YES];
        
    [PFUser logInWithUsernameInBackground:self.emailTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        if (user) {
            // Hooray! Let them use the app now.
            [self setHUDCustomViewWithImageNamed:@"37x-Checkmark.png" labelText:@"Success" detailsLabelText:nil hideDelay:1.5];
            
            [self.delegate signInSuccessful];
        } else {
            // The login failed. Check error to see why.
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            // Show the errorString somewhere and let the user try again.
            [self setHUDCustomViewWithImageNamed:@"x.png" labelText:@"Error" detailsLabelText:errorString hideDelay:4.0];
        }
    }];
   
}


#pragma mark - HUD helper methods
/**
 * The way the HUD is supposed to work is that you init it every time you use it, so use this method to configure
 * with appropriate fonts and delegate and all that.
 */
- (PF_MBProgressHUD *)configureHUD {
    //init and set up HUD    
    HUD = [[PF_MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0];
    HUD.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    
    return HUD;
}

/**
 * Displays a message and image in the HUD and then hides it after hideDelay.
 */
- (void)setHUDCustomViewWithImageNamed:(NSString *)imageName 
                             labelText:(NSString *)labelText 
                      detailsLabelText:(NSString *)detailsLabelText 
                             hideDelay:(float)hideDelay {
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    HUD.mode = PF_MBProgressHUDModeCustomView;
    HUD.labelText = labelText;
    HUD.detailsLabelText = detailsLabelText;
    [HUD hide:YES afterDelay:hideDelay];
}


#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(PF_MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidden
	[HUD removeFromSuperview];
	HUD = nil;
}

#pragma mark - CircleSignUpDelegate methods
- (void) signUpSuccessful; {
    [self.delegate signInSuccessful];
}
@end