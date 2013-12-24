//
//  STViewController.h
//  StudyChat
//
//  Created by Christopher Laganiere on 12/16/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STCoreViewController.h"

@interface STLoginViewController : STCoreViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property CGPoint svos;
- (IBAction)login:(id)sender;
- (IBAction)backgroundTap:(id)sender;
-(void)loginSucceeded;
-(void)loginFailed;
-(void)removeViewControllersAndReset;

@end
