//
//  CircleSelectCategoryTableViewController.m
//  Circle
//
//  Created by Sam Olson on 4/10/12.
//  Copyright (c) 2012 Northern Arizona University. All rights reserved.
//

#import "CircleSelectCategoryTableViewController.h"

@interface CircleSelectCategoryTableViewController ()
@property (strong, nonatomic) NSArray *selectedCategories;
@end

@implementation CircleSelectCategoryTableViewController
@synthesize delegate = _delegate;
@synthesize selectedCategories = _selectedCategories;


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSMutableArray *selectedCategories = [[NSMutableArray alloc] initWithCapacity:5];
    for (UITableViewCell *Cell in self.tableView.visibleCells)
    {
        if(Cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            [selectedCategories addObject:Cell.textLabel.text];
        }
    }
[self.delegate userSelectedCategories:selectedCategories];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryNone)
    {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    }
}

@end
