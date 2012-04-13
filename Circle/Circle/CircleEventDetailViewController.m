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

@synthesize event = _event;

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
	// Do any additional setup after loading the view.
    
    //UGGGGGGLLLLLLYYYYY
    //
    //but works for now ^H^H^H^H^H^H^H^H doesn't actually work.
    //
    //setting up the view, making a half-hearted, extremely tired attempt at formatting in a "smart"-ish way.
    if (self.event) {
        self.titleLabel.text = [self.event objectForKey:@"name"];
        
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
