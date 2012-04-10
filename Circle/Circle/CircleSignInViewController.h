//
//  CircleSignInViewController.h
//  Circle
//
//  Created by Joshua Conner on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CircleSignInDelegate
@required
- (void) signInSuccessful;
@end

@interface CircleSignInViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *callToActionLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)dismissKeyboard:(id)sender;
@end
