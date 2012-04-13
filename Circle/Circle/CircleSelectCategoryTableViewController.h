//
//  CircleSelectCategoryTableViewController.h
//  Circle
//
//  Created by Sam Olson on 4/10/12.
//  Copyright (c) 2012 Northern Arizona University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@protocol CircleCategoryDelegate <NSObject>
@required
-(void) userSelectedCategories:(NSArray *)categories;
@end



@interface CircleSelectCategoryTableViewController : PFQueryTableViewController
@property (strong, nonatomic) NSArray *selectedCategories;
@property NSObject<CircleCategoryDelegate> *delegate;
@end
