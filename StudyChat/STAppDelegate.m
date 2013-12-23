//
//  STAppDelegate.m
//  StudyChat
//
//  Created by Christopher Laganiere on 12/16/13.
//  Copyright (c) 2013 Chris Laganiere. All rights reserved.
//

#import "STAppDelegate.h"
#import "SSKeychain.h"

#import "XMPP.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "GCDAsyncSocket.h"
#import <CFNetwork/CFNetwork.h>

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface STAppDelegate()
- (void)setupStream;
- (void)goOnline;
- (void)goOffline;
@end

@implementation STAppDelegate

@synthesize xmppStream;
@synthesize _chatDelegate, _messageDelegate;

- (void)setupStream {
    if (!xmppStream) {
        NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
        xmppStream = [[XMPPStream alloc] init];
        [xmppStream setHostName:@"localhost"];
        [xmppStream setHostPort:5222];
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
}
- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}
- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}
- (BOOL)connect {
    
    [self setupStream];
    NSString *jabberID = @"cesare@chris.local";
    NSString *myPassword = @"password";

    
    /*
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoLogin"]) {
        jabberID = [[NSUserDefaults standardUserDefaults] stringForKey:@"userID"];
        myPassword = [SSKeychain passwordForService:@"xmpp" account:jabberID];
    }
     */
    if (![xmppStream isAuthenticated]) {
        NSLog(@"not authenticated yet...");
    }
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    NSLog(@"trying to connect");
    
    if (jabberID == nil || myPassword == nil) {
        return NO;
    }
    [xmppStream setMyJID:[XMPPJID jidWithString:jabberID]];
    password = myPassword;
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[NSString stringWithFormat:@"Can't connect to server %@", [error localizedDescription]]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        
        return NO;
    }
    return YES;
}
- (void)disconnect {
    [self goOffline];
    [xmppStream disconnect];
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    isOpen = YES;
    NSError *error = nil;
    NSLog(@"xmppStreamDidConnect");
    if (![[self xmppStream] authenticateWithPassword:password error:&error]) {
        NSLog(@"error: %@",error);
        DDLogError(@"Error authenticating: %@", error);
    }
}
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSLog(@"xmppStreamDidAuthenticate");
    [self goOnline];
}
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self disconnect];
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self connect];
}
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    NSString *presenceType = [presence type]; // online/offline
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:myUsername]) {
        if ([presenceType isEqualToString:@"available"]) {
            [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"chris.local"]];
        } else if ([presenceType isEqualToString:@"unavailable"]) {
            [_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"chris.local"]];
        }
    }
}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    if ([message isChatMessageWithBody])
	{
        NSLog(@"message received");
        NSString *msg = [[message elementForName:@"body"] stringValue];
        NSLog(@"msg: %@",msg);
        NSString *from = [[message attributeForName:@"from"] stringValue];
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:msg forKey:@"msg"];
        [m setObject:from forKey:@"sender"];
        [_messageDelegate newMessageReceived:m];
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
    return YES;
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
