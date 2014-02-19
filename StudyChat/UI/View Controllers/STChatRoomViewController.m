//
//  STChatRoomViewController.m
//  BruinChat
//
//  Created by Christopher Laganiere on 12/19/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STChatRoomViewController.h"
#import "STAppDelegate.h"

//Custom UI
#import "STChatBubbleCell.h"
#import "NSString+Utils.h"
#import "STStyleSheet.h"
#import "DAKeyboardControl.h"
#import "UIImage+SolidColor.h"

//XMPP
#import "STDModel.h"
#import "XMPPRoomMessageCoreDataStorageObject.h"
#import "XMPPRoomOccupantCoreDataStorageObject.h"
#import "XMPPFramework.h" //TODO: import specific requisites
#import "XMPPRosterCoreDataStorage.h"

@interface STChatRoomViewController ()
@property (nonatomic, strong) NSFetchedResultsController *chatFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *usersFetchedResultsController;
@property (nonatomic, strong) XMPPRoom *xmppRoom;
@property (nonatomic, weak) UIView *usersView;
@property (nonatomic, strong) NSString *chatroomNickname;
@end

@implementation STChatRoomViewController
@synthesize chatFetchedResultsController = _chatFetchedResultsController;
@synthesize usersFetchedResultsController = _usersFetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view removeKeyboardControl];
    [self.xmppRoom leaveRoom];
    [self.xmppRoom deactivate];
    [self.xmppRoom removeDelegate:self];
    self.xmppRoom = nil;
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.tableView removeFromSuperview];
    [self.toolBar removeFromSuperview];
    [self.messageField removeFromSuperview];
    [self.sendButton removeFromSuperview];
    self.tableView = nil;
    self.toolBar = nil;
    self.messageField = nil;
    self.sendButton = nil;
}
-(void)viewWillAppear:(BOOL)animated
{
    //remove BruinChat logo
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"NavBarEmpty"] colorImageWithColor:[STStyleSheet navigationColor]]
                                                  forBarMetrics:UIBarMetricsDefault];
    
    
    CGRect titleViewFrame = CGRectMake(0.0f,
                                  0.0f,
                                  215.0f,
                                   44.0f);
    CGRect titleFrame = CGRectMake(0.0f,
                                       0.0f,
                                       titleViewFrame.size.width,
                                       28.0f);
    
    
    UIView *titleView = [[UIView alloc] initWithFrame:titleViewFrame];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    //squeeze letters together to fit more
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.className];
    [attributedString addAttribute:NSKernAttributeName value:@-2 range:NSMakeRange(0, [self.className length])];
    [titleLabel setAttributedText:attributedString];
    titleLabel.font = [STStyleSheet titleFont];
    titleLabel.textColor = [STStyleSheet titleColor];
    [titleView addSubview:titleLabel];
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleFrame.size.height, titleViewFrame.size.width, titleViewFrame.size.height-titleFrame.size.height)];
    //squeeze letters together to fit more
    NSMutableAttributedString *subtAttributedString = [[NSMutableAttributedString alloc] initWithString:self.classSubtitle];
    [subtAttributedString addAttribute:NSKernAttributeName value:@-2 range:NSMakeRange(0, [self.classSubtitle length])];
    [subtitleLabel setAttributedText:subtAttributedString];
    subtitleLabel.font = [STStyleSheet subtitleFont];
    subtitleLabel.textColor = [STStyleSheet titleColor];
    [titleView addSubview:subtitleLabel];

    
    [[self navigationItem] setTitleView:titleView];
    
    
    
    
    
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName  : [STStyleSheet titleColor],
                                 NSFontAttributeName : [STStyleSheet titleFont]};
    
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    
    
    
    [super viewWillAppear:animated];
    
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
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    toolBar.barTintColor = [STStyleSheet navigationColor];
    [self.view addSubview:toolBar];
    self.toolBar = toolBar;
    
    HPGrowingTextView *textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10.0f,
                                                                           6.0f,
                                                                           toolBar.bounds.size.width - 20.0f - 35.0f,
                                                                           30.0f)];
    //textView.borderStyle = UITextBorderStyleRoundedRect; //only for textField
    [textView.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [textView.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [textView.layer setBorderWidth: 1.0];
    [textView.layer setCornerRadius:8.0f];
    [textView.layer setMasksToBounds:YES];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView.delegate = self;
    textView.backgroundColor = [STStyleSheet textFieldColor];
    [toolBar addSubview:textView];
    self.messageField = textView;
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [sendButton setImage:[UIImage imageNamed:@"return"] forState:UIControlStateNormal];
    sendButton.frame = CGRectMake(toolBar.bounds.size.width - 35.0f,
                                  (toolBar.bounds.size.height/2) - 12.5f,
                                  25.0f,
                                  25.0f);
    sendButton.tintColor = [STStyleSheet tintColor];
    [sendButton.titleLabel setFont:[STStyleSheet labelFont]];
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
    
    //start chatroom
    if (self.chatroomJid) {
        [self startChatroom:self.chatroomJid];
    } else {
        //error
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonHit:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)startChatroom:(NSString *)chatroomTitle
{
    XMPPRoomCoreDataStorage * _roomMemory = [[XMPPRoomCoreDataStorage alloc]initWithDatabaseFilename:[NSString stringWithFormat:@"%@.sqlite",self.chatroomJid] storeOptions:nil];
    NSString* roomID = [NSString stringWithFormat:@"%@@conference.%@",self.chatroomJid,HostName];
    XMPPJID * roomJID = [XMPPJID jidWithString:roomID];
    XMPPRoom* xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_roomMemory
                                                           jid:roomJID
                                                 dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:self.xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSString *nickname = [[NSUserDefaults standardUserDefaults] valueForKey:@"userNickname"];
    if (nickname.length < 1) {
        nickname = [[NSUserDefaults standardUserDefaults] valueForKey:@"userID"];
    }
    self.chatroomNickname = nickname;
    [xmppRoom joinRoomUsingNickname:nickname
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

- (IBAction)usersButtonHit:(id)sender {
    //create view
    if (!self.usersView) {
        //create
        [self putUpUsersView];
    } else {
        //remove
        [UIView animateWithDuration:0.5 animations:^{
            self.usersView.frame = CGRectMake(220, 64, 200, 0);
        } completion:^(BOOL finished){
            if (finished)
                [self takeDownUsersView];
        }];
    }
}
-(void)putUpUsersView
{
    UIView *usersView = [[UIView alloc] initWithFrame:CGRectMake(220, 64, 100, 0)];
    usersView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:usersView];
    self.usersView = usersView;
    
    UITableView *usersTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, usersView.bounds.size.width, usersView.bounds.size.height)];
    usersTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    usersTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    usersTable.alwaysBounceVertical = NO;
    
    usersTable.dataSource = self;
    usersTable.delegate = self;
    [usersView addSubview:usersTable];
    self.usersTable = usersTable;
    
    //view height <= 250
    double potentialViewHeight = 44.0*[[self.usersFetchedResultsController fetchedObjects] count];
    double realViewHeight = potentialViewHeight < 250 ? potentialViewHeight : 250;
    [UIView animateWithDuration:0.5 animations:^{
        [UIView animateWithDuration:10.0
                         animations:^{
                             usersView.frame = CGRectMake(120, 64, 200, realViewHeight);// its final location
                         }];
    }];
}
-(void)takeDownUsersView
{
    [self.usersTable removeFromSuperview];
    [self.usersView removeFromSuperview];
    self.usersFetchedResultsController = nil;
    self.usersTable = nil;
    self.usersView = nil;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewCell helpers
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPRoomOccupantCoreDataStorageObject *)user
{
    /*
    //must not be self
    if ([user.nickname isEqual:self.chatroomNickname]) {
        return;
    }
     */
    
    
    NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
    STAppDelegate *del = [self appDelegate];
    XMPPUserCoreDataStorageObject *xmppUser = [[XMPPRosterCoreDataStorage sharedInstance] userForJID:user.realJID xmppStream:del.xmppStream managedObjectContext:moc];
    
	// Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
	// We only need to ask the avatar module for a photo, if the roster doesn't have it.
	
	if (xmppUser.photo != nil)
	{
		cell.imageView.image = xmppUser.photo;
	} else {
		NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:user.realJID];
        
		if (photoData != nil)
			cell.imageView.image = [UIImage imageWithData:photoData];
		else {
			cell.imageView.image = [UIImage imageNamed:@"defaultPerson"];
        }
	}
    cell.imageView.backgroundColor=[UIColor clearColor];
    [cell.imageView.layer setCornerRadius:8.0f];
    [cell.imageView.layer setMasksToBounds:YES];
}

