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
    [self registerForKeyboardNotifications];
    
    self.messagesArray = [NSMutableArray array];
    self.scrollView.contentSize = self.view.frame.size;
    [self.scrollView setScrollEnabled:false];
    
    STAppDelegate *del = [self appDelegate];
    del._messageDelegate = self;
    
    //flip table view upside down!
    self.tableView.transform = CGAffineTransformMakeScale(1, -1);
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    //[self.scrollView setContentSize:aRect.size];
    //self.innerView.frame = aRect;
    
    if (!CGRectContainsPoint(aRect, self.messageField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.messageField.frame.origin.y-kbSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
        NSLog(@"scrollPoint: %f",scrollPoint.y);
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self.scrollView setContentOffset:CGPointMake(0, -65) animated:YES];
    //UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    //self.scrollView.contentInset = contentInsets;
    //self.scrollView.scrollIndicatorInsets = contentInsets;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark UITableViewDataSource

/*
 //Updated for bubble messages
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *s = (NSDictionary *) [self.messagesArray objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [s objectForKey:@"msg"];
    cell.detailTextLabel.text = [s objectForKey:@"sender"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;
    return cell;
}
*/
 
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
    if (textField == self.messageField) {
        [self performSelector:@selector(sendMessage:) withObject:self.sendButton];
    }
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
