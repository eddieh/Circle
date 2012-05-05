//
//  CircleEventCell.m
//  Circle
//
//  Created by Sam Olson on 5/3/12.
//  Copyright (c) 2012 Northern Arizona University. All rights reserved.
//

#import "CircleEventCell.h"

@implementation CircleEventCell
@synthesize eventLocationLabel = _eventLocationLabel;
@synthesize eventTitleLabel = _eventTitleLabel;
@synthesize monthLabel = _monthLabel;
@synthesize dayLabel = _dayLabel;
@synthesize weekdayLabel = _weekdayLabel;
@synthesize eventImage = _eventImage;

-(void) layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(5,5,66,66);  
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) prepareForReuse{
    [super prepareForReuse];
    self.imageView.image = nil;
}

@end
