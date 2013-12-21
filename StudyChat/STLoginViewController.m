//
//  STViewController.m
//  StudyChat
//
//  Created by Christopher Laganiere on 12/16/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STLoginViewController.h"
#import "SSKeychain.h"

@interface STLoginViewController ()

@end

@implementation STLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Center scroll view (containing log in stuff)
    CGRect bounds = [self.view bounds];
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGPoint scrollCenter = self.scrollView.center;
    self.svos = CGPointMake(scrollCenter.x - centerPoint.x, scrollCenter.y - centerPoint.y);
    [self.scrollView setContentOffset:self.svos animated:NO];
    
    //set now so that after login, navbar image will already be up
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar.png"] forBarMetrics:UIBarMetricsDefault];
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.scrollView setContentOffset:self.svos animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender
{
    BOOL isUserValid = NO;
    
    // Debug
    NSLog(@"Username: %@", self.usernameField.text);
    NSLog(@"Password: %@", self.passwordField.text);
    
    NSString *userID = self.usernameField.text;
    NSString *userPass = self.passwordField.text;
    [SSKeychain setPassword:userPass forService:@"xmpp" account:userID];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autoLoginDisabled"]) {
        [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"userID"];
        [[NSUserDefaults standardUserDefaults] setObject:@"******" forKey:@"userPass"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // Replace this with call to stubs
    // We don't want to send passwords in plain text
    // TODO: Calculate MD5 or some other hash
    if (![self.usernameField.text isEqualToString:@""] &&
        ![self.passwordField.text isEqualToString:@""] &&
        YES /*validate with server here*/) {
        isUserValid = YES;
    }
    
    if (isUserValid) {
        //call to server here
        [self.activityIndicator startAnimating];
        [self performSelector:@selector(doLoginSegue:) withObject:sender afterDelay:1.0];
        //[self performSegueWithIdentifier:@"loginSuccess" sender:sender];
    }
    else {
        // Maybe change the alert title/message depending on the type of failure
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Invalid Username or password"
                                                          message:@"Enter a valid username and password."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}

-(void)doLoginSegue:(id)sender
{
    [self.activityIndicator stopAnimating];
    [self performSegueWithIdentifier:@"loginSuccess" sender:sender];
}

- (IBAction)backgroundTap:(id)sender {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.scrollView setContentOffset:self.svos animated:YES];
}

#pragma mark textField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGPoint pt;
    CGRect rc = [textField bounds];
    rc = [self.usernameField convertRect:rc toView:self.scrollView];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 140;
    [self.scrollView setContentOffset:pt animated:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.scrollView setContentOffset:self.svos animated:YES];
    [textField resignFirstResponder];
    if (textField == self.usernameField) {
        [self.passwordField becomeFirstResponder];
    }
    if (textField == self.passwordField) {
        [self performSelector:@selector(login:) withObject:self.loginButton];
    }
    return YES;
}

@end
