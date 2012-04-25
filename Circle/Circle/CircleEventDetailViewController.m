//
//  CircleEventDetailsViewController.m
//  Circle
//
//  Created by Joshua Conner on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleEventDetailViewController.h"

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
@synthesize event = _event;
@synthesize image = _image;

#pragma mark - View lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        dateFormatter = [[NSDateFormatter alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.event) {
        if (self.image) {
            [self.imageView setImage:self.image];
        }
        self.titleLabel.text = [self.event objectForKey:@"name"];
        
        //size the description UILabel to the size of its text
        NSString *details = (NSString *)[self.event objectForKey:@"details"];
        CGSize size = [details sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0] forWidth:304.0 lineBreakMode:UILineBreakModeWordWrap];
        CGPoint origin = self.descriptionLabel.frame.origin;
        self.descriptionLabel.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
        self.descriptionLabel.text = details;

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
        
        [dateFormatter setDateFormat:@"d"];
        self.calendarDayLabel.text = [dateFormatter stringFromDate:date];
        
        [dateFormatter setDateFormat:@"MMM"];
        self.calendarMonthLabel.text = [dateFormatter stringFromDate:date];
        
        
        
        
        
        
//        NSString *interval = [[NSString alloc] init];
//
//        if ([self.event objectForKey:@"startDate"] && [self.event objectForKey:@"endDate"]) {
//            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//            NSDateComponents *components = [gregorianCalendar components: NSDayCalendarUnit fromDate:[self.event objectForKey:@"startDate"] toDate:[self.event objectForKey:@"endDate"] options:0];
//            
//            if (components > 0) {
//                [dateFormatter setDateFormat:@"EEE, MMMM d 'at' h:mm a"];
//                NSString *startDate = [dateFormatter stringFromDate:[self.event objectForKey:@"startDate"]];
//                
//                [dateFormatter setDateFormat:@"EEE, MMMM d yyyy 'at' h:mm a"];
//                NSString *endDate = [dateFormatter stringFromDate:[self.event objectForKey:@"endDate"]];
//                 
//                interval = [NSString stringWithFormat:@"from %s until %s ",
//                                      startDate,
//                                      endDate];
//                
//            } else {
//                [dateFormatter setDateFormat:@"EEE, MMMM d yyyy 'from' h:mm a"];
//                NSString *startDate = [dateFormatter stringFromDate:[self.event objectForKey:@"startDate"]];
//                
//                [dateFormatter setDateFormat:@"'until' h:mm a"];
//                NSString *endDate = [dateFormatter stringFromDate:[self.event objectForKey:@"endDate"]];
//                
//                interval = [NSString stringWithFormat:@"%s %s ", startDate, endDate];
//                
//            }
//                        
//        } else {
//            [dateFormatter setDateFormat:@"EEE, MMMM d 'at' h:mm a "];
//            if ([self.event objectForKey:@"startDate"])
//                interval = [dateFormatter stringFromDate:[self.event objectForKey:@"startDate"]];
//            else if ([self.event objectForKey:@"endDate"])
//                interval = [dateFormatter stringFromDate:[self.event objectForKey:@"endDate"]];
//        }
//    
//        details = [details stringByAppendingString:interval];
//    
//        if ([self.event objectForKey:@"venueName"]) {
//            details = [details stringByAppendingString:[NSString stringWithFormat:@"at %s ", [self.event objectForKey:@"venueName"]]];
//        }
//        
//        if ([self.event objectForKey:@"address"]) {
//            details = [details stringByAppendingString:[NSString stringWithFormat:@"\n%s", [self.event objectForKey:@"address"]]];
//        }
//    
//    self.descriptionLabel.text = details;
    self.descriptionLabel.text = [self.event
                             objectForKey:@"details"];
    [self.descriptionLabel sizeToFit];
    }
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setTitleLabel:nil];
    [self setDescriptionLabel:nil];
    [self setTimeLabel:nil];
    [self setVenueLabel:nil];
    [self setCalendarDayLabel:nil];
    [self setCalendarMonthLabel:nil];
    [self setCalendarWeekdayLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)mapButtonPressed:(id)sender {
}
@end
