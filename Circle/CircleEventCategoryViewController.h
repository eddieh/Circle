//
//  CircleEventCategoryViewController.h
//  Circle
//
//  Created by Joshua Conner on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Parse/Parse.h>
@protocol CircleEventCategoryChooserDelegate;

@interface CircleEventCategoryViewController : PFQueryTableViewController
@property (nonatomic, strong) PFObject *event;
@property (nonatomic, strong) NSObject<CircleEventCategoryChooserDelegate> *delegate;
@end

@protocol CircleEventCategoryChooserDelegate <NSObject>;
- (void)circleEventCategoryViewController:(CircleEventCategoryViewController *)controller didModifyPFObject:(PFObject *)event;
@end