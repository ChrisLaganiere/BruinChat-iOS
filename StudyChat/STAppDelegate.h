//
//  STAppDelegate.h
//  StudyChat
//
//  Created by Christopher Laganiere on 12/16/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPP.h"

@class STLoginViewController;

@protocol STChatDelegate
- (void)newBuddyOnline:(NSString *)buddyName;
- (void)buddyWentOffline:(NSString *)buddyName;
- (void)didDisconnect;
@end

@protocol STMessageDelegate
- (void)newMessageReceived:(NSDictionary *)messageContent;
@end

@interface STAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    STLoginViewController *viewController;
    XMPPStream *xmppStream;
    NSString *password;
    BOOL isOpen;
}
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet STLoginViewController *viewController;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;

@property (nonatomic, assign) id  _chatDelegate;
@property (nonatomic, assign) id  _messageDelegate;
- (BOOL)connect;
- (void)disconnect;
@end