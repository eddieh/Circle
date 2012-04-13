//
//  MSENameDetailsTableViewController.m
//  MultiStepEditor
//
//  Created by Eddie Hillenbrand on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleNameDetailsTableViewController.h"
#import "CircleMainViewController.h"

#import "UIPlaceHolderTextView.h"
#import "Parse/Parse.h"

@interface CircleNameDetailsTableViewController ()

@end

@implementation CircleNameDetailsTableViewController

@synthesize nameTextField;
@synthesize detailsTextView;
@synthesize nextButton;
@synthesize event = _event;
@synthesize cancelButton;


#pragma mark - View lifecycle
//scroll to top of the tableview everytime so the user doesn't get stuck with the details section at the 
//top of their view
- (void)viewWillAppear:(BOOL)animated {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.detailsTextView.placeholder = @"Details";
    self.detailsTextView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    
    if (self.event) {
        self.nameTextField.text = [self.event objectForKey:@"name"];
        self.detailsTextView.text = [self.event objectForKey:@"details"];
    }
    
    [self.nameTextField becomeFirstResponder];
                            
}

- (void)viewDidUnload
{
    [self setNameTextField:nil];
    [self setDetailsTextView:nil];
    [self setNextButton:nil];
    [self setCancelButton:nil];
    [self setDetailsTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameTextField) {
        [self.detailsTextView becomeFirstResponder];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"CreateEventNextSegue"]) {
        id viewController = [segue destinationViewController];
        if ([viewController respondsToSelector:@selector(setEvent:)]) {
            
            // create the event if needed
            if (!self.event) {
                self.event = [PFObject objectWithClassName:@"Event"];
            }
            
            [self.event setObject:self.nameTextField.text forKey:@"name"];
            [self.event setObject:self.detailsTextView.text forKey:@"details"];
            
            [viewController setEvent:self.event];
        }
    }
}

#ifdef eddie
- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"CreateEventNextSegue"]) {
    }
}
#endif

- (IBAction)cancel:(id)sender; {
    // if the user has begun adding details to an even ask for confirmation before leaving
    if (self.event) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" 
                                                           delegate:self 
                                                  cancelButtonTitle:@"Cancel" 
                                                  destructiveButtonTitle:@"Delete Event" otherButtonTitles:nil];
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    } else {
        // leave
        [self.tabBarController setSelectedViewController:((CircleMainViewController*)self.tabBarController).lastSelectedViewController];
    }
    
    
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
    // do nothing    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete Event"]) {
        // the user has confirmed that it is okay to delete the event
        [self.tabBarController setSelectedViewController:((CircleMainViewController*)self.tabBarController).lastSelectedViewController];
    }
}

@end
