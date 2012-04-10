//
//  CircleCheckInViewController.h
//  Circle
//
//  Created by Joshua Conner on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"
#import "Parse/Parse.h"

@interface CircleCheckInViewController : UIViewController <PF_MBProgressHUDDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@property (strong, nonatomic) PFObject *event;
@property (strong, nonatomic) PFFile *imageFile;

- (IBAction)cameraButtonPressed:(UIButton *)sender;
- (IBAction)foursquareButtonPressed:(UIButton *)sender;
- (IBAction)facebookButtonPressed:(UIButton *)sender;
- (IBAction)checkInButtonPressed;
@end
