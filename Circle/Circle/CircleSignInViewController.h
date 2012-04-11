//
//  CircleSignInViewController.h
//  Circle
//
//  Created by Joshua Conner on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleSignUpViewController.h"

/**
 * These are the CircleSignInDelegate protocol methods. Whichever viewcontroller presents this ViewController
 * modally must implement these methods and respond to when the user signs in successfully or cancels sign in.
 */
@protocol CircleSignInDelegate <NSObject>
@required
- (void) signInSuccessful;
- (void) userCancelledSignIn;
@end

@interface CircleSignInViewController : UIViewController <UITextFieldDelegate, CircleSignUpDelegate, PF_MBProgressHUDDelegate>
//UI Properties
@property (weak, nonatomic) IBOutlet UILabel *callToActionLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

//Non-UI properties
@property (strong, nonatomic) NSObject<CircleSignInDelegate> *delegate;

- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)connectWithFacebookButtonPressed;
- (IBAction)signInButtonPressed;
@end
