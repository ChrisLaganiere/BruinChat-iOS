//
//  STChatRoomViewController.h
//  BruinChat
//
//  Created by Christopher Laganiere on 12/19/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface STChatRoomViewController : CoreDataTableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (nonatomic,retain) NSString *chatroomJid;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)backButtonHit:(id)sender;
- (IBAction)sendMessage:(id)sender;


@end
