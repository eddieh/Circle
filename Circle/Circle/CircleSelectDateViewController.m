//
//  MSEWhenTableViewController.m
//  MultiStepEditor
//
//  Created by Eddie Hillenbrand on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//off by +7 hours?

#define componentCount 2;
#define column1Component 1;
#define column2Component 2;

#import "CircleSelectDateViewController.h"
#import "CircleConstants.h"
#import "Parse/Parse.h"

@interface CircleSelectDateViewController ()
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UITableViewCell *selectedCell;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@end

@implementation CircleSelectDateViewController
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
//@synthesize event = _event;

//added
@synthesize selectedEndDate = _selectedEndDate;
@synthesize selectedStartDate = _selectedStartDate;
@synthesize delegate = _delegate;
@synthesize startCellDetail = _startCellDetail;
@synthesize endCellDetail = _endCellDetail;
@synthesize clearEndDateTextButton = _clearEndDateTextButton;
@synthesize clearStartDateTextButton = clearStartDateTextButton;


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
    //highlight selected cell
    UIColor *selectedFieldColor = [UIColor colorWithRed: 0.0f green: 0.0f blue: 1.0f alpha: 0.1f];
    
    self.startsCell.backgroundColor = selectedFieldColor;
    self.endsCell.backgroundColor = [UIColor whiteColor];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Set up the date formatter
    self.dateFormatter = [[NSDateFormatter alloc] init];
	[self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [self.dateFormatter setDateFormat:@"EEEE MM/dd"];
    
    // select the starts cell so it is highlighted
    [self.startsCell becomeFirstResponder];
    self.selectedCell = self.startsCell;
    
    // set up the start date
    // uses start date from event search screen
    if (self.selectedStartDate) self.startDate = self.selectedStartDate;
        
    //self.startDate = [self.event objectForKey:@"startDate"];
    if (self.startDate) {
        self.datePicker.date = self.startDate;
    } else {
        self.startDate = self.datePicker.date;
    }
    self.startCellDetail.text = [self.dateFormatter stringFromDate:self.startDate];
    
    // set up the end date
    // uses end date from event search screen
    if (self.selectedEndDate) self.endDate = self.selectedEndDate;
    
    if (self.endDate && ([self.endDate timeIntervalSinceDate:self.startDate]>60.0f)) {
        self.endCellDetail.text = [self.dateFormatter stringFromDate:self.endDate];
    } else {
        self.endCellDetail.text = @"None";
        self.clearEndDateTextButton.hidden = YES;
    }
    
    // sets DatePicker to use 15 min intervals
    self.datePicker.minuteInterval = 30;
    // sets minimum date to the current date
    NSDate *currentDate = [NSDate date];
    self.datePicker.minimumDate = currentDate;
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
    [self setDateFormatter:nil];
    [self setSelectedStartDate:nil];
    [self setSelectedEndDate:nil];
    [self setEndDate:nil];
    [self setStartDate:nil];
    [self setSelectedCell:nil];
    [self setStartCellDetail:nil];
    [self setEndCellDetail:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
//added
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.dateFormatter setDateFormat:@"EEEE MM/dd/yyyy"];
    [self.delegate userSelectedStartDate:[self.dateFormatter dateFromString:[self.dateFormatter stringFromDate:self.startDate]]
                                 endDate:[self.dateFormatter dateFromString:[self.dateFormatter stringFromDate:self.endDate]]];
}
-(void) viewWillAppear:(BOOL)animated{
    NSLog(@"Test %@",self.delegate);
    //add search button
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBarButtonClicked)];
}
                                              
