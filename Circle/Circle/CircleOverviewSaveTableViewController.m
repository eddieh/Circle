//
//  CircleOverviewSaveTableViewController.m
//  Circle
//
//  Created by Eddie Hillenbrand on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleOverviewSaveTableViewController.h"
#import "Parse/Parse.h"
#import "LocationSingleton.h"

@interface CircleOverviewSaveTableViewController () {
    PF_MBProgressHUD *HUD;
}
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation CircleOverviewSaveTableViewController
@synthesize dateFormatter = _dateFormatter;
@synthesize nameCell = _nameCell;
@synthesize detailsCell = _detailsCell;
@synthesize whereCell = _whereCell;
@synthesize startsCell = _startsCell;
@synthesize endsCell = _endsCells;
@synthesize categoryCell = _categoryCell;
@synthesize photoCell = _photoCell;
@synthesize saveButton = _saveButton;
@synthesize event = _event;

bool userCanContinue = YES;


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"%@", self.event);
    
    
    
    if (self.event) {
        self.nameCell.detailTextLabel.text = [self.event objectForKey:@"name"];
        self.detailsCell.detailTextLabel.text = [self.event objectForKey:@"details"];
    }
    
    NSDate *endDate = nil;
    if (![[NSNull null] isEqual:[self.event objectForKey:@"endDate"]]) {
        endDate = [self.event objectForKey:@"endDate"];
    }
  
    if (endDate) {
        self.endsCell.detailTextLabel.text = [self.dateFormatter stringFromDate:endDate];
    } else {
        self.endsCell.detailTextLabel.text = @"None";
    }
}
-(void) viewWillAppear:(BOOL)animated
{
    
    // user can coninue if all the following fields are filled out
    userCanContinue = YES;
    
    // incomplete field color
    UIColor *incompleteFieldColor = [UIColor colorWithRed: 1.0f green: 0.0f blue: 0.0f alpha: 0.1f];
    UIColor *incompleteLabelColor = [UIColor colorWithRed: 1.0f green: 0.0f blue: 0.0f alpha: 0.00f];
    
    // event name cell
    if ([self.nameCell.detailTextLabel.text isEqualToString: @""]){
        self.nameCell.backgroundColor = incompleteFieldColor;
        self.nameCell.textLabel.backgroundColor = incompleteLabelColor;
        userCanContinue = NO; 
    }
    else {
        self.nameCell.backgroundColor = [UIColor whiteColor];
    }
    
    // event detail cell
    if ([self.detailsCell.detailTextLabel.text isEqualToString: @""]){
        self.detailsCell.backgroundColor = incompleteFieldColor;
        self.detailsCell.textLabel.backgroundColor = incompleteLabelColor;
        userCanContinue = NO; 
    }
    else {
        self.detailsCell.backgroundColor = [UIColor whiteColor];
    }
    
    // event category cell
    if ([self.categoryCell.detailTextLabel.text isEqualToString: @""]){
        self.categoryCell.backgroundColor = incompleteFieldColor;
        self.categoryCell.textLabel.backgroundColor = incompleteLabelColor;
        userCanContinue = NO; 
    }
    else {
        self.categoryCell.backgroundColor = [UIColor whiteColor];
    }
    
    // event start date cell, not needed, but just in case?
    if ([self.startsCell.detailTextLabel.text isEqualToString: @""]){
        self.startsCell.backgroundColor = incompleteFieldColor;
        self.startsCell.textLabel.backgroundColor = incompleteLabelColor;
        userCanContinue = NO; 
    }
    else {
        self.startsCell.backgroundColor = [UIColor whiteColor];
    }
    
    NSLog(@"USER CAN START: %s", userCanContinue ? "true" : "false");
    
    
    // Set up the date formatter
    self.dateFormatter = [[NSDateFormatter alloc] init];
	[self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [self.dateFormatter setDateFormat:@"MM/dd h:mm a"];
    
    NSDate *startDate = [self.event objectForKey:@"startDate"];
    if (startDate) {
        self.startsCell.detailTextLabel.text = [self.dateFormatter stringFromDate:startDate];
    }
    else {
        userCanContinue = NO;
    }
    [super viewWillAppear:animated];
}
- (void)viewDidUnload
{
    [self setNameCell:nil];
    [self setDetailsCell:nil];
    [self setWhereCell:nil];
    [self setStartsCell:nil];
    [self setEndsCell:nil];
    [self setCategoryCell:nil];
    [self setPhotoCell:nil];
    [self setSaveButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    id viewController = [segue destinationViewController];
    if ([viewController respondsToSelector:@selector(setEvent:)]) {
        
//            [self.event setObject:self.nameTextField.text forKey:@"name"];
//            [self.event setObject:self.detailsTextField.text forKey:@"details"];
        
        [viewController setEvent:self.event];
    }
    
    if ([viewController isKindOfClass:[CircleEventCategoryViewController class]]) {
        CircleEventCategoryViewController *vc = viewController;
        vc.delegate = self;
    }
}

#pragma mark - Table View delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int count = [self.navigationController.viewControllers count];
    
    switch (indexPath.section) {
        case 0:
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:(count - 4)] animated:YES];
            break;
        case 2:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 3:
            break;
        default:
            break;
    }
}

#pragma mark - CircleEventCategoryChooser delegate method
- (void)circleEventCategoryViewController:(CircleEventCategoryViewController *)controller didModifyPFObject:(PFObject *)event; {
    NSLog(@"Modified: %@", event);
    self.event = event;
    self.categoryCell.detailTextLabel.text = [[event objectForKey:@"category"] objectForKey:@"name"];
}

//pop up a spinner, save, then pop to rootviewcontroller
- (IBAction)saveButtonPressed:(id)sender {
    if(userCanContinue){
        HUD = [self configureHUD];
        HUD.labelText = @"Saving...";
        [HUD show:YES];
        
        [self.event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self setHUDCustomViewWithImageNamed:@"37x-Checkmark.png" labelText:@"Success!" detailsLabelText:@"Event created." hideDelay:1.5];
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            /**
             * HACK: (the hackiest!)
             * We get a reference back to the "Nearby view" in probably the worst way possible,
             * tell it to reload, and then pop back to it.
             *
             * Also, we set our own's rootviewcontroller's event property to nil so the user can create
             * another event if they want.
             */
            
            //tell nearby view to reload
            UINavigationController *nearbyNC = [self.tabBarController.viewControllers objectAtIndex:2];
            [[nearbyNC.viewControllers objectAtIndex:0] loadObjects];
            
            //go to it
            [self.tabBarController setSelectedIndex:2];
            
            //reset "new event" flow's state
            UINavigationController *thisNC = [self.tabBarController.viewControllers objectAtIndex:1];
            [thisNC popToRootViewControllerAnimated:NO];
            if ([[thisNC.viewControllers objectAtIndex:0] respondsToSelector:@selector(setEvent:)]) {
                [[thisNC.viewControllers objectAtIndex:0] setEvent:nil];
            }
        });
    }
    else{
        HUD = [self configureHUD];
        [HUD show:YES];
        [self setHUDCustomViewWithImageNamed: @"problem.png" labelText:@"Error" detailsLabelText:@"Complete the required fields" hideDelay:3.0];
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

#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(PF_MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidden
	[HUD removeFromSuperview];
	HUD = nil;
}

@end
