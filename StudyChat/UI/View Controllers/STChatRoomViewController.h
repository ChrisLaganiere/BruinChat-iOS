//
//  STChatRoomViewController.h
//  BruinChat
//
//  Created by Christopher Laganiere on 12/19/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "CoreDataTableViewController.h"

#import "HPGrowingTextView.h"

@interface STChatRoomViewController : CoreDataTableViewController <HPGrowingTextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet HPGrowingTextView *messageField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *usersButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITableView *usersTable;
@property (nonatomic,retain) NSString *chatroomJid;
@property (nonatomic,retain) NSString *className;
@property (nonatomic,retain) NSString *classSubtitle;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)backButtonHit:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (IBAction)usersButtonHit:(id)sender;


@end
