//
//  MSEWhenTableViewController.m
//  MultiStepEditor
//
//  Created by Eddie Hillenbrand on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleWhenTableViewController.h"
#import "CircleConstants.h"
#import "Parse/Parse.h"

@interface CircleWhenTableViewController ()
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UITableViewCell *selectedCell;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@end

@implementation CircleWhenTableViewController
@synthesize dateFormatter = _dateFormatter;
@synthesize selectedCell = _selectedCell;
@synthesize startDate = _startDate;
@synthesize endDate = _endDate;
@synthesize startsCell = _startsCell;
@synthesize endsCell = _endsCell;
@synthesize plusOneDayButton = _plusOneDayButton;
@synthesize plusOneWeekButton = _plusOneWeekButton;
@synthesize plusOneMonthButton = _plusOneMonthButton;
@synthesize datePicker = _datePicker;
@synthesize nextButton = _nextButton;
@synthesize event = _event;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSLog(@"%@", self.event);

    // Set up the date formatter
    self.dateFormatter = [[NSDateFormatter alloc] init];
	[self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [self.dateFormatter setDateFormat:@"MM/dd h:mm a"];

    // select the starts cell so it is highlighted
    [self.startsCell becomeFirstResponder];
    [self.startsCell setAccessoryType:UITableViewCellAccessoryCheckmark];
    self.selectedCell = self.startsCell;
    
    
    // sets DatePicker to use 30 min intervals
    self.datePicker.minuteInterval = 30;
    // sets minimum date to the current date
    NSDate *currentDate = [NSDate date];
    self.datePicker.minimumDate = currentDate;
    
    // set up the start date
    self.startDate = [self.event objectForKey:@"startDate"];
    if (self.startDate) {
        self.datePicker.date = self.startDate;
    } else {
        self.startDate = self.datePicker.date;
    }
    self.startsCell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.startDate];
    
    // set up the end date
    if (![[NSNull null] isEqual:[self.event objectForKey:@"endDate"]]) {
        self.endDate = [self.event objectForKey:@"endDate"];
    }
    
    if (self.endDate) {
        self.endsCell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.endDate];
    } else {
        self.endsCell.detailTextLabel.text = @"None";
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"EndDate2 %@", [self.dateFormatter stringFromDate:self.endDate]);
}
-(void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewDidUnload
{
    [self setStartsCell:nil];
    [self setEndsCell:nil];
    [self setPlusOneDayButton:nil];
    [self setPlusOneWeekButton:nil];
    [self setPlusOneMonthButton:nil];
    [self setDatePicker:nil];
    [self setNextButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 0) {
        [self.startsCell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self.endsCell setAccessoryType:UITableViewCellAccessoryNone];
        self.datePicker.date = self.startDate;
        //start date cannot be before end date
        //error avoidance, when end date is not set it gets set as current date
        //can cause all options to be grayed out
        if([self.endDate timeIntervalSinceDate:self.startDate]>60.0f)
        {
            self.datePicker.maximumDate = self.endDate;
            NSDate *currentDate = [NSDate date];
            self.datePicker.minimumDate = currentDate;
        }
    }
    else if (indexPath.row == 1)
    {
        [self.endsCell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self.startsCell setAccessoryType:UITableViewCellAccessoryNone];
        
        if (self.endDate)
        {
            self.datePicker.date = self.endDate;
        } else {
            self.endDate = [self.startDate dateByAddingTimeInterval:4*60*60];
            self.datePicker.date = self.endDate;
            self.selectedCell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.endDate];
            [self.tableView reloadData];
        }
        //end date cannot be before start date
        self.datePicker.minimumDate = self.startDate;
        self.datePicker.maximumDate = nil;
        
    }
}

- (IBAction)changeDate:(id)sender; {
    NSDate *date = self.datePicker.date;
    
    if (self.selectedCell == self.startsCell) {
        self.startDate = date;
        if ([self.startDate timeIntervalSinceDate:self.endDate] > 0) {
            self.endDate = [self.startDate dateByAddingTimeInterval:4*60*60];
            self.endsCell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.endDate];
        }
    } else {
        self.endDate = date;
    }
    
    self.selectedCell.detailTextLabel.text = [self.dateFormatter stringFromDate:date];
    [self.tableView reloadData];
}

- (IBAction)plusOneDay:(id)sender; {
    NSDate *date; 
    if (self.selectedCell == self.startsCell) {
        date = [self.startDate dateByAddingTimeInterval:ONE_HOUR];
        self.startDate = date;
    } else {
        date = [self.endDate dateByAddingTimeInterval:ONE_HOUR];
        self.endDate = date;
    }
    
    self.datePicker.date = date;
    self.selectedCell.detailTextLabel.text = [self.dateFormatter stringFromDate:date];
}

- (IBAction)plusOneWeek:(id)sender; {
    NSDate *date; 
    if (self.selectedCell == self.startsCell) {
        date = [self.startDate dateByAddingTimeInterval:ONE_WEEK];
        self.startDate = date;
    } else {
        date = [self.endDate dateByAddingTimeInterval:ONE_WEEK];
        self.endDate = date;
    }
    
    self.datePicker.date = date;
    self.selectedCell.detailTextLabel.text = [self.dateFormatter stringFromDate:date];
}

- (IBAction)plusOneMonth:(id)sender; {
    NSDate *date; 
    if (self.selectedCell == self.startsCell) {
        date = [self.startDate dateByAddingTimeInterval:ONE_MONTH];
        self.startDate = date;
    } else {
        date = [self.endDate dateByAddingTimeInterval:ONE_MONTH];
        self.endDate = date;
    }
    
    self.datePicker.date = date;
    self.selectedCell.detailTextLabel.text = [self.dateFormatter stringFromDate:date];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"CreateEventNextSegue"]) {
        id viewController = [segue destinationViewController];
        if ([viewController respondsToSelector:@selector(setEvent:)]) {

            [self.event setObject:self.startDate forKey:@"startDate"];
            if (self.endDate) {
                [self.event setObject:self.endDate forKey:@"endDate"];
            } else {
                [self.event setObject:[NSNull null] forKey:@"endDate"];
            }
            
            
            [viewController setEvent:self.event];
        }
    }
}

@end
