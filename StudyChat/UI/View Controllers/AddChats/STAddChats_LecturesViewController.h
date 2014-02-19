//
//  STAddChats_LecturesViewController.h
//  BruinChat
//
//  Created by Christopher Laganiere on 2/17/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "STCoreViewController.h"

@interface STAddChats_LecturesViewController : STCoreViewController <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) NSString *classTitle;
@property (strong, nonatomic) NSString *classCode;
@property (strong, nonatomic) NSString *subjectCode;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *checkButton;
@property (strong, nonatomic) NSArray *lectures;
- (IBAction)back:(id)sender;
- (IBAction)check:(id)sender;

@end
