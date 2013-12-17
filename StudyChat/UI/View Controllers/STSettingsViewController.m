//
//  STSettingsViewController.m
//  StudyChat
//
//  Created by Christopher Laganiere on 12/16/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STSettingsViewController.h"

@interface STSettingsViewController ()

@property BOOL notificationsEnabled;

@end

@implementation STSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    
    self.tableView.sectionHeaderHeight = 40;
    self.notificationsEnabled = true;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelAndDismiss:(id)sender
{
    //NSLog(@"Cancel");
    [self dismissViewControllerAnimated:YES completion:^{
        //view controller dismiss animation completed
    }];
}

- (IBAction)saveAndDismiss:(id)sender
{
    //NSLog(@"Save");
    [self dismissViewControllerAnimated:YES completion:^{
        //view controller dismiss animation completed
    }];
}

- (void) loginAutoSwitchChanged:(id)sender {
    UISwitch* switchControl = sender;
    self.notificationsEnabled = switchControl.isOn;
    
    [self.tableView reloadData];
}
-(void)prepareForLoginAutoSwitchChanged:(id)sender {
    //corrects animation of switch, which before was reloaded to it's current state instantly (unpleasantly)
    UISwitch *newSwitch = sender;
    [self performSelector:@selector(loginAutoSwitchChanged:) withObject:newSwitch afterDelay:0.3];
}
- (void) otherSwitchChanged:(id)sender {
    UISwitch* switchControl = sender;
    NSLog( @"The otherSwitchChanged switch is %@", switchControl.on ? @"ON" : @"OFF" );
}

#pragma mark UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *basicCell = [self.tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
    basicCell.textLabel.text = @"unset";
    UITableViewCell *rightDetailCell = [self.tableView dequeueReusableCellWithIdentifier:@"RightDetailCell"];
    rightDetailCell.textLabel.text = @"unset";
    UITableViewCell *notificationCell = [self.tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
    rightDetailCell.textLabel.text = @"unset";
    
    if (indexPath.section == 0) {
        //Profile
        switch (indexPath.row) {
            case 0:
                basicCell.textLabel.text = @"Chris";
                return basicCell;
                break;
        }
    }
    else if (indexPath.section == 1) {
        //UCLA Login
        switch (indexPath.row) {
            case 0: {
                rightDetailCell.textLabel.text = @"Chris";
                rightDetailCell.detailTextLabel.text = @"Username";
                return rightDetailCell;
                break; }
            case 1: {
                rightDetailCell.textLabel.text = @"******";
                rightDetailCell.detailTextLabel.text = @"Password";
                return rightDetailCell;
                break; }
            case 2: {
                basicCell.textLabel.text = @"Log in automatically";
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                basicCell.accessoryView = switchView;
                [switchView setOn:NO animated:NO];
                [switchView addTarget:self action:@selector(otherSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                return basicCell;
                break; }
        }
    }
    else if (indexPath.section == 2) {
        //Notification Settings
        switch (indexPath.row) {
            case 0: {
                basicCell.textLabel.text = @"Push Notifications";
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                basicCell.accessoryView = switchView;
                [switchView setOn:(self.notificationsEnabled) animated:NO];
                [switchView addTarget:self action:@selector(prepareForLoginAutoSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                return basicCell;
                break;
            }
            case 1: {
                notificationCell.textLabel.text = @"Notify on Lecture message";
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                notificationCell.accessoryView = switchView;
                [switchView setOn:NO animated:NO];
                [switchView addTarget:self action:@selector(otherSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                
                //Grey out the text and disable the switch
                if (!self.notificationsEnabled) {
                    notificationCell.userInteractionEnabled = NO;
                    [notificationCell.textLabel setTextColor:[UIColor lightGrayColor]];
                }
                
                return notificationCell;
                break;
            }
            case 2: {
                notificationCell.textLabel.text = @"Notify on Study Group messages";
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                notificationCell.accessoryView = switchView;
                [switchView setOn:NO animated:NO];
                [switchView addTarget:self action:@selector(otherSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                
                //Grey out the text and disable the switch
                if (!self.notificationsEnabled) {
                    notificationCell.userInteractionEnabled = NO;
                    [notificationCell.textLabel setTextColor:[UIColor lightGrayColor]];
                }
                
                return notificationCell;
                break;
            }
            case 3: {
                notificationCell.textLabel.text = @"Notify on Class messages";
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                notificationCell.accessoryView = switchView;
                [switchView setOn:NO animated:NO];
                [switchView addTarget:self action:@selector(otherSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                
                //Grey out the text and disable the switch
                if (!self.notificationsEnabled) {
                    notificationCell.userInteractionEnabled = NO;
                    [notificationCell.textLabel setTextColor:[UIColor lightGrayColor]];
                }
                
                return notificationCell;
                break;
            }
        }
    }
    
    return basicCell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            //Profile
            return 1;
            break;
        case 1:
            //UCLA Login
            return 3;
            break;
        case 2:
            //Notification Settings
            return 4;
            break;
        default:
            break;
    }
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return @"Profile";
            break;
        case 1:
            return @"UCLA Login";
            break;
        case 2:
            return @"Notification Settings";
            break;
        default:
            break;
    }
    return @"Unknown Section";
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
