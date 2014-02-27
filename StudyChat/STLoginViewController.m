//
//  STViewController.m
//  StudyChat
//
//  Created by Christopher Laganiere on 12/16/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STLoginViewController.h"
#import "STClassListViewController.h"
#import "SSKeychain.h"
#import "STAppDelegate.h"
#import "STStyleSheet.h"

@interface STLoginViewController ()

@end

@implementation STLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //allow app to reset if autologin is disabled
    [[self appDelegate] setFirstViewController:self];
    
    //Center scroll view (containing log in stuff)
    CGRect bounds = [self.view bounds];
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGPoint scrollCenter = self.scrollView.center;
    self.svos = CGPointMake(scrollCenter.x - centerPoint.x, scrollCenter.y - centerPoint.y);
    [self.scrollView setContentOffset:self.svos animated:NO];
    
    //set now so that after login, navbar image will already be up
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar.png"] forBarMetrics:UIBarMetricsDefault];
    
    self.activityIndicator.color = [STStyleSheet tintColor];
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"userID"];
    BOOL userIDIsValid = (userID && userID.length >= 1);
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autoLoginDisabled"] && userIDIsValid) {
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
        self.usernameField.text = userID;
        self.passwordField.text = [SSKeychain passwordForService:@"xmpp" account:userID];
        [self  performSelector:@selector(login:) withObject:self.loginButton];
    }
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
    
    //lower textfields
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.scrollView setContentOffset:self.svos animated:YES];
    
    // Debug
    NSLog(@"Username: %@", self.usernameField.text);
    NSLog(@"Password: %@", self.passwordField.text);
    
    NSString *userID = self.usernameField.text;
    NSString *userPass = self.passwordField.text;
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autoLoginDisabled"]) {
        [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"userID"];
        [[NSUserDefaults standardUserDefaults] setObject:@"******" forKey:@"userPass"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [SSKeychain setPassword:userPass forService:@"xmpp" account:userID];
    }
    
    if (![self.usernameField.text isEqualToString:@""] &&
        ![self.passwordField.text isEqualToString:@""] &&
        YES /*validate with server here*/) {
        isUserValid = YES;
    }
    
    if (isUserValid) {
        //call to server here
        
        // Replace this with call to stubs
        // We don't want to send passwords in plain text
        // TODO: Calculate MD5 or some other hash
        
        STAppDelegate *del = [self appDelegate];
        del._loginDelegate = self;
        
        if ([[self appDelegate] connect:userID withPass:userPass]) {
            [self.activityIndicator startAnimating];
        }
        //wait for result in loginResult
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

#pragma mark loginDelegate
-(void)loginSucceeded
{
    [self.activityIndicator stopAnimating];
    [self performSegueWithIdentifier:@"loginSuccess" sender:self.loginButton];
}
-(void)loginFailed
{
    NSLog(@"loginFailed");
    [self.activityIndicator stopAnimating];
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Connection Timed Out"
                                                      message:@"Check network settings and try again."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

-(void)removeViewControllersAndReset
{
    NSLog(@"removeViewControllersAndReset");
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)registerTap:(id)sender {
    [[self appDelegate] disconnect];
    [self appDelegate]._loginDelegate = nil;
    [self.activityIndicator stopAnimating];
}


- (IBAction)backgroundTap:(id)sender {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.scrollView setContentOffset:self.svos animated:YES];
}

#pragma mark xmpp

- (STAppDelegate *)appDelegate {
    return (STAppDelegate *)[[UIApplication sharedApplication] delegate];
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
