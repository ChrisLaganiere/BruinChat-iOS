//
//  STAddChats_ClassesViewController.m
//  BruinChat
//
//  Created by Christopher Laganiere on 2/16/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "STAddChats_ClassesViewController.h"
#import "STAddChats_LecturesViewController.h"

//Custom UI
#import "STClassesMethods.h"
#import "STStyleSheet.h"

@interface STAddChats_ClassesViewController ()

@property (strong, nonatomic) NSArray *classes;
@property (strong, nonatomic) NSArray *filteredClasses;
@property(nonatomic, copy) NSString *currentSearchString;
@property(nonatomic, strong) UISearchDisplayController *strongSearchDisplayController;
@property(nonatomic, strong, readwrite) UISearchBar *searchBar;

@end

@implementation STAddChats_ClassesViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    //set up title
    NSDictionary *subjectAreas = [STClassesMethods currentSubjectAreas];
    NSString *title = subjectAreas[self.subjectArea];
    
    CGRect titleViewFrame = CGRectMake(0.0f,
                                       0.0f,
                                       215.0f,
                                       44.0f);
    
    UIView *titleView = [[UIView alloc] initWithFrame:titleViewFrame];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleViewFrame];
    //could be used to squeeze letters together to fit more
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    [attributedString addAttribute:NSKernAttributeName value:@-2 range:NSMakeRange(0, [title length])];
    [titleLabel setAttributedText:attributedString];
    titleLabel.font = [STStyleSheet titleFont];
    titleLabel.textColor = [STStyleSheet titleColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleView addSubview:titleLabel];
    
    [[self navigationItem] setTitleView:titleView];
    
    /*
     Default behavior:
     The search bar scrolls along with the table view.
     */
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.barTintColor = [STStyleSheet navigationColor];
    self.searchBar.placeholder = @"Search";
    self.searchBar.delegate = self;
    
    [self.searchBar sizeToFit];
    
    self.strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.delegate = self;
    
    
    self.tableView.tableHeaderView = self.searchBar;
    
    // The search bar is hidden when the view becomes visible the first time
    self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.searchBar.bounds));
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //ask STClassesMethods to start looking for classes
    [STClassesMethods populateClassesForSubjectArea:self.subjectArea sender:self];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.searchDisplayController setActive:NO];
    self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.searchBar.bounds));
}

- (IBAction)back:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)check:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (tableView == self.tableView) {
        cell.textLabel.text = [self.classes objectAtIndex:indexPath.row][@"name"];
    } else {
        cell.textLabel.text = [self.filteredClasses objectAtIndex:indexPath.row][@"name"];
    }
    
    return cell;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return (int)[self.classes count];
    } else {
        return (int)[self.filteredClasses count];
    }
}

#pragma mark -
#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Segues

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = segue.identifier;
    
    if ([identifier isEqualToString:@"Lectures"])
    {
        NSDictionary *theClass;
        if (self.filteredClasses) {
            NSIndexPath *selectedIndexPath = self.searchDisplayController.searchResultsTableView.indexPathForSelectedRow;
            theClass = [self.filteredClasses objectAtIndex:selectedIndexPath.row];
        }
        else
        {
            NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
            theClass = [self.classes objectAtIndex:selectedIndexPath.row];
        }
        
        NSString *classTitle = theClass[@"name"];
        NSString *classCode = theClass[@"code"];
        NSString *subjectCode = self.subjectArea;
        NSArray *lectures = theClass[@"lectures"];
        
        STAddChats_LecturesViewController *destination = segue.destinationViewController;
        [destination setClassTitle:classTitle];
        [destination setClassCode:classCode];
        [destination setSubjectCode:subjectCode];
        [destination setLectures:lectures];
        return;
    }
}

#pragma mark -
#pragma mark - Search Bar

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableView scrollRectToVisible:self.searchBar.frame animated:animated];
}

#pragma mark - Search Delegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.filteredClasses = nil;
    self.currentSearchString = @"";
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.filteredClasses = nil;
    self.currentSearchString = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (searchString.length > 0) { // Should always be the case
        NSArray *classesToSearch = self.classes;
        if (self.currentSearchString.length > 0 && [searchString rangeOfString:self.currentSearchString].location == 0) { // If the new search string starts with the last search string, reuse the already filtered array so searching is faster
            classesToSearch= self.filteredClasses;
        }
        
        self.filteredClasses = [classesToSearch filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchString]];
    } else {
        self.filteredClasses = self.classes;
    }
    
    self.currentSearchString = searchString;
    
    return YES;
}

#pragma mark -
#pragma mark - Extras
- (void)populateClasses:(NSArray *)classes
{
    self.classes = classes;
    [self.tableView reloadData];
}


@end
