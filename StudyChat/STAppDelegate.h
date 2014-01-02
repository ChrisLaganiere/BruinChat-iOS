//
//  STAppDelegate.h
//  StudyChat
//
//  Created by Christopher Laganiere on 12/16/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "XMPPFramework.h"

@class STLoginViewController;

@protocol STLoginDelegate
-(void)loginSucceeded;
-(void)loginFailed;
@end

@interface STAppDelegate : NSObject <UIApplicationDelegate, XMPPRosterDelegate> {
    XMPPStream *xmppStream;
    
    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
	XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    
    NSString *password;
    BOOL isOpen;
}
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet STLoginViewController *firstViewController;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

@property (nonatomic, assign)id _loginDelegate;

- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

- (BOOL)connect:(NSString *)userID withPass:(NSString *)userPass;
//-(void)getListOfChatrooms;
- (void)disconnect;
@end