//
//  CircleEventCategoryAndPrivacyViewController.h
//  Circle
//
//  Created by Eddie Hillenbrand on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleEventCategoryAndPrivacyViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *privacyPicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;

@end
