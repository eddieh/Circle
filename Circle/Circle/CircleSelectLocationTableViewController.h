//
//  CircleSelectLocationTableViewController.h
//  Circle
//
//  Created by Sam Olson on 4/10/12.
//  Copyright (c) 2012 Northern Arizona University. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CircleLocationDelegate <NSObject>
@required
-(void)userSelectedLocation:(NSString *)location;
@end

@interface CircleSelectLocationTableViewController : UITableViewController
@property NSObject <CircleLocationDelegate> *delegate;
@end


