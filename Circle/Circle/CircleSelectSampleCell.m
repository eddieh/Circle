//
//  CircleSelectSampleCell.m
//  Circle
//
//  Created by Sam Olson on 4/11/12.
//  Copyright (c) 2012 Northern Arizona University. All rights reserved.
//

#import "CircleSelectSampleCell.h"

@implementation CircleSelectSampleCell

@synthesize makeLabel = _makeLabel;
@synthesize modelLabel = _modelLabel;

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

@end
