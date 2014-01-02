//
//  STClassListViewController.m
//  StudyChat
//
//  Created by Christopher Laganiere on 12/16/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STClassListViewController.h"
#import "STStyleSheet.h"
#import "STBuddyListViewController.h"
#import "STChatRoomViewController.h"
#import "STSettingsViewController.h"
#import "STAppDelegate.h"
#import "STDModel.h"
#import "Chatroom.h"

@interface STClassListViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation STClassListViewController
@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [STStyleSheet navigationColor];
    
    
     //create sample chat room
    Chatroom *testRoom = [NSEntityDescription insertNewObjectForEntityForName:@"Chatroom" inManagedObjectContext:[STDModel sharedInstance].managedObjectContext];
    testRoom.title = @"Chem 20A";
    testRoom.jid = @"testroom";
    testRoom.password = @"testroom";
    [[STDModel sharedInstance] saveChanges];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.toolbar.barTintColor = [STStyleSheet navigationColor];
    self.toolbar.tintColor = [STStyleSheet tintColor];
    self.toolbar.alpha = 0.9;
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar.png"] forBarMetrics:UIBarMetricsDefault];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    Chatroom *chatroom = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = chatroom.title;
    return cell;
}
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark Segues

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = segue.identifier;
    
    if ([identifier isEqualToString:@"buddyList"])
    {
        STBuddyListViewController *buddyList = segue.destinationViewController;
        [buddyList.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        return;
    }
    else if ([identifier isEqualToString:@"settings"])
    {
        STSettingsViewController *settings = segue.destinationViewController;
        [settings.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        return;
    }
    else if ([identifier isEqualToString:@"chatroom"])
    {
        [segue.destinationViewController setChatroomJID:@"14w-chem20a-1@conference.bruinchat.p1.im"];
        return;
    }
}

#pragma mark Fetched Results Controller to keep track of the Core Data Chatroom managed objects

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController == nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        //access the single managed object context through model singleton
        NSManagedObjectContext *context = [STDModel sharedInstance].managedObjectContext;
        
        //fetch request requires an entity description - we're only interested in Chatroom managed objects
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chatroom" inManagedObjectContext:context];
        fetchRequest.entity = entity;
        
        //we'll order the Chatroom objects in title sort order for now
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        fetchRequest.sortDescriptors = sortDescriptors;
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        self.fetchedResultsController.delegate = self;
        NSError *error = nil;
        if (![self.fetchedResultsController performFetch:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
	return _fetchedResultsController;
}

- (IBAction)logout:(id)sender {
    NSLog(@"DISCONNECT");
    STAppDelegate *del =[self appDelegate];
    [del disconnect];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Accessors
- (STAppDelegate *)appDelegate {
    return (STAppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
