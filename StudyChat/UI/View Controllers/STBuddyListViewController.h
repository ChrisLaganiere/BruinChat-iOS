//
//  STBuddyListViewController.h
//  BruinChat
//
//  Created by Christopher Laganiere on 12/19/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STCoreViewController.h"
#import "STAppDelegate.h"
@protocol STChatDelegate;

@interface STBuddyListViewController : STCoreViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>{
	NSFetchedResultsController *fetchedResultsController;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *studyGroupButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)done:(id)sender;

@end
