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


@protocol STMessageDelegate
- (void)newMessageReceived:(NSDictionary *)messageContent;
@end

@protocol STLoginDelegate
-(void)loginSucceeded;
-(void)loginFailed;
@end

@interface STAppDelegate : NSObject <UIApplicationDelegate, XMPPRosterDelegate> {
    XMPPStream *xmppStream;
    
    NSString *password;
    BOOL isOpen;
}
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet STLoginViewController *firstViewController;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *xmppRosterStorage;

@property (nonatomic, assign) id  _messageDelegate;
@property (nonatomic, assign)id _loginDelegate;

- (NSManagedObjectContext *)managedObjectContext_roster;

- (BOOL)connect:(NSString *)userID withPass:(NSString *)userPass;
- (void)disconnect;
@end