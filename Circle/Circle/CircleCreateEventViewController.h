//
//  CircleCreateEventViewController.h
//  Circle
//
//  Created by Joshua Conner on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIPlaceHolderTextView;

@interface CircleCreateEventViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *eventTitleTextField;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *eventDescriptionTextView;

@end
