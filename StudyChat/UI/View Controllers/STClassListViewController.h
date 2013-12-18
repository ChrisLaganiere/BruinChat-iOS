//
//  STClassListViewController.h
//  StudyChat
//
//  Created by Christopher Laganiere on 12/16/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STCoreViewController.h"

@interface STClassListViewController : STCoreViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *settingsButton;
@property (weak, nonatomic) IBOutlet UIToolbar *logoutButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
- (IBAction)logout:(id)sender;

@end
