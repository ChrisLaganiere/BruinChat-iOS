//
//  STAddChats_ClassesViewController.h
//  BruinChat
//
//  Created by Christopher Laganiere on 2/16/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "STCoreViewController.h"

@interface STAddChats_ClassesViewController : STCoreViewController <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *subjectArea;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *checkButton;
@property(nonatomic, strong, readonly) UISearchBar *searchBar;
- (IBAction)back:(id)sender;
- (void)populateClasses:(NSDictionary *)classes;
- (IBAction)check:(id)sender;

@end
