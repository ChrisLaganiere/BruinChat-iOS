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
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //remove BruinChat logo
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"NavBarEmptyFullAlpha"] colorImageWithColor:[STStyleSheet navigationColor]]
                                                  forBarMetrics:UIBarMetricsDefault];
}


- (IBAction)doneHit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addHit:(id)sender {
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
    
    cell.textLabel.text = [self.subjectAreasArray objectAtIndex:indexPath.row];
    
    return cell;
}

-(int) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.subjectAreas count];
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
        NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
        
        STAddChats_ClassesViewController *destination = segue.destinationViewController;
        NSString *subjectAreaTitle = [self.subjectAreasArray objectAtIndex:selectedIndexPath.row];
        NSString *subjectAreaCode = [[self.subjectAreas allKeysForObject:subjectAreaTitle] firstObject];
        destination.subjectArea = subjectAreaCode;
        return;
    }
}


#pragma mark -
#pragma mark - Extras
-(NSDictionary *)subjectAreas
{
    if (_subjectAreas != nil && [_subjectAreas count] > 0) {
        return _subjectAreas;
    }
    
    _subjectAreas = [STClassesMethods currentSubjectAreas];
    _subjectAreasArray = [_subjectAreas allValues];
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
