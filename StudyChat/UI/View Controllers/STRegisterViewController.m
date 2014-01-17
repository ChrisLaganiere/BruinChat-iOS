//
//  STRegisterViewController.m
//  BruinChat
//
//  Created by Christopher Laganiere on 1/15/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "STRegisterViewController.h"
#import "DAKeyboardControl.h"
#import "STStyleSheet.h"

@interface STRegisterViewController ()

@end

@implementation STRegisterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Center scroll view (containing log in stuff)
    self.svos = CGPointMake(0, self.scrollView.contentOffset.y);
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //extra nav bar height screwed up content offset when view is presented modally
    //65 is height of nav bar with BruinChat navbar image
    CGPoint svosMinusNavBarHeight = CGPointMake(self.svos.x, (self.svos.y+65));
    [self.scrollView setContentOffset:svosMinusNavBarHeight animated:NO];
}

- (IBAction)backgroundTouch:(id)sender {
    [self.UCLALogonIDTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.chatroomNicknameTextField resignFirstResponder];
    [self.scrollView setContentOffset:self.svos animated:YES];
}


- (IBAction)cancelAndDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submit:(id)sender {
    [self.activityIndicator startAnimating];
}

#pragma mark textField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGPoint pt;
    CGRect rc = [textField bounds];
    rc = [self.UCLALogonIDTextField convertRect:rc toView:self.scrollView];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 100;
    [self.scrollView setContentOffset:pt animated:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.scrollView setContentOffset:self.svos animated:YES];
    [textField resignFirstResponder];
    if (textField == self.UCLALogonIDTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self.chatroomNicknameTextField becomeFirstResponder];
    }
    return YES;
}
@end
