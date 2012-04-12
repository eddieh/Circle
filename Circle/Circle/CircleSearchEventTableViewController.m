//
//  CircleSearchEventTableViewController.m
//  Circle
//
//  Created by Sam Olson on 4/10/12.
//  Copyright (c) 2012 Northern Arizona University. All rights reserved.
//

#import "CircleSearchEventTableViewController.h"

@interface CircleSearchEventTableViewController ()
@property (strong, nonatomic) NSArray *categories;
@end

@implementation CircleSearchEventTableViewController
@synthesize categoryCell = _categoryCell;
@synthesize categories = _categories;

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
}

- (void)viewDidUnload
{
    [self setCategoryCell:nil];
    [super viewDidUnload];
    [self setCategories:nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *categoryString = [[NSString alloc] init];
    
    if (self.categories) {
        for (NSString *category in self.categories) {
            categoryString = [categoryString stringByAppendingFormat:@"%@, ", category];
        }
        categoryString = [categoryString substringToIndex:[categoryString length] - 3];
        self.categoryCell.detailTextLabel.text = categoryString;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[CircleSelectCategoryTableViewController class]]) {
        CircleSelectCategoryTableViewController *vc = (CircleSelectCategoryTableViewController *)segue.destinationViewController;
        vc.delegate = self;
        
        if (self.categories) {
            
        }
    }
}

- (void)userSelectedCategories:(NSArray *)categories {
    self.categories = categories;
}
@end
