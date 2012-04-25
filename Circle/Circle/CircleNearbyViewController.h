//
//  CircleHomeViewController.h
//  Circle
//
//  Created by Joshua Conner on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleSignInViewController.h"

@interface CircleNearbyViewController : PFQueryTableViewController <CircleSignInDelegate, PF_MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *logOutSignInButton;
- (IBAction)signInLogOutButtonPressed:(id)sender;
- (IBAction)segmentedButtonChanged:(UISegmentedControl *)sender;
@end
