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
#import "UIImage+Thumbnail.h"

@interface STRegisterViewController ()

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

@implementation STRegisterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Center scroll view (containing log in stuff)
    self.svos = CGPointMake(0, self.scrollView.contentOffset.y);
    
    [STStyleSheet styleRoundCorneredView:self.userPhotoContainerView];
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


#pragma mark user's photo stuff

- (IBAction)didTapPhoto:(id)sender {
    NSLog(@"Did Tap Photo!");
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"No camera detected!");
        [self pickPhoto];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a Photo",@"Pick from Photo Library", nil];
    [actionSheet showInView:self.view];
}

-(UIImagePickerController *) imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

-(void) takePhoto
{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self.navigationController presentViewController:self.imagePicker animated:YES completion:nil];
}

-(void) pickPhoto
{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (self.imagePicker == nil) {
        NSLog(@"It's nil!");
    }
    else
    {
        NSLog(@"Not nil!");
    }
    
    [self.navigationController presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    CGFloat side = 50.f;
    side *= [[UIScreen mainScreen] scale];
    
    UIImage *thumbnail = [image createThumbnailToFillSize:CGSizeMake(side, side)];
    self.userPhotoImageView.image = thumbnail;
    self.defaultUserPhotoImageView.hidden = true;
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
    
    switch (buttonIndex) {
        case 0:
            [self takePhoto];
            break;
        case 1:
            [self pickPhoto];
            break;
    }
}

@end
