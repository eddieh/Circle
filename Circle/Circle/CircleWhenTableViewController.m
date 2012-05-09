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
@synthesize startCellDetail = _startCellDetail;
@synthesize endCellDetail = _endCellDetail;
@synthesize clearTextButton = _clearTextButton;


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
    self.selectedCell = self.startsCell;
    
    //highlight selected cell
    UIColor *selectedFieldColor = [UIColor colorWithRed: 0.0f green: 0.0f blue: 1.0f alpha: 0.1f];
    self.startsCell.backgroundColor = selectedFieldColor;
    
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
    self.startCellDetail.text = [self.dateFormatter stringFromDate:self.startDate];
    
    // set up the end date
    if (![[NSNull null] isEqual:[self.event objectForKey:@"endDate"]]) {
        self.endDate = [self.event objectForKey:@"endDate"];
    }
    
    if (self.endDate) {
        self.endCellDetail.text = [self.dateFormatter stringFromDate:self.endDate];
        self.clearTextButton.hidden = NO;
    } else {
        self.endsCell.detailTextLabel.text = @"None";
        self.clearTextButton.hidden = YES;
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
    [self setStartCellDetail:nil];
    [self setEndCellDetail:nil];
    [self setClearTextButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)clearDateButtonClicked:(id)sender{
    self.endDate = [[NSDate alloc]init];
    self.endCellDetail.text = @"None";
    self.clearTextButton.hidden = YES;
    self.datePicker.maximumDate = nil;
    self.datePicker.date = self.startDate;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIColor *selectedFieldColor = [UIColor colorWithRed: 0.0f green: 0.0f blue: 1.0f alpha: 0.1f];
    
    if (indexPath.row == 0) {
        NSDate *currentDate = [NSDate date];
        //highlight selected cell
        self.endsCell.backgroundColor = [UIColor whiteColor];
        self.startsCell.backgroundColor = selectedFieldColor;
        self.datePicker.date = self.startDate;
        self.datePicker.minimumDate = currentDate;
        //start date cannot be before end date
        //error avoidance, when end date is not set it gets set as current date
        //can cause all options to be grayed out
        if([self.endDate timeIntervalSinceDate:self.startDate]>60.0f)
        {
            self.datePicker.maximumDate = self.endDate;
            self.datePicker.minimumDate = currentDate;
        }
    }
    else if (indexPath.row == 1)
    {
        //highlight selected cell
        self.startsCell.backgroundColor = [UIColor whiteColor];
        self.endsCell.backgroundColor = selectedFieldColor;
        
        if (self.endDate)
        {
            self.datePicker.date = self.endDate;
        } else {
            self.endDate = [self.startDate dateByAddingTimeInterval:4*60*60];
            self.datePicker.date = self.endDate;
            self.startCellDetail.text = [self.dateFormatter stringFromDate:self.startDate];
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
        self.startCellDetail.text = [self.dateFormatter stringFromDate:self.startDate];
        if ([self.startDate timeIntervalSinceDate:self.endDate] > 0) {
            self.endDate = [self.startDate dateByAddingTimeInterval:4*60*60];
            self.endCellDetail.text = [self.dateFormatter stringFromDate:self.endDate];
        }
    } else {
        
        self.endDate = date;
        self.endCellDetail.text = [self.dateFormatter stringFromDate:self.endDate];
        self.clearTextButton.hidden = NO;
    }
    [self.tableView reloadData];
}

- (IBAction)plusOneDay:(id)sender; {
    [self addTimeToDatePicker:[NSNumber numberWithDouble:ONE_HOUR]];
}

- (IBAction)plusOneWeek:(id)sender; {
    [self addTimeToDatePicker:[NSNumber numberWithDouble:ONE_WEEK]];
}

- (IBAction)plusOneMonth:(id)sender; {
    [self addTimeToDatePicker:[NSNumber numberWithDouble:ONE_MONTH]];
}

-(void)addTimeToDatePicker:(NSNumber*)timeInterval{
    NSDate *date;
    if (self.selectedCell == self.startsCell) {
        date = [self.startDate dateByAddingTimeInterval:[timeInterval doubleValue]];
        self.startDate = date;
        self.startCellDetail.text = [self.dateFormatter stringFromDate:date];
        if ([self.endDate compare:self.startDate] == NSOrderedAscending) {
            self.endDate = self.startDate;
            self.datePicker.maximumDate = nil;
            if (![self.endCellDetail.text isEqualToString:@"None"]) {
                self.endCellDetail.text = [self.dateFormatter stringFromDate:date];
                self.clearTextButton.hidden = NO;
            }
        }
    } else {
        date = [self.endDate dateByAddingTimeInterval:[timeInterval doubleValue]];
        self.endDate = date;
        self.endCellDetail.text = [self.dateFormatter stringFromDate:date];
        self.clearTextButton.hidden = NO;
    }
    self.datePicker.date = date;
    [self.tableView reloadData];
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
