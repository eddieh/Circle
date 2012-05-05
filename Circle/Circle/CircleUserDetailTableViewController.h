//
//  CircleUserDetailTableViewController.h
//  Circle
//
//  Created by Sam Olson on 5/3/12.
//  Copyright (c) 2012 Northern Arizona University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@interface CircleUserDetailTableViewController : PFQueryTableViewController

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userEmail;
@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;

- (IBAction)addFriendButtonClicked:(id)sender;

@property (strong, nonatomic) PFObject *selectedUser;

@end
