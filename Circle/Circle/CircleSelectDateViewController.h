//  CircleSelectDateViewController.h


#import <UIKit/UIKit.h>
@class PFObject;

//added
@protocol CircleDateDelegate <NSObject>
-(void) userSelectedStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
@end


@interface CircleSelectDateViewController : UITableViewController


@property (weak, nonatomic) IBOutlet UITableViewCell *startsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *endsCell;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *plusOneDayButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *plusOneWeekButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *plusOneMonthButton;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@property (weak, nonatomic) IBOutlet UILabel *startCellDetail;
@property (weak, nonatomic) IBOutlet UILabel *endCellDetail;
@property (weak, nonatomic) IBOutlet UIButton *clearEndDateTextButton;
@property (weak, nonatomic) IBOutlet UIButton *clearStartDateTextButton;


-(IBAction)clearEndDateButtonClicked:(id)sender;
-(IBAction)clearStartDateButtonClicked:(id)sender;

- (IBAction)changeDate:(id)sender;

- (IBAction)plusOneDay:(id)sender;
- (IBAction)plusOneWeek:(id)sender;
- (IBAction)plusOneMonth:(id)sender;

//sends data back to event page
@property (strong, nonatomic) NSDate *selectedStartDate;
@property (strong, nonatomic) NSDate *selectedEndDate;
@property NSObject <CircleDateDelegate> *delegate;



@end