#pragma mark UITableViewDataSource
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
            //chat
        XMPPRoomMessageCoreDataStorageObject *messageObject = [self.chatFetchedResultsController objectAtIndexPath:indexPath];
        
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
    } else {
        //users view
        XMPPRoomOccupantCoreDataStorageObject *occupant = [self.usersFetchedResultsController objectAtIndexPath:indexPath];
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [self.usersTable dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = occupant.nickname;
        if (![occupant.affiliation isEqual: @"none"]) {
            cell.detailTextLabel.text = occupant.affiliation;
        }
        UIImage *backgroundImage = [UIImage imageNamed:@"usersBack.png"];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = backgroundImage;
        cell.backgroundView = imageView;
        
        [self configurePhotoForCell:cell user:occupant];
        
        return cell;
        
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView)
    {
        //for chat
        XMPPRoomMessageCoreDataStorageObject *messageObject = [self.chatFetchedResultsController objectAtIndexPath:indexPath];
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
    else {
        //for usersTable
        return [[UIImage imageNamed:@"usersBack.png"] size].height;
    }
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.usersTable) {
        XMPPRoomOccupantCoreDataStorageObject *user = [self.usersFetchedResultsController objectAtIndexPath:indexPath];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:user.nickname
		                                                    message:@"Add as friend"
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Cancel"
		                                          otherButtonTitles:@"Add", nil];
		[alertView show];
    }
}

