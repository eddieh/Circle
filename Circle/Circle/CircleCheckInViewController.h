//
//  CircleCheckInViewController.h
//  Circle
//
//  Created by Joshua Conner on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DCRoundSwitch;

@interface CircleCheckInViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (strong, nonatomic) NSString *eventTitle;

- (IBAction)checkInButtonPressed;
@end
