//
//  STRegisterViewController.h
//  BruinChat
//
//  Created by Christopher Laganiere on 1/15/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "STCoreViewController.h"

@interface STRegisterViewController : STCoreViewController <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *UCLALogonIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *chatroomNicknameTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *userPhotoImageView;
@property (weak, nonatomic) IBOutlet UIView *userPhotoContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultUserPhotoImageView;
@property CGPoint svos;

- (IBAction)backgroundTouch:(id)sender;
- (IBAction)cancelAndDismiss:(id)sender;
- (IBAction)submit:(id)sender;
- (IBAction)didTapPhoto:(id)sender;
@end
