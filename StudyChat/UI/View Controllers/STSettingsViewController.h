//
//  STSettingsViewController.h
//  StudyChat
//
//  Created by Christopher Laganiere on 12/16/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STCoreViewController.h"

@interface STSettingsViewController : STCoreViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *userPassTextField;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
- (IBAction)cancelAndDismiss:(id)sender;
- (IBAction)saveAndDismiss:(id)sender;

@end