#pragma mark UITextView Delegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float difference = height - growingTextView.frame.size.height;
    CGRect toolFrame = self.toolBar.frame;
    toolFrame.size.height += difference;
    toolFrame.origin.y -= difference;
    self.toolBar.frame = toolFrame;
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height -= difference;
    self.tableView.frame = tableFrame;
    
    /*
    
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	containerView.frame = r;
     */
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
    return _managedObjectContext;
}

- (NSFetchedResultsController *)chatFetchedResultsController {
    if (_chatFetchedResultsController == nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        //access the single managed object context through model singleton
        NSManagedObjectContext *context = self.managedObjectContext;
        
        //fetch request requires an entity description - we're only interested in Chatroom managed objects
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPRoomMessageCoreDataStorageObject" inManagedObjectContext:context];
        fetchRequest.entity = entity;
        
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"nickname != nil"];
        
        //we'll order the Chatroom objects in title sort order for now
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"localTimestamp" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        fetchRequest.sortDescriptors = sortDescriptors;
        
        self.chatFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        self.chatFetchedResultsController.delegate = self;
        NSError *error = nil;
        if (![self.chatFetchedResultsController performFetch:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
	return _chatFetchedResultsController;
}

- (NSFetchedResultsController *)usersFetchedResultsController {
    if (_usersFetchedResultsController == nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        //access the single managed object context through model singleton
        NSManagedObjectContext *context = self.managedObjectContext;
        
        //fetch request requires an entity description - we're only interested in User managed objects
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPRoomOccupantCoreDataStorageObject" inManagedObjectContext:context];
        fetchRequest.entity = entity;
        
        //we'll order the Users objects in title sort order for now
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"nickname" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        fetchRequest.sortDescriptors = sortDescriptors;
        
        self.usersFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        self.usersFetchedResultsController.delegate = self;
        NSError *error = nil;
        if (![self.usersFetchedResultsController performFetch:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
	return _usersFetchedResultsController;
}

#pragma mark - UITableViewDataSource overriding CoreDataTableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        NSInteger sections = [[self.chatFetchedResultsController sections] count];
        return sections;
    } else {
        //users table
        NSInteger sections = [[self.usersFetchedResultsController sections] count];
        return sections;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (tableView == self.tableView) {
        if ([[self.chatFetchedResultsController sections] count] > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.chatFetchedResultsController sections] objectAtIndex:section];
            rows = [sectionInfo numberOfObjects];
        }
    } else {
        if ([[self.usersFetchedResultsController sections] count] > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.usersFetchedResultsController sections] objectAtIndex:section];
            rows = [sectionInfo numberOfObjects];
        }

    }
    return rows;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return [[[self.chatFetchedResultsController sections] objectAtIndex:section] name];
    } else {
        //users table
        return [[[self.usersFetchedResultsController sections] objectAtIndex:section] name];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.tableView) {
        return [self.chatFetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
    } else {
        return [self.usersFetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return [self.chatFetchedResultsController sectionIndexTitles];
    } else {
        //users view
        return [self.usersFetchedResultsController sectionIndexTitles];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (controller == _chatFetchedResultsController) {
        [self.tableView beginUpdates];
    } else {
        //users view
        [self.usersTable beginUpdates];
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
    if (controller == _chatFetchedResultsController) {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    } else {
        //users table
        switch(type)
        {
        case NSFetchedResultsChangeInsert:
            [self.usersTable insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.usersTable deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }

    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
    
    if (controller == _chatFetchedResultsController) {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeMove:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    } else {
        //users table
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.usersTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.usersTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self.usersTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeMove:
                [self.usersTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.usersTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (controller == _chatFetchedResultsController) {
        [self.tableView endUpdates];
    } else {
        [self.usersTable endUpdates];
    }
}



@end
