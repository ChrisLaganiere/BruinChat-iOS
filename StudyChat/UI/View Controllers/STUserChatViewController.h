//
//  STStudyGroupViewController.h
//  BruinChat
//
//  Created by Christopher Laganiere on 12/19/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STCoreViewController.h"
#import "CoreDataTableViewController.h"

@interface STUserChatViewController : CoreDataTableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic,retain) NSString *userJID;
@property (nonatomic,retain) NSString *userNickname;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)sendMessage:(id)sender;
- (IBAction)backButtonHit:(id)sender;

@end
