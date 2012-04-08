//
//  CircleChooseEventLocationViewController.h
//  Circle
//
//  Created by Eddie Hillenbrand on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleChooseEventLocationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISearchBar *mapSearchBar;
@property (weak, nonatomic) IBOutlet UIPickerView *savedLocationsPicker;

@end
