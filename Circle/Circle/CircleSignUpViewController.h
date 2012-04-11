//
//  CircleSignUpViewController.h
//  Circle
//
//  Created by Joshua Conner on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

/**
 * This is the delegate protocol for the CircleSignUpViewController's delegate.
 *
 * Whichever view (probably the CircleSignInViewController) presents this view modally has to respond
 * to these methods.
 */
@protocol CircleSignUpDelegate <NSObject>
@required
- (void) signUpSuccessful;
@end

@interface CircleSignUpViewController : UIViewController <UITextFieldDelegate, PF_MBProgressHUDDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
//UI Elements
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

//Non-UI properties
@property (weak, nonatomic) NSObject<CircleSignUpDelegate> *delegate;

- (IBAction)dismissKeyboard;
- (IBAction)signUpButtonPressed;
- (IBAction)cameraButtonPressed:(UIButton *)sender;
@end
