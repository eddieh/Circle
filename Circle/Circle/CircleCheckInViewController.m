//
//  CircleCheckInViewController.m
//  Circle
//
//  Created by Joshua Conner on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleCheckInViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface CircleCheckInViewController () {
    BOOL doFacebookCheckIn;
    BOOL doFoursquareCheckIn;
    PF_MBProgressHUD *HUD;
    
}

@end

@implementation CircleCheckInViewController
@synthesize eventTitleLabel;
@synthesize eventDescriptionLabel;
@synthesize descriptionTextView;
@synthesize cameraButton;
@synthesize event = _event;
@synthesize imageFile = _imageFile;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - viewWillAppear, viewDidLoad, shouldAutoRotate, etc.
- (void)viewWillAppear:(BOOL)animated {
    [self.descriptionTextView becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.eventTitleLabel.text = [self.event objectForKey:@"name"];
    self.eventDescriptionLabel.text = [self.event objectForKey:@"description"];
    
    //configure description text view
    self.descriptionTextView.placeholder = @"What are you doing? (Optional)";
    self.descriptionTextView.backgroundColor = [UIColor whiteColor];
    self.descriptionTextView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
}

- (void)viewDidUnload
{
    [self setEventTitleLabel:nil];
    [self setDescriptionTextView:nil];
    [self setEvent:nil];
    
    [self setEventDescriptionLabel:nil];
    [self setCameraButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UI callback methods
- (IBAction)cameraButtonPressed:(UIButton *)sender {
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take a new photo", @"Choose photo from library", nil];
    [a show];
}

- (IBAction)foursquareButtonPressed:(UIButton *)sender {
    doFoursquareCheckIn = !doFoursquareCheckIn;
    sender.selected = doFoursquareCheckIn;
}

- (IBAction)facebookButtonPressed:(UIButton *)sender {
    doFacebookCheckIn = !doFacebookCheckIn;
    sender.selected = doFacebookCheckIn;
}

- (IBAction)checkInButtonPressed {
    PFObject *checkIn = [PFObject objectWithClassName:@"CheckIn"];
    [checkIn setObject:self.event forKey:@"event"];
    [checkIn setObject:self.descriptionTextView.text forKey:@"text"];
    [checkIn setObject:[PFUser user] forKey:@"user"];
    
    HUD = [[PF_MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    HUD.labelText = @"Checking in...";
    
    [HUD show:YES];
    [checkIn saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // The event saved successfully.
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            HUD.mode = PF_MBProgressHUDModeCustomView;
            [HUD hide:YES afterDelay:2];
            
        } else {
            // There was an error saving the event.
            HUD.labelText = @"Error!";
            HUD.detailsLabelText = @"We were unable to save your check-in. Please try again later.";
            [HUD hide:YES afterDelay:4];
        }
    }];
    
    
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

// For responding to the user accepting a newly-captured picture
- (void)imagePickerController: (UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    //UIImage *originalImage, *editedImage, *bigImage, *imageToSave;
    UIImage *image;
    
    // Handle a still image capture
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        //editedImage = (UIImage *) [info objectForKey: UIImagePickerControllerEditedImage];
        image = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
        NSData *imageData = UIImagePNGRepresentation(image);
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
        [imageFile saveInBackground];
//        if (editedImage) {
//            bigImage = editedImage;
//        } else {
//            bigImage = originalImage;
//        }
//        if (!picker.title) {
//            // Save the new image (original or edited) to the Camera Roll
//            UIImageWriteToSavedPhotosAlbum (bigImage, nil, nil , nil);
//        }
//        imageToSave = [UIImage imageWithImage:bigImage scaledToSizeWithSameAspectRatio:CGSizeMake(150.0, 150.0)];
//        // Set the profileButton image to the newly-captured picture
//        profileImage = imageToSave;
//        [profileButton setImage:imageToSave borderWidth:5.0 shadowDepth:7.0 controlPointXOffset:30.0 controlPointYOffset:75.0 forState:UIControlStateNormal];
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


#pragma mark - MBProgressHUDDelegate methods

- (void)hudWasHidden:(PF_MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}


@end