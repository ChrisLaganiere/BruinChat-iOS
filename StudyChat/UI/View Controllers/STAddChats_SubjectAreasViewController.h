//
//  STAddChatsViewController.h
//  BruinChat
//
//  Created by Christopher Laganiere on 2/16/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "STCoreViewController.h"

@interface STAddChats_SubjectAreasViewController : STCoreViewController <UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong, readonly) UISearchBar *searchBar;
- (IBAction)doneHit:(id)sender;

@end
