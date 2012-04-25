//
//  CircleEventDetailsViewController.h
//  Circle
//
//  Created by Joshua Conner on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CircleEventDetailViewController : UIViewController
//UI
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;

@property (weak, nonatomic) IBOutlet UILabel *calendarDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *calendarMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *calendarWeekdayLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;

- (IBAction)mapButtonPressed:(id)sender;


//non-UI
@property (strong, nonatomic) PFObject *event;
@property (strong, nonatomic) UIImage *image;
@end
