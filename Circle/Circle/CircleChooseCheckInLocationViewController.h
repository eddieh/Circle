//
//  CircleChooseCheckInLocationViewController.h
//  Circle
//
//  Created by Joshua Conner on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "CircleSignInViewController.h"

@interface CircleChooseCheckInLocationViewController : UITableViewController <CircleSignInDelegate>
@property (strong, nonatomic) NSArray *events;
@end
