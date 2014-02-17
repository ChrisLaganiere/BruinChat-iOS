//
//  STAddChats_ClassesViewController.m
//  BruinChat
//
//  Created by Christopher Laganiere on 2/16/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "STAddChats_ClassesViewController.h"
#import "STClassesMethods.h"
#import "STStyleSheet.h"

@interface STAddChats_ClassesViewController ()

@property (strong, nonatomic) NSArray *classes;
@property (weak, nonatomic) NSTimer *checkTimer;

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
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //ask STClassesMethods to start looking for classes
    [STClassesMethods populateClassesForSubjectArea:self.subjectArea sender:self];
}

- (IBAction)back:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
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
    
    cell.textLabel.text = [self.classes objectAtIndex:indexPath.row][@"name"];
    
    return cell;
}

-(int) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.classes count];
}

#pragma mark -
#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark - Extras
- (void)populateClasses:(NSArray *)classes
{
    self.classes = classes;
    [self.tableView reloadData];
}

@end
