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

@interface STChatRoomViewController ()

@end

@implementation STChatRoomViewController

- (IBAction)backButtonHit:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (id) initWithUser:(NSString *) userName {
    if (self = [super init]) {
        self.chatWithUser = userName;
    }
    return self;
}

- (IBAction)sendMessage:(id)sender {
    NSString *messageStr = self.messageField.text;
    if([messageStr length] > 0) {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:self.chatWithUser];
        [message addChild:body];
        [self.xmppStream sendElement:message];
        self.messageField.text = @"";
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:messageStr forKey:@"msg"];
        [m setObject:@"you" forKey:@"sender"];
        [m setObject:[NSString getCurrentTime] forKey:@"time"];
        //moved to beginning of array because the table view is flipped
        [self.messagesArray insertObject:m atIndex:0]; //addObject:messageContent];
        [self.tableView reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.messagesArray = [NSMutableArray array];
    
    STAppDelegate *del = [self appDelegate];
    del._messageDelegate = self;
    
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
    
    STAppDelegate *del = [self appDelegate];
    del._messageDelegate = nil;
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
    NSDictionary *s = (NSDictionary *) [self.messagesArray objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"Cell";
    STChatBubbleCell *cell = (STChatBubbleCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[STChatBubbleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *sender = [s objectForKey:@"sender"];
    NSString *message = [s objectForKey:@"msg"];
    NSString *time = [s objectForKey:@"time"];
    
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
    if ([sender isEqualToString:@"you"]) {
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
    cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@", time];
    
    //rotate to fit upside down table view!
    cell.transform = CGAffineTransformMakeScale(1, -1);
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = (NSDictionary *)[self.messagesArray objectAtIndex:indexPath.row];
    NSString *msg = [dict objectForKey:@"msg"];
    
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messagesArray count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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

#pragma mark STMessageDelegate
-(void)newMessageReceived:(NSDictionary *)messageContent
{
    [messageContent setValue:[NSString getCurrentTime] forKey:@"time"];
    //moved to beginning of array because the table view is flipped
    [self.messagesArray insertObject:messageContent atIndex:0]; //addObject:messageContent];
    self.chatWithUser = [messageContent valueForKey:@"sender"];
    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}
@end
