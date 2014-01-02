//
//  STChatRoomViewController.m
//  BruinChat
//
//  Created by Christopher Laganiere on 12/19/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STChatRoomViewController.h"
#import "STChatBubbleCell.h"
#import "NSString+Utils.h"
#import "STStyleSheet.h"
#import "DAKeyboardControl.h"
#import "STDModel.h"
#import "XMPPRoomMessageCoreDataStorageObject.h"
#import "XMPPFramework.h"
#import "STAppDelegate.h"

@interface STChatRoomViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) XMPPRoom *xmppRoom;
@end

@implementation STChatRoomViewController
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;

- (IBAction)backButtonHit:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)startChatroom:(NSString *)jid
{
    NSLog(@"ATTEMPTING TO JOIN CHATROOM CALLED %@",jid);
    XMPPRoomCoreDataStorage * _roomMemory = [[XMPPRoomCoreDataStorage alloc]initWithDatabaseFilename:@"14w-chem20a-1.sqlite" storeOptions:nil];
    NSString* roomID = @"14w-chem20a-1@conference.bruinchat.p1.im";
    XMPPJID * roomJID = [XMPPJID jidWithString:roomID];
    XMPPRoom* xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_roomMemory
                                                           jid:roomJID
                                                 dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:self.xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoom joinRoomUsingNickname:@"myNickname"
                            history:nil
                           password:nil];
    self.xmppRoom = xmppRoom;
}

- (IBAction)sendMessage:(id)sender {
    NSString *messageStr = self.messageField.text;
    if([messageStr length] > 0) {
        [self.xmppRoom sendMessageWithBody:messageStr];
        self.messageField.text = @"";
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.chatroomJID) {
        [self startChatroom:self.chatroomJID];
    }
    
    //set up layout
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                           0.0f,
                                                                           self.view.bounds.size.width,
                                                                           self.view.bounds.size.height - 40.0f)];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    
    //flip table view upside down!
    tableView.transform = CGAffineTransformMakeScale(1, -1);
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                                     self.view.bounds.size.height - 40.0f,
                                                                     self.view.bounds.size.width,
                                                                     40.0f)];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:toolBar];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f,
                                                                           6.0f,
                                                                           toolBar.bounds.size.width - 20.0f - 68.0f,
                                                                           30.0f)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textField.delegate = self;
    [toolBar addSubview:textField];
    self.messageField = textField;
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    sendButton.frame = CGRectMake(toolBar.bounds.size.width - 68.0f,
                                  6.0f,
                                  58.0f,
                                  29.0f);
    [sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
    [toolBar addSubview:sendButton];
    self.sendButton = sendButton;
    
    //swipe gesture to dismiss, like Messages app
    
    self.view.keyboardTriggerOffset = toolBar.bounds.size.height;
    
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        /*
         Try not to call "self" inside this block (retain cycle).
         But if you do, make sure to remove DAKeyboardControl
         when you are done with the view controller by calling:
         [self.view removeKeyboardControl];
         */
        CGRect toolBarFrame = toolBar.frame;
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        toolBar.frame = toolBarFrame;
        
        CGRect tableViewFrame = tableView.frame;
        tableViewFrame.size.height = toolBarFrame.origin.y;
        tableView.frame = tableViewFrame;
    }];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view removeKeyboardControl];
    [self.xmppRoom leaveRoom];
    [self.xmppRoom deactivate];
    [self.xmppRoom removeDelegate:self];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XMPPRoomMessageCoreDataStorageObject *messageObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    static NSString *CellIdentifier = @"Cell";
    STChatBubbleCell *cell = (STChatBubbleCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[STChatBubbleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *sender = messageObject.nickname;
    NSString *message = [messageObject.message stringValue];
    NSString *time = [NSDateFormatter localizedStringFromDate:messageObject.localTimestamp dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    
    //find size of message with constrained height
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = [STStyleSheet chatFont];
    gettingSizeLabel.text = message;
    gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    gettingSizeLabel.numberOfLines = 0;
    
    NSInteger padding = 30;
    CGSize textSize = { 260.0, 10000.0 };
    CGSize expectedSize = [gettingSizeLabel sizeThatFits:textSize];
    expectedSize.width += (padding/2);
    cell.messageContentView.text = message;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;
    UIImage *bgImage = nil;
    if (messageObject.fromMe == [NSNumber numberWithInt:1]) {
        //right aligned
        bgImage = [[UIImage imageNamed:@"aqua.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
        [cell.messageContentView setFrame:CGRectMake(320 - expectedSize.width - padding,
                                                     padding*1.2,
                                                     expectedSize.width,
                                                     expectedSize.height)];
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2,
                                              cell.messageContentView.frame.origin.y - padding/2,
                                              expectedSize.width+padding,
                                              expectedSize.height+padding)];
        [cell.messageContentView setTextContainerInset:UIEdgeInsetsZero];
    } else {
        //left aligned
        NSInteger chatBubbleTailWidth = 6;
        bgImage = [[UIImage imageNamed:@"orange.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
        [cell.messageContentView setFrame:CGRectMake(padding + chatBubbleTailWidth, padding*1.2, expectedSize.width, expectedSize.height)];
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2 - chatBubbleTailWidth,
                                              cell.messageContentView.frame.origin.y - padding/2,
                                              expectedSize.width+padding,
                                              expectedSize.height+padding)];
        [cell.messageContentView setTextContainerInset:UIEdgeInsetsZero];
    }
    cell.bgImageView.image = bgImage;
    cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@, %@",sender,time];
    
    //rotate to fit upside down table view!
    cell.transform = CGAffineTransformMakeScale(1, -1);
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPRoomMessageMemoryStorageObject *messageObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *msg = [messageObject.message stringValue];
    
    //find size of message with constrained height
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = [STStyleSheet chatFont];
    gettingSizeLabel.text = msg;
    gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    gettingSizeLabel.numberOfLines = 0;
    
    NSInteger padding = 30;
    CGSize textSize = { 260.0, 10000.0 };
    CGSize expectedSize = [gettingSizeLabel sizeThatFits:textSize];
    expectedSize.height += 1.75*padding;
    CGFloat height = expectedSize.height;// < 65 ? 65 : expectedSize.height;
    return height;
}
#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.messageField resignFirstResponder];
}

#pragma mark UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

#pragma mark Jabber
- (STAppDelegate *)appDelegate {
    return (STAppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}

#pragma mark Fetched Results Controller to keep track of the Core Data Chatroom managed objects

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    XMPPCoreDataStorage *roomStorage = self.xmppRoom.xmppRoomStorage;
    NSManagedObjectContext *context = [roomStorage mainThreadManagedObjectContext];
    _managedObjectContext = context;
    /*
    NSPersistentStoreCoordinator *coordinator = roomStorage.persistentStoreCoordinator;
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
     */
    return _managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController == nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        //access the single managed object context through model singleton
        NSManagedObjectContext *context = self.managedObjectContext;
        
        //fetch request requires an entity description - we're only interested in Chatroom managed objects
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPRoomMessageCoreDataStorageObject" inManagedObjectContext:context];
        fetchRequest.entity = entity;
        
        //we'll order the Chatroom objects in title sort order for now
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"localTimestamp" ascending:NO];
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
@end
