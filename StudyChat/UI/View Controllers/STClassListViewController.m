//
//  STClassListViewController.m
//  StudyChat
//
//  Created by Christopher Laganiere on 12/16/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STClassListViewController.h"
#import "STStyleSheet.h"
#import "STAddChats_SubjectAreasViewController.h"
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
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.toolbar.barTintColor = [STStyleSheet navigationColor];
    self.toolbar.tintColor = [STStyleSheet tintColor];
    self.toolbar.alpha = 0.9;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar.png"] forBarMetrics:UIBarMetricsDefault];
    
    [self.tableView reloadData];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.fetchedResultsController.fetchedObjects.count == 0)
        [self performSegueWithIdentifier:@"addChats" sender:self];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //fix state if editing
    if (self.tableView.editing) {
        [self.tableView setEditing:NO];
        [self changeAddButtonVisibility:NO];
    }
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
    cell.detailTextLabel.text = chatroom.subtitle;
    return cell;
}

/*
 Delete object from tableview and core data table
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([[self.fetchedResultsController fetchedObjects]count] > 0) {
            
            NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
            //Chatroom *chatroom = [self.fetchedResultsController objectAtIndexPath:indexPath];
            
            [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            /*
             // commented until testing
            if (![[STDModel sharedInstance] cleanUpAfterClassWithJid:chatroom.jid])
                NSLog(@"error");
             */
            
            // Save the context.
            NSError *error = nil;
            if (![context save:&error]) {
                /*
                 Replace this implementation with code to handle the error appropriately.
                 
                 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 */
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }
}
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark Segues

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSString *identifier = segue.identifier;
    
    if ([identifier isEqualToString:@"addChats"])
    {
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
        NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
        Chatroom *chatroom = [[self fetchedResultsController] objectAtIndexPath:selectedIndexPath];
        NSString *chatroomJid = chatroom.jid;
        NSString *className = chatroom.title;
        NSString *classSubtitle = chatroom.subtitle;
        [segue.destinationViewController setChatroomJid:chatroomJid];
        [segue.destinationViewController setClassName:className];
        [segue.destinationViewController setClassSubtitle:classSubtitle];
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

#pragma mark buttons

- (IBAction)logout:(id)sender {
    NSLog(@"DISCONNECT");
    STAppDelegate *del =[self appDelegate];
    [del disconnect];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)edit:(id)sender {
    if (self.tableView.editing) {
        [self.tableView setEditing:NO];
        [self changeAddButtonVisibility:NO];
    }
    else {
        [self.tableView setEditing:YES];
        [self changeAddButtonVisibility:YES];
    }
}
- (IBAction)add:(id)sender {
    [self performSegueWithIdentifier:@"addChats" sender:self];
}
-(void)changeAddButtonVisibility:(BOOL)visible
{
    if (visible) {
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(add:)];
        [anotherButton setImage:[UIImage imageNamed:@"plus"]];
        self.navigationItem.leftBarButtonItem = anotherButton;
    }
    else if (self.navigationItem.rightBarButtonItem) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

#pragma mark Accessors
- (STAppDelegate *)appDelegate {
    return (STAppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
