//
//  STSettingsViewController.m
//  StudyChat
//
//  Created by Christopher Laganiere on 12/16/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STSettingsViewController.h"
#import "SSKeychain.h"
#import "STAppDelegate.h"
#import "XMPPvCardTemp.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPJID.h"
#import "UIImage+Thumbnail.h"

@interface STSettingsViewController ()

@property BOOL notificationsEnabled;
@property BOOL autoLoginDisabled;
@property BOOL notifyOnLecture;
@property BOOL notifyOnStudy;
@property BOOL notifyOnElse;
@property NSString *userID;
@property NSString *userPass;
@property NSString *realUserPass;
@property NSString *userNickname;
@property (strong, nonatomic) UIImage *avatarImage;
@property BOOL imageUpdated;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

#define TEXT_CELL_TAG_FOR_REMOVAL 2;

@implementation STSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    
    self.tableView.sectionHeaderHeight = 40;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadSettings];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //shouldn't be needed
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar.png"] forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadSettings
{
    self.userNickname = [[NSUserDefaults standardUserDefaults] valueForKey:@"userNickname"];
    self.autoLoginDisabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"autoLoginDisabled"];
    self.userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    self.userPass = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPass"];
    
    self.notificationsEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"notificationsEnabled"];
    self.notifyOnLecture = [[NSUserDefaults standardUserDefaults] boolForKey:@"notifyOnLecture"];
    self.notifyOnStudy = [[NSUserDefaults standardUserDefaults] boolForKey:@"notifyOnLecture"];
    self.notifyOnElse = [[NSUserDefaults standardUserDefaults] boolForKey:@"notifyOnElse"];
    
    self.imageUpdated = false;
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(IBAction)cancelAndDismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveAndDismiss:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:self.userNickname forKey:@"userNickname"];
    [[NSUserDefaults standardUserDefaults] setBool:self.autoLoginDisabled forKey:@"autoLoginDisabled"];
    [[NSUserDefaults standardUserDefaults] setObject:self.userID forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] setValue:self.userPass forKey:@"userPass"];
    if (self.realUserPass) {
        [SSKeychain setPassword:self.realUserPass forService:@"xmpp" account:self.userID];
        [[NSUserDefaults standardUserDefaults] setValue:@"******" forKey:@"userPass"];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:self.notificationsEnabled forKey:@"notificationsEnabled"];
    [[NSUserDefaults standardUserDefaults] setBool:self.notifyOnLecture forKey:@"notifyOnLecture"];
    [[NSUserDefaults standardUserDefaults] setBool:self.notifyOnStudy forKey:@"notifyOnStudy"];
    [[NSUserDefaults standardUserDefaults] setBool:self.notifyOnElse forKey:@"notifyOnElse"];
    
    if (self.imageUpdated) {
        [[self appDelegate] updateAvatar:self.avatarImage];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForAutoLoginSwitchChanged:(id)sender {
    //delay corrects animation of switch, which before was reloaded to its current state instantly (unpleasantly)
    UISwitch *newSwitch = sender;
    [self performSelector:@selector(autoLoginSwitchChanged:) withObject:newSwitch afterDelay:0.3];
}
- (void) autoLoginSwitchChanged:(id)sender {
    UISwitch *switchControl = sender;
    self.autoLoginDisabled = !switchControl.isOn;
    if (self.autoLoginDisabled) {
        self.userID = @"";
        self.userPass = @"";
        if (self.realUserPass) {
            self.realUserPass = nil;
        }
    }
    
    [self.tableView reloadData];
}

-(void)prepareForNotificationsOnSwitchChanged:(id)sender {
    //corrects animation of switch, which before was reloaded to its current state instantly (unpleasantly)
    UISwitch *newSwitch = sender;
    [self performSelector:@selector(notificationsOnSwitchChanged:) withObject:newSwitch afterDelay:0.3];
}
- (void) notificationsOnSwitchChanged:(id)sender {
    UISwitch* switchControl = sender;
    self.notificationsEnabled = switchControl.isOn;
    
    [self.tableView reloadData];
}
- (void) notifyOnLectureSwitchChanged:(id)sender {
    UISwitch* switchControl = sender;
    self.notifyOnLecture = switchControl.isOn;
}
- (void) notifyOnStudySwitchChanged:(id)sender {
    UISwitch* switchControl = sender;
    self.notifyOnStudy = switchControl.isOn;
}
- (void) notifyOnElseSwitchChanged:(id)sender {
    UISwitch* switchControl = sender;
    self.notifyOnElse = switchControl.isOn;
}

- (void) otherSwitchChanged:(id)sender {
    UISwitch* switchControl = sender;
    NSLog( @"The otherSwitchChanged switch is %@", switchControl.on ? @"ON" : @"OFF" );
}

#pragma mark UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *basicCell = [self.tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
    basicCell.textLabel.text = @"unset";
    //viewWithTag should equal TEXT_CELL_TAG_FOR_REMOVAL
    if ([basicCell.contentView viewWithTag:2]) {
        [[basicCell.contentView viewWithTag:2] removeFromSuperview];
    }
    UITableViewCell *rightDetailCell = [self.tableView dequeueReusableCellWithIdentifier:@"RightDetailCell"];
    rightDetailCell.textLabel.text = @"unset";
    UITableViewCell *notificationCell = [self.tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
    rightDetailCell.textLabel.text = @"unset";
    //viewWithTag should equal TEXT_CELL_TAG_FOR_REMOVAL
    if ([rightDetailCell.contentView viewWithTag:2]) {
        [[rightDetailCell.contentView viewWithTag:2] removeFromSuperview];
    }
    
    if (indexPath.section == 0) {
        //Profile
        switch (indexPath.row) {
            case 0:
                basicCell.textLabel.text = @"";
                
                //create user photo space
                UIView *userPhotoView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 44, 44)];
                UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, userPhotoView.frame.size.width, userPhotoView.frame.size.height)];
                self.avatarImageView = userImageView;
                
               
                XMPPJID *myJID = [[[self appDelegate] xmppStream] myJID];
                
                userImageView.image = [[self appDelegate] avatarForUser:myJID];
                
                userImageView.backgroundColor=[UIColor clearColor];
                [userPhotoView.layer setCornerRadius:8.0f];
                [userPhotoView.layer setMasksToBounds:YES];
                
                CGRect editFrame = CGRectMake(0, 34, 44, 10);
                UILabel *editLabel = [[UILabel alloc] initWithFrame:editFrame];
                editLabel.backgroundColor = [UIColor blackColor];
                editLabel.text = @"edit";
                editLabel.textColor = [UIColor lightTextColor];
                editLabel.font = [UIFont systemFontOfSize:11];
                editLabel.textAlignment = NSTextAlignmentCenter;
                
                //tap listeners
                UITapGestureRecognizer *singleFingerTap =
                [[UITapGestureRecognizer alloc] initWithTarget:self
                                                        action:@selector(avatarTap)];
                [userPhotoView addGestureRecognizer:singleFingerTap];
                
                [userPhotoView addSubview:userImageView];
                [userPhotoView addSubview:editLabel];
                [basicCell.contentView addSubview:userPhotoView];
                
                //create a textfield to put in the cell
                UITextField *userNicknameTextField = [[UITextField alloc] initWithFrame:CGRectMake(64, 10, 240, 30)];
                userNicknameTextField.placeholder = @"Chatroom Nickname";
                userNicknameTextField.adjustsFontSizeToFitWidth = YES;
                userNicknameTextField.textColor = [UIColor blackColor];
                userNicknameTextField.text = self.userNickname;
                userNicknameTextField.returnKeyType = UIReturnKeyDone;
                userNicknameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                userNicknameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                userNicknameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
                userNicknameTextField.delegate = self;
                userNicknameTextField.tag = TEXT_CELL_TAG_FOR_REMOVAL;
                self.nicknameTextField = userNicknameTextField;
                [basicCell.contentView addSubview:userNicknameTextField];
                
                return basicCell;
                break;
        }
    }
    else if (indexPath.section == 1) {
        //UCLA Login
        switch (indexPath.row) {
            case 0: {
                //create a textfield to put in the cell
                UITextField *userIDTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 185, 30)];
                userIDTextField.adjustsFontSizeToFitWidth = YES;
                userIDTextField.textColor = [UIColor blackColor];
                userIDTextField.text = self.userID;
                userIDTextField.returnKeyType = UIReturnKeyDone;
                userIDTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                userIDTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                userIDTextField.autocorrectionType = UITextAutocorrectionTypeNo;
                userIDTextField.delegate = self;
                userIDTextField.tag = TEXT_CELL_TAG_FOR_REMOVAL;
                self.usernameTextField = userIDTextField;
                [rightDetailCell.contentView addSubview:userIDTextField];
                
                rightDetailCell.textLabel.text = @"";
                rightDetailCell.detailTextLabel.text = @"Username";
                return rightDetailCell;
                break; }
            case 1: {
                //create a textfield to put in the cell
                UITextField *userPassTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 185, 30)];
                userPassTextField.adjustsFontSizeToFitWidth = YES;
                userPassTextField.textColor = [UIColor blackColor];
                userPassTextField.text = self.userPass;
                userPassTextField.secureTextEntry = true;
                userPassTextField.returnKeyType = UIReturnKeyDone;
                userPassTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                userPassTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                userPassTextField.autocorrectionType = UITextAutocorrectionTypeNo;
                userPassTextField.delegate = self;
                userPassTextField.tag = TEXT_CELL_TAG_FOR_REMOVAL;
                self.userPassTextField = userPassTextField;
                [rightDetailCell.contentView addSubview:userPassTextField];
                
                rightDetailCell.textLabel.text = @"";
                rightDetailCell.detailTextLabel.text = @"Password";
                return rightDetailCell;
                break; }
            case 2: {
                basicCell.textLabel.text = @"Log in automatically";
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                basicCell.accessoryView = switchView;
                [switchView setOn:!self.autoLoginDisabled animated:NO];
                [switchView addTarget:self action:@selector(autoLoginSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                return basicCell;
                break; }
        }
    }
    else if (indexPath.section == 2) {
        //Notification Settings
        switch (indexPath.row) {
            case 0: {
                basicCell.textLabel.text = @"Push Notifications";
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                basicCell.accessoryView = switchView;
                [switchView setOn:(self.notificationsEnabled) animated:NO];
                [switchView addTarget:self action:@selector(prepareForNotificationsOnSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                return basicCell;
                break;
            }
            case 1: {
                notificationCell.textLabel.text = @"Notify on Lecture message";
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                notificationCell.accessoryView = switchView;
                [switchView setOn:self.notifyOnLecture animated:NO];
                [switchView addTarget:self action:@selector(notifyOnLectureSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                
                //Grey out the text and disable the switch
                if (!self.notificationsEnabled) {
                    notificationCell.userInteractionEnabled = NO;
                    [notificationCell.textLabel setTextColor:[UIColor lightGrayColor]];
                }
                
                return notificationCell;
                break;
            }
            case 2: {
                notificationCell.textLabel.text = @"Notify on Study Group messages";
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                notificationCell.accessoryView = switchView;
                [switchView setOn:self.notifyOnStudy animated:NO];
                [switchView addTarget:self action:@selector(notifyOnStudySwitchChanged:) forControlEvents:UIControlEventValueChanged];
                
                //Grey out the text and disable the switch
                if (!self.notificationsEnabled) {
                    notificationCell.userInteractionEnabled = NO;
                    [notificationCell.textLabel setTextColor:[UIColor lightGrayColor]];
                }
                
                return notificationCell;
                break;
            }
            case 3: {
                notificationCell.textLabel.text = @"Notify on Class messages";
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                notificationCell.accessoryView = switchView;
                [switchView setOn:self.notifyOnElse animated:NO];
                [switchView addTarget:self action:@selector(notifyOnElseSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                
                //Grey out the text and disable the switch
                if (!self.notificationsEnabled) {
                    notificationCell.userInteractionEnabled = NO;
                    [notificationCell.textLabel setTextColor:[UIColor lightGrayColor]];
                }
                
                return notificationCell;
                break;
            }
        }
    }
    
    return basicCell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            //Profile
            return 1;
            break;
        case 1:
            //UCLA Login
            return 3;
            break;
        case 2:
            //Notification Settings
            return 4;
            break;
        default:
            break;
    }
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return @"Profile";
            break;
        case 1:
            return @"UCLA Login";
            break;
        case 2:
            return @"Notification Settings";
            break;
        default:
            break;
    }
    return @"Unknown Section";
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.usernameTextField) {
        self.userID = self.usernameTextField.text;
    } else if (textField == self.userPassTextField) {
        self.realUserPass = self.userPassTextField.text;
        self.userPass = [@"" stringByPaddingToLength:self.realUserPass.length withString: @"*" startingAtIndex:0];
    } else if (textField == self.nicknameTextField) {
        self.userNickname = self.nicknameTextField.text;
    }
}

#pragma mark extras
- (STAppDelegate *)appDelegate {
    return (STAppDelegate *)[[UIApplication sharedApplication] delegate];
}



#pragma mark user's photo stuff

- (void)avatarTap
{
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
    CGFloat avatarSize = 100.f;
    self.avatarImage = [image createThumbnailToFillSize:CGSizeMake(avatarSize, avatarSize)];
    self.imageUpdated = true;
    
    CGFloat side = 44.f;
    side *= [[UIScreen mainScreen] scale];
    
    UIImage *thumbnail = [image createThumbnailToFillSize:CGSizeMake(side, side)];
    self.avatarImageView.image = thumbnail;
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
