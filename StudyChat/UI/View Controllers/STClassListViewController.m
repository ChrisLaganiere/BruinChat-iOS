//
//  STClassListViewController.m
//  StudyChat
//
//  Created by Christopher Laganiere on 12/16/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STClassListViewController.h"
#import "STStyleSheet.h"
#import "STBuddyListViewController.h"
#import "STSettingsViewController.h"
#import "STAppDelegate.h"

@interface STClassListViewController ()

@end

@implementation STClassListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.toolbar.barTintColor = [STStyleSheet navigationColor];
    self.toolbar.tintColor = [STStyleSheet tintColor];
    self.toolbar.alpha = 0.9;
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar.png"] forBarMetrics:UIBarMetricsDefault];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.textLabel.text = @"Class Name";
    cell.detailTextLabel.text = @"Dates & Info";
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Chem 20A - Chemical Structure";
            cell.detailTextLabel.text = @"Lec 1 MWF, Dis 1G R";
            break;
        case 1:
            cell.textLabel.text = @"Math 33B - Differential Equations";
            cell.detailTextLabel.text = @"Lec 2 MWF, Dis 2C T";
            break;
        case 2:
            cell.textLabel.text = @"Com Sci 32 - Intro to Computer Science II";
            cell.detailTextLabel.text = @"Lec 2 MW, Dis 2C R";
            break;
        case 3:
            cell.textLabel.text = @"Phys 1A - Physics for Scientists And Engineers: Mechanics";
            cell.detailTextLabel.text = @"Lec 1 MTWF, Dis 1B W";
            break;
    }
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Segues

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = segue.identifier;
    
    if ([identifier isEqualToString:@"buddyList"])
    {
        STBuddyListViewController *buddyList = segue.destinationViewController;
        [buddyList.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        return;
    }
    else if ([identifier isEqualToString:@"settings"])
    {
        STSettingsViewController *settings = segue.destinationViewController;
        [settings.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        return;
    }
}

- (IBAction)logout:(id)sender {
    NSLog(@"DISCONNECT");
    STAppDelegate *del =[self appDelegate];
    [del disconnect];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Accessors
- (STAppDelegate *)appDelegate {
    return (STAppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
