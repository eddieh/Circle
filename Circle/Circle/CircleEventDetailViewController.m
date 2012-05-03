//
//  CircleEventDetailsViewController.m
//  Circle
//
//  Created by Joshua Conner on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleEventDetailViewController.h"
#import "CircleAttendeesViewController.h"
#import "Parse/Parse.h"

@interface CircleEventDetailViewController ()

@end

@implementation CircleEventDetailViewController {
    NSDateFormatter *dateFormatter;
}
@synthesize imageView;
@synthesize titleLabel;
@synthesize descriptionLabel;
@synthesize timeLabel;
@synthesize venueLabel;
@synthesize calendarDayLabel;
@synthesize calendarMonthLabel;
@synthesize calendarWeekdayLabel;
@synthesize scrollView;
@synthesize mapButton;
@synthesize event = _event;
@synthesize image = _image;

@synthesize attendeesButton;
@synthesize attendingCheckboxButton;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    dateFormatter = [[NSDateFormatter alloc] init];

    if (self.event) {
        if (self.image) {
            [self.imageView setImage:self.image];
        }
        self.titleLabel.text = [self.event objectForKey:@"name"];
        self.navigationItem.title = [self.event objectForKey:@"name"];
        
        //size the description UILabel to the size of its text
        NSString *details = (NSString *)[self.event objectForKey:@"details"];
        CGSize boundingSize = CGSizeMake(304.0, CGFLOAT_MAX);
        CGSize size = [details sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0] constrainedToSize:boundingSize lineBreakMode:UILineBreakModeWordWrap];  
        CGPoint origin = self.descriptionLabel.frame.origin;
        self.descriptionLabel.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
        self.descriptionLabel.text = details;
        
        //set attending button images
        UIImage *buttonCheckedBackground = [UIImage imageNamed:@"checkbox-checked.png"];
        [self.attendingCheckboxButton setImage: buttonCheckedBackground forState:UIControlStateSelected];

        //set attending button state
        PFQuery *query = [PFQuery queryWithClassName:@"Rsvp"];
        [query whereKey:@"event" equalTo: self.event];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        if ([query getFirstObject] != NULL)
        {
            [self.attendingCheckboxButton setSelected:YES];
        }
        
        //set up the calendar
        NSDate *date = [self.event objectForKey:@"startDate"];
        //set the time label
        [dateFormatter setDateFormat:@"h:mm a"];
        NSString *timeString = [dateFormatter stringFromDate:date];
        if ([self.event objectForKey:@"endDate"]) {
            NSString *endTimeString = [dateFormatter stringFromDate:[self.event objectForKey:@"endDate"]];
            timeString = [NSString stringWithFormat:@"from %@ to %@", timeString, endTimeString];
        }
        self.timeLabel.text = timeString;
        
        //formatting the dayLabel with "Mon," "Tue," etc.
        [dateFormatter setDateFormat:@"EE"];
        self.calendarWeekdayLabel.text = [dateFormatter stringFromDate:date];
        
        //format the date number
        [dateFormatter setDateFormat:@"d"];
        self.calendarDayLabel.text = [dateFormatter stringFromDate:date];
        
        //format the month
        [dateFormatter setDateFormat:@"MMM"];
        self.calendarMonthLabel.text = [dateFormatter stringFromDate:date];
        
        
        //set the content size so we can scroll our scrollview
        if (self.image) {
            self.scrollView.contentSize = CGSizeMake(320.0, 370.0 + size.height);
        } else {
            self.scrollView.contentSize = CGSizeMake(320.0, 160.0 + size.height);
        }
        
        //disable the map button if there's no address for some reason
        if (![self.event objectForKey:@"address"]) {
            [self.mapButton setHidden:YES];
        }
    }
    
}

- (void)viewDidUnload
{
    dateFormatter = nil;
    [self setImageView:nil];
    [self setTitleLabel:nil];
    [self setDescriptionLabel:nil];
    [self setTimeLabel:nil];
    [self setVenueLabel:nil];
    [self setCalendarDayLabel:nil];
    [self setCalendarMonthLabel:nil];
    [self setCalendarWeekdayLabel:nil];
    [self setScrollView:nil];
    [self setMapButton:nil];
    [self setAttendeesButton:nil];
    [self setAttendingCheckboxButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}



/**
 * Send user to a directions page
 */
- (IBAction)mapButtonPressed:(id)sender {
    if ([self.event objectForKey:@"address"]) {

        NSString *address = [@"http://maps.google.com/maps?saddr=Current Location&daddr=%@" stringByAppendingString:[self.event objectForKey:@"address"]];
        
        NSString *urlString = [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        
    }
}
// send current event to attendees page
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[CircleAttendeesViewController class]]) {
        CircleAttendeesViewController *vc = segue.destinationViewController;
        vc.event = self.event;
    }
}
// Bring user to attendees page
- (IBAction)attendeesButtonPressed:(id)sender{
    
}
// Update attending selection
- (IBAction)attendingCheckboxPressed:(id)sender{
    //if already attending and button is clicked, set selected to false and remove rsvp from parse
    if (self.attendingCheckboxButton.selected){
        [self.attendingCheckboxButton setSelected:NO];
        PFQuery *query = [PFQuery queryWithClassName:@"Rsvp"];
        [query whereKey:@"event" equalTo: self.event];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        PFObject *unrsvp = [query getFirstObject];
        [unrsvp deleteInBackground];
    }
    //if not attending and button is clicked, set selected to true and add rsvp to parse
    else {
        [self.attendingCheckboxButton setSelected:YES];
        PFObject *rsvp = [PFObject objectWithClassName:@"Rsvp"];
        [rsvp setObject:self.event forKey:@"event"];
        [rsvp setObject:[PFUser currentUser] forKey:@"user"];
        [rsvp saveInBackground];
    }
}
@end
