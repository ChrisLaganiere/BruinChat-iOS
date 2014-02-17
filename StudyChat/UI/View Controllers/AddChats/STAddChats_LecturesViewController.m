//
//  STAddChats_LecturesViewController.m
//  BruinChat
//
//  Created by Christopher Laganiere on 2/17/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "STAddChats_LecturesViewController.h"
#import "STClassesMethods.h"
#import "STStyleSheet.h"
#import "BlockAlertView.h"
#import "STDModel.h"

@interface STAddChats_LecturesViewController ()

@end

@implementation STAddChats_LecturesViewController

-(void)viewDidLoad
{
    //set up title
    NSString *title = self.classTitle;
    
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *lecture = [self.lectures objectAtIndex:indexPath.row];
    NSString *mainText = [NSString stringWithFormat:@"%@: %@",lecture[@"section"],lecture[@"professor"]];
    NSString *detailText = [NSString stringWithFormat:@"%@ %@, %@",lecture[@"days"],lecture[@"time"],lecture[@"location"]];
    cell.textLabel.text = mainText;
    cell.detailTextLabel.text = detailText;
    
    return cell;
}

-(int) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.lectures count];
}

#pragma mark -
#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *lecture = [self.lectures objectAtIndex:indexPath.row];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BlockAlertView *addAlert = [[BlockAlertView alloc] initWithTitle:@"Add Class" message:[NSString stringWithFormat:@"%@: %@ will be added to your class list.",lecture[@"section"],self.classTitle] delegate:Nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    [addAlert setClickedButtonBlock:^(BlockAlertView *alertView, NSInteger buttonIndex) {
        
        //add core data object here
        NSString *subtitle = [NSString stringWithFormat:@"%@ %@, %@",lecture[@"days"],lecture[@"time"],lecture[@"location"]];
        NSString *jid = [NSString stringWithFormat:@"%@_%@",self.classCode,lecture[@"code"]];
        
        if (![[STDModel sharedInstance] addClassToCoreDataWithTitle:self.classTitle Subtitle:subtitle Jid:jid]) {
            BlockAlertView *errorAlert = [[BlockAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@ is already in your class list.",lecture[@"section"]] delegate:Nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];

            [errorAlert show];
        }
    }];
    [addAlert setDelegate:addAlert];
    [addAlert show];
}
@end
