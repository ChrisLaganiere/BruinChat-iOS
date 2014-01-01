//
//  STClassListViewController.h
//  StudyChat
//
//  Created by Christopher Laganiere on 12/16/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface STClassListViewController : CoreDataTableViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buddyListButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
- (IBAction)logout:(id)sender;

@end
