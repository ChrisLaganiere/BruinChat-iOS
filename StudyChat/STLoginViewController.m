//
//  STViewController.m
//  StudyChat
//
//  Created by Christopher Laganiere on 12/16/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STLoginViewController.h"

@interface STLoginViewController ()

@end

@implementation STLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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
    
    // Replace this with call to stubs
    // We don't want to send passwords in plain text
    // TODO: Calculate MD5 or some other hash
    if (![self.usernameField.text isEqualToString:@""] &&
        ![self.passwordField.text isEqualToString:@""] &&
        YES /*validate with server here*/) {
        isUserValid = YES;
    }
    
    if (isUserValid) {
        [self performSegueWithIdentifier:@"loginSuccess" sender:sender];
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

@end
