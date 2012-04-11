//
//  CircleSignUpViewController.m
//  Circle
//
//  Created by Joshua Conner on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleSignUpViewController.h"
#import "Parse/Parse.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface CircleSignUpViewController () {
    PF_MBProgressHUD *HUD;
}
@property (strong, nonatomic) PFFile *imageFile;
@end

@implementation CircleSignUpViewController
@synthesize nameTextField;
@synthesize emailTextField;
@synthesize passwordTextField;
@synthesize repeatPasswordTextField;
@synthesize cameraButton;
@synthesize delegate = _delegate;
@synthesize imageFile = _imageFile;

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
    [self setCameraButton:nil];
    [self setDelegate:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UI Callback methods
- (IBAction)dismissKeyboard {
    //does what it says on the tin!
    [self.view endEditing:YES];
}

- (IBAction)signUpButtonPressed {
    [self doSignUp]; // duh.
}

// shows an alert dialog allowing the user to choose where to take a photo from
// (alertView:clickedButtonAtIndex: is the delegate (responder) method for the alert)
- (IBAction)cameraButtonPressed:(UIButton *)sender {
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take a new photo", @"Choose photo from library", nil];
    [a show];
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //move to next textfield
    if (textField == self.nameTextField) {
        [self.emailTextField becomeFirstResponder];
    } else if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self.repeatPasswordTextField becomeFirstResponder];
    } else {
        //if it's the last textfield, attempt to do the signup
        [self doSignUp];
    }
    return YES;
}

- (void) doSignUp {
    HUD = [self configureHUD];
    
    //sanity checking!
    if (![self.passwordTextField.text isEqualToString:@""] && [self.passwordTextField.text isEqualToString:self.repeatPasswordTextField.text]) {
        
        //show the HUD, attempt to do signup...
        HUD.labelText = @"Signing up...";
        HUD.dimBackground = YES;
        [HUD show:YES];
        
        PFUser *user = [PFUser user];
        user.username = self.emailTextField.text;
        user.password = self.passwordTextField.text;
        user.email = self.emailTextField.text;
        [user setObject:self.nameTextField.text forKey:@"name"];
        
        if (self.imageFile) {
            [user setObject:self.imageFile forKey:@"image"];
        }
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                // Hooray! Let them use the app now.
                [self setHUDCustomViewWithImageNamed:@"37x-Checkmark.png" labelText:@"Success" detailsLabelText:nil hideDelay:1.5];
                
                [self.delegate signUpSuccessful];
                
            } else {
                NSString *errorString = [[error userInfo] objectForKey:@"error"];
                // Show the errorString somewhere and let the user try again.
                [self setHUDCustomViewWithImageNamed:@"x.png" labelText:@"Error" detailsLabelText:errorString hideDelay:4.0];
            }
        }];
        
    } else {
        NSString *detailsLabelText = @"Password fields must match.";
        if ([self.passwordTextField.text isEqualToString:@""])
                detailsLabelText = @"Please enter a password.";


        [HUD show:YES];
        [self setHUDCustomViewWithImageNamed:@"x.png" labelText:@"Error" detailsLabelText:detailsLabelText hideDelay:3.0];
    }
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


#pragma mark - Camera/ImagePicker methods
- (BOOL)startCameraControllerFromViewController: (UIViewController*) controller usingDelegate: (id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate {
    // Check to see if the device has a camera, and the delegate and controller isn't nil
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) || (delegate == nil) || (controller == nil)) {
        return NO;   
    }
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = delegate;
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}

- (BOOL)startImagePickerFromViewController:(UIViewController*) controller usingDelegate:(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate {
    // Check to see if the device has a Photo Library, and the delegate and controller isn't nil
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO) || (delegate == nil) || (controller == nil)) {
        return NO;   
    }
    UIImagePickerController *imagePickerUI = [[UIImagePickerController alloc] init];
    imagePickerUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    imagePickerUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
    imagePickerUI.allowsEditing = NO;
    imagePickerUI.delegate = delegate;
    [controller presentModalViewController:imagePickerUI animated:YES];
    return YES;
}

// For responding to the user tapping Cancel.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated: YES];
}

#pragma mark - UIImagePickerController delegate method
// For responding to the user accepting a newly-captured picture
- (void)imagePickerController: (UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    //UIImage *originalImage, *editedImage, *bigImage, *imageToSave;
    UIImage *image;
    
    // Handle a still image capture
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        image = (UIImage *) [info objectForKey: UIImagePickerControllerEditedImage];
        
        if (!image) {
            image = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
        }
        
        //replace the camera button with the user's chosen image
        [self.cameraButton setImage:image forState:UIControlStateNormal];
        
        //upload the image to Parse
        NSData *imageData = UIImagePNGRepresentation(image);
        self.imageFile = [PFFile fileWithName:@"profile.png" data:imageData];
        [self.imageFile saveInBackground];
        
        //TODO: image saving doesn't work right now
        //        //if the user took the picture, we also save it
        //        if (!picker.title) {
        //            UIImageWriteToSavedPhotosAlbum (image, nil, nil , nil);
        //        }
    }
    
    self.cameraButton.imageView.image = image;
    [self dismissModalViewControllerAnimated: YES];
}


#pragma mark - UIAlertViewDelegate methods

/**
 * callback method when the user clicks a button in the alert window.
 * buttonIndex 0 = cancel, 1 = take new photo, 2 = choose from library
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%d", buttonIndex);
    if (buttonIndex == 1) {
        [self startCameraControllerFromViewController:self usingDelegate:self];
    } else if (buttonIndex == 2) {
        [self startImagePickerFromViewController:self usingDelegate:self];
        
    }
}
@end
