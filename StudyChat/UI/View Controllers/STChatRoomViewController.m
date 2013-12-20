//
//  STChatRoomViewController.m
//  BruinChat
//
//  Created by Christopher Laganiere on 12/19/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STChatRoomViewController.h"

@interface STChatRoomViewController ()

@end

@implementation STChatRoomViewController

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
    //[self registerForKeyboardNotifications];
    
    self.messagesArray = [NSMutableArray array];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.messageField becomeFirstResponder];
}
/*
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
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
    if (!CGRectContainsPoint(aRect, self.messageField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.messageField.frame.origin.y-kbSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.textLabel.text = @"Class Name";
    cell.detailTextLabel.text = @"Dates & Info";
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Chem 20A - Chemical Structure";
            cell.detailTextLabel.text = @"Lec 1 MWF, Dis 1G R";
            break;
        case 1:
            cell.textLabel.text = @"Math 33B - Differential Equations";
            cell.detailTextLabel.text = @"Lec 2 MWF, Dis 2C T";
            break;
        case 2:
            cell.textLabel.text = @"Com Sci 32 - Intro to Computer Science II";
            cell.detailTextLabel.text = @"Lec 2 MW, Dis 2C R";
            break;
        case 3:
            cell.textLabel.text = @"Phys 1A - Physics for Scientists And Engineers: Mechanics";
            cell.detailTextLabel.text = @"Lec 1 MTWF, Dis 1B W";
            break;
    }
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)sendMessage:(id)sender
{
    NSString *messageStr = self.messageField.text;
    if([messageStr length] > 0) {
        // send message through XMPP
        self.messageField.text = @"";
        //NSString *m = [NSString stringWithFormat:@"%@:%@", messageStr, @"you"];
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:messageStr forKey:@"msg"];
        [m setObject:@"you" forKey:@"sender"];
        [self.messagesArray addObject:m];
        [self.tableView reloadData];
    }
}
@end
