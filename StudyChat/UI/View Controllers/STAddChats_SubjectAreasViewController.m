//
//  STAddChatsViewController.m
//  BruinChat
//
//  Created by Christopher Laganiere on 2/16/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "STAddChats_SubjectAreasViewController.h"
#import "STStyleSheet.h"
#import "UIImage+SolidColor.h"
#import "STClassesMethods.h"
#import "STAddChats_ClassesViewController.h"

@interface STAddChats_SubjectAreasViewController ()

@property (strong, nonatomic) NSDictionary *subjectAreas;
@property (strong, nonatomic) NSArray *subjectAreasArray; //array to order results
@property (weak, nonatomic) NSTimer *checkTimer;

@property(nonatomic, copy) NSArray *filteredSubjectAreas;
@property(nonatomic, copy) NSString *currentSearchString;
@property(nonatomic, strong) UISearchDisplayController *strongSearchDisplayController; // UIViewController doesn't retain the search display controller if it's created programmatically: http://openradar.appspot.com/10254897
@property(nonatomic, strong, readwrite) UISearchBar *searchBar;

@end

@implementation STAddChats_SubjectAreasViewController
@synthesize subjectAreas = _subjectAreas;
@synthesize subjectAreasArray = _subjectAreasArray;

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    //set up title
    NSString *title = @"Subject Areas";
    
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

    self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkSubjectAreas) userInfo:nil repeats:YES];
    
    
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
    
    //remove BruinChat logo
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"NavBarEmptyFullAlpha"] colorImageWithColor:[STStyleSheet navigationColor]]
                                                  forBarMetrics:UIBarMetricsDefault];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.searchDisplayController setActive:NO];
    self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.searchBar.bounds));
}

- (IBAction)doneHit:(id)sender {
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
            cell.textLabel.text = [self.subjectAreasArray objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = [self.filteredSubjectAreas objectAtIndex:indexPath.row];
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
        return (int)self.subjectAreasArray.count;
    } else {
        return (int)self.filteredSubjectAreas.count;
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
    
    if ([identifier isEqualToString:@"Classes"])
    {
        NSString *subjectAreaTitle = @"";
        if (self.filteredSubjectAreas) {
            NSIndexPath *selectedIndexPath = self.searchDisplayController.searchResultsTableView.indexPathForSelectedRow;
            subjectAreaTitle = [self.filteredSubjectAreas objectAtIndex:selectedIndexPath.row];
        }
        else
        {
            NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
            subjectAreaTitle = [self.subjectAreasArray objectAtIndex:selectedIndexPath.row];
        }
        
        STAddChats_ClassesViewController *destination = segue.destinationViewController;
        NSString *subjectAreaCode = [[self.subjectAreas allKeysForObject:subjectAreaTitle] firstObject];
        destination.subjectArea = subjectAreaCode;
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
    self.filteredSubjectAreas = nil;
    self.currentSearchString = @"";
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.filteredSubjectAreas = nil;
    self.currentSearchString = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (searchString.length > 0) { // Should always be the case
        NSArray *subjectAreasToSearch = self.subjectAreasArray;
        if (self.currentSearchString.length > 0 && [searchString rangeOfString:self.currentSearchString].location == 0) { // If the new search string starts with the last search string, reuse the already filtered array so searching is faster
            subjectAreasToSearch = self.filteredSubjectAreas;
        }
        
        self.filteredSubjectAreas = [subjectAreasToSearch filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchString]];
    } else {
        self.filteredSubjectAreas = self.subjectAreasArray;
    }
    
    self.currentSearchString = searchString;
    
    return YES;
}

#pragma mark -
#pragma mark - Extras
-(NSDictionary *)subjectAreas
{
    if (_subjectAreas != nil && [_subjectAreas count] > 0) {
        return _subjectAreas;
    }
    
    _subjectAreas = [STClassesMethods currentSubjectAreas];
    _subjectAreasArray = [[_subjectAreas allValues] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return _subjectAreas;
}
-(void)checkSubjectAreas
{
    if ([self.subjectAreas count] > 0) {
        [self.checkTimer invalidate];
        [self.tableView reloadData];
    }
}
@end
