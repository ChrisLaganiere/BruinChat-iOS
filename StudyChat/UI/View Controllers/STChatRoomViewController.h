//
//  STChatRoomViewController.h
//  BruinChat
//
//  Created by Christopher Laganiere on 12/19/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STCoreViewController.h"

@interface STChatRoomViewController : STCoreViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic,retain) NSString *chatWithUser;
@property (nonatomic,retain) NSMutableArray *messagesArray;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
- (id) initWithUser:(NSString *) userName;
- (IBAction)sendMessage:(id)sender;


@end