-(void)cancelBarButtonClicked
{
    //resets start date and end date/returns to event screen
    self.startDate = [[NSDate alloc]init];
    self.endDate = [[NSDate alloc]init];
    [self.navigationController popViewControllerAnimated:YES]; 
}
                                    
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)clearEndDateButtonClicked:(id)sender{
    self.endDate = self.startDate;
    self.endCellDetail.text = @"None";
    self.clearEndDateTextButton.hidden = YES;
    self.datePicker.maximumDate = nil;
    if (!(self.startDate == nil))
    {
        self.datePicker.date = self.startDate;
    }
}
-(void)clearStartDateButtonClicked:(id)sender{
    self.startDate = nil;
    self.startCellDetail.text = @"None";
    self.clearStartDateTextButton.hidden = YES;
    self.endDate = self.startDate;
    self.endCellDetail.text = @"None";
    self.clearEndDateTextButton.hidden = YES;
    self.datePicker.maximumDate = nil;
    NSDate *currentDate = [NSDate date];
    self.datePicker.minimumDate = currentDate;
    self.datePicker.date = currentDate;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    UIColor *selectedFieldColor = [UIColor colorWithRed: 0.0f green: 0.0f blue: 1.0f alpha: 0.1f];
    
    if (indexPath.row == 0) {
        NSDate *currentDate = [NSDate date];
        //highlight selected cell
        self.startsCell.backgroundColor = selectedFieldColor;
        self.endsCell.backgroundColor = [UIColor whiteColor];
        
        if(self.startDate != nil){
            self.datePicker.date = self.startDate;
        }
        if(self.endDate != nil){
            self.datePicker.maximumDate = self.endDate;
        }

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
        self.endsCell.backgroundColor = selectedFieldColor;
        self.startsCell.backgroundColor = [UIColor whiteColor];
        
        if (self.endDate)
        {
            self.datePicker.date = self.endDate;
        } else {
            if(self.endDate !=nil){
                self.endDate = [self.startDate dateByAddingTimeInterval:4*60*60];
                self.datePicker.date = self.endDate;
                self.startCellDetail.text = [self.dateFormatter stringFromDate:self.startDate];
                [self.tableView reloadData];
            }
        }
        //end date cannot be before start date
        if (self.startDate != nil)
        {
            self.datePicker.minimumDate = self.startDate;
        }
        self.datePicker.maximumDate = nil;
    }
}

- (IBAction)changeDate:(id)sender; {
    NSDate *date = self.datePicker.date;
    self.clearStartDateTextButton.hidden = NO;
    
    if (self.selectedCell == self.startsCell) {
        self.startDate = date;
        self.startCellDetail.text = [self.dateFormatter stringFromDate:self.startDate];
        if ([self.startDate timeIntervalSinceDate:self.endDate] > 0) {
            self.endDate = [self.startDate dateByAddingTimeInterval:4*60*60];
        }
    } else {
        self.endDate = date;
        self.endCellDetail.text = [self.dateFormatter stringFromDate:self.endDate];
        self.clearEndDateTextButton.hidden = NO;
        if (self.startDate == nil)
        {
            self.startDate = self.endDate;
        }
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
    NSDate *currentDate = [NSDate date];
    if(self.startDate == nil)
    {
        self.startDate = currentDate;
    }
    
    
    self.clearStartDateTextButton.hidden = NO;
    if (self.selectedCell == self.startsCell) {
        date = [self.startDate dateByAddingTimeInterval:[timeInterval doubleValue]];
        self.startDate = date;
        self.startCellDetail.text = [self.dateFormatter stringFromDate:date];
        if ([self.endDate compare:self.startDate] == NSOrderedAscending) {
            self.endDate = self.startDate;
            self.datePicker.maximumDate = nil;
            if (![self.endCellDetail.text isEqualToString:@"None"]) {
                self.endCellDetail.text = [self.dateFormatter stringFromDate:date];
                self.clearEndDateTextButton.hidden = NO;
            }
        }
    } else {
        date = [self.endDate dateByAddingTimeInterval:[timeInterval doubleValue]];
        self.endDate = date;
        self.endCellDetail.text = [self.dateFormatter stringFromDate:date];
        self.clearEndDateTextButton.hidden = NO;
    }
    if (self.startDate == nil){
        
        self.datePicker.date = currentDate;
        self.datePicker.minimumDate = currentDate;
    }
    else if(date!=nil){
        self.datePicker.date = date;
    }
    
    [self.tableView reloadData];
}

@end
