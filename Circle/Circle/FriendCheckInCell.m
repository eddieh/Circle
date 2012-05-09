//
//  FriendCheckInCell.m
//  Circle
//
//  Created by Joshua Conner on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendCheckInCell.h"
#import "Parse/Parse.h"
#import "UIImageView+WebCache.h"

@interface FriendCheckInCell() {
    NSDateFormatter *dateFormatter;
}

@end

@implementation FriendCheckInCell
@synthesize imageView;
@synthesize nameLabel;
@synthesize locationLabel;
@synthesize dayLabel;
@synthesize monthLabel;
@synthesize dateLabel;
@synthesize timeLabel;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    dateFormatter = [[NSDateFormatter alloc] init];
    
    return self;
}

- (void)configureWithCheckIn:(PFObject *)checkIn {
    PFObject *friend = [checkIn objectForKey:@"user"];
    PFObject *event = [checkIn objectForKey:@"event"];
    
    //set the title
    self.nameLabel.text = [friend objectForKey:@"name"];
    
    //set the image
    if ([[checkIn objectForKey:@"image"] isKindOfClass:[PFFile class]]) {
        PFFile *image = [checkIn objectForKey:@"image"];
        [self.imageView setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:[UIImage imageNamed:@"profile.png"]
                                success:^(UIImage *image) {}
                                failure:^(NSError *error) {}];

    } else if ([[friend objectForKey:@"image"] isKindOfClass:[PFFile class]]) {
        PFFile *image = [friend objectForKey:@"image"];
        [self.imageView setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:[UIImage imageNamed:@"profile.png"]
                                success:^(UIImage *image) {}
                                failure:^(NSError *error) {}];

    }
    
    //set detaillabel
    NSString *detailText = [event objectForKey:@"name"];
    self.locationLabel.text = [NSString stringWithFormat:@"checked in at %@", detailText];
    
    //set calendar
    [self setupCalendarWithCheckIn:checkIn];
    
}

-(void)setupCalendarWithCheckIn:(PFObject *)checkIn {
    //set up the calendar
    NSDate *date = checkIn.createdAt;
    
    //set the time label
    [dateFormatter setDateFormat:@"h:mm a"];
    NSString *timeString = [dateFormatter stringFromDate:date];
    self.timeLabel.text = timeString;
    
    //formatting the dayLabel with "Mon," "Tue," etc.
    [dateFormatter setDateFormat:@"EE"];
    self.dayLabel.text = [dateFormatter stringFromDate:date];
    
    //format the date number
    [dateFormatter setDateFormat:@"d"];
    self.dateLabel.text = [dateFormatter stringFromDate:date];
    
    //format the month
    [dateFormatter setDateFormat:@"MMM"];
    self.monthLabel.text = [dateFormatter stringFromDate:date];
}

- (void)layoutSubviews {  
    [super layoutSubviews];  
    self.imageView.frame = CGRectMake(5,5,40,32.5);  
    float limgW =  self.imageView.image.size.width;  
    if(limgW > 0) {  
        self.textLabel.frame = CGRectMake(55,self.textLabel.frame.origin.y,self.textLabel.frame.size.width,self.textLabel.frame.size.height);  
        self.detailTextLabel.frame = CGRectMake(55,self.detailTextLabel.frame.origin.y,self.detailTextLabel.frame.size.width,self.detailTextLabel.frame.size.height);  
    }  
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
}

@end
