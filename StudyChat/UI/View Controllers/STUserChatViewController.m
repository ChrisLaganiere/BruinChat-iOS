//
//  STStudyGroupViewController.m
//  BruinChat
//
//  Created by Christopher Laganiere on 12/19/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STUserChatViewController.h"
#import "STChatBubbleCell.h"
#import "NSString+Utils.h"
#import "STStyleSheet.h"
#import "DAKeyboardControl.h"
#import "STDModel.h"
#import "XMPPMessageArchiving_Message_CoreDataObject.h"
#import "XMPPFramework.h"
#import "STAppDelegate.h"

@interface STUserChatViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation STUserChatViewController
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;

- (IBAction)backButtonHit:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)sendMessage:(id)sender {
    NSString *messageStr = self.messageField.text;
    if([messageStr length] > 0) {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:self.userJID];
        [message addChild:body];
        [self.xmppStream sendElement:message];
        self.messageField.text = @"";
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set name to nickname or display name
    if (self.userNickname.length > 0) {
        //there's a nickname given
        self.title = self.userNickname;
    } else {
        self.title = self.userJID;
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
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XMPPMessageArchiving_Message_CoreDataObject *messageObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    static NSString *CellIdentifier = @"Cell";
    STChatBubbleCell *cell = (STChatBubbleCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[STChatBubbleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //NSString *sender = messageObject.bareJidStr;
    NSString *message = [messageObject.message stringValue];
    NSString *time = [NSDateFormatter localizedStringFromDate:messageObject.timestamp dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    
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
    if (messageObject.isOutgoing) {
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
    cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@",time];
    
    //rotate to fit upside down table view!
    cell.transform = CGAffineTransformMakeScale(1, -1);
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPMessageArchiving_Message_CoreDataObject *messageObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
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

#pragma mark Fetched Results Controller to keep track of the Core Data Chat managed objects

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    XMPPCoreDataStorage *chatStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    NSManagedObjectContext *context = [chatStorage mainThreadManagedObjectContext];
    _managedObjectContext = context;
    return _managedObjectContext;
}
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController == nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        //access the single managed object context through model singleton
        NSManagedObjectContext *context = self.managedObjectContext;
        
        //fetch request requires an entity description - we're only interested in Chat managed objects
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
        fetchRequest.entity = entity;
        
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@",self.userJID];
        
        //we'll order the Chatroom objects in title sort order for now
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
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
